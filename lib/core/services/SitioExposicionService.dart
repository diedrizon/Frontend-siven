import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class SitioExposicionService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SitioExposicionService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateSitiosExposicion(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateSitiosExposicion();
      }
    });
  }

  // Obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Inicializar la base de datos
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos SQLite
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sitio_exposicion.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Sitio de Exposición
        await db.execute('''
          CREATE TABLE sitio_exposicion (
            id_sitio_exposicion INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_sitio_exposicion_id ON sitio_exposicion(id_sitio_exposicion)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // SITIO DE EXPOSICION
  Future<List<Map<String, dynamic>>> _getAllSitiosExposicionLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sitio_exposicion',
        orderBy: 'nombre ASC',
      );
      return maps;
    } catch (e) {
      print("Error obteniendo sitios de exposición desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleSitiosExposicion(List<Map<String, dynamic>> sitiosList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var sitio in sitiosList) {
        batch.insert(
          'sitio_exposicion',
          sitio,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando sitios de exposición en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getSitioExposicionByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sitio_exposicion',
        where: 'id_sitio_exposicion = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo sitio de exposición por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteSitioExposicionLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'sitio_exposicion',
        where: 'id_sitio_exposicion = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando sitio de exposición desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los sitios de exposición
  Future<List<Map<String, dynamic>>> listarSitiosExposicion() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> sitiosLocal = await _getAllSitiosExposicionLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateSitiosExposicion();

    // Retornar los datos locales
    return sitiosLocal;
  }

  // Obtener un sitio de exposición por ID
  Future<Map<String, dynamic>> obtenerSitioExposicionPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? sitioLocal = await _getSitioExposicionByIdLocal(id);
    if (sitioLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchSitioExposicionById(id);
      return sitioLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchSitioExposicionById(id);
  }

  // Agregar un nuevo sitio de exposición
  Future<Map<String, dynamic>> agregarSitioExposicion(Map<String, dynamic> nuevoSitio) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-sitio-exposicion';
      final response = await httpService.post(url, nuevoSitio);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoSitioData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleSitiosExposicion([{
          'id_sitio_exposicion': nuevoSitioData['id_sitio_exposicion'],
          'nombre': nuevoSitioData['nombre'],
          'usuario_creacion': nuevoSitioData['usuario_creacion'],
          'fecha_creacion': nuevoSitioData['fecha_creacion'],
          'usuario_modificacion': nuevoSitioData['usuario_modificacion'],
          'fecha_modificacion': nuevoSitioData['fecha_modificacion'],
          'activo': nuevoSitioData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevoSitioData;
      } else {
        throw Exception('Error al agregar el sitio de exposición');
      }
    } catch (e) {
      print("Error creando sitio de exposición: $e");
      rethrow;
    }
  }

  // Actualizar un sitio de exposición existente
  Future<Map<String, dynamic>> actualizarSitioExposicion(int idSitio, Map<String, dynamic> sitioActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-sitio-exposicion/$idSitio';
      final response = await httpService.put(url, sitioActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final sitioActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleSitiosExposicion([{
          'id_sitio_exposicion': sitioActualizadoData['id_sitio_exposicion'],
          'nombre': sitioActualizadoData['nombre'],
          'usuario_creacion': sitioActualizadoData['usuario_creacion'],
          'fecha_creacion': sitioActualizadoData['fecha_creacion'],
          'usuario_modificacion': sitioActualizadoData['usuario_modificacion'],
          'fecha_modificacion': sitioActualizadoData['fecha_modificacion'],
          'activo': sitioActualizadoData['activo'] ? 1 : 0,
        }]);

        return sitioActualizadoData;
      } else {
        throw Exception('Error al actualizar el sitio de exposición');
      }
    } catch (e) {
      print("Error actualizando sitio de exposición: $e");
      rethrow;
    }
  }

  // Eliminar un sitio de exposición
  Future<void> eliminarSitioExposicion(int idSitio) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-sitio-exposicion/$idSitio';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteSitioExposicionLocal(idSitio);
      } else {
        throw Exception('Error al eliminar el sitio de exposición');
      }
    } catch (e) {
      print("Error eliminando sitio de exposición: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateSitiosExposicion() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-sitio-exposicion';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> sitiosList = jsonResponse.map((sitio) {
          return {
            'id_sitio_exposicion': sitio['id_sitio_exposicion'],
            'nombre': sitio['nombre'],
            'usuario_creacion': sitio['usuario_creacion'],
            'fecha_creacion': sitio['fecha_creacion'],
            'usuario_modificacion': sitio['usuario_modificacion'],
            'fecha_modificacion': sitio['fecha_modificacion'],
            'activo': sitio['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleSitiosExposicion(sitiosList);
      } else {
        throw Exception('Error al listar sitios de exposición');
      }
    } catch (e) {
      print("Error actualizando sitios de exposición: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchSitioExposicionById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/sitio-exposicion/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final sitioData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleSitiosExposicion([{
          'id_sitio_exposicion': sitioData['id_sitio_exposicion'],
          'nombre': sitioData['nombre'],
          'usuario_creacion': sitioData['usuario_creacion'],
          'fecha_creacion': sitioData['fecha_creacion'],
          'usuario_modificacion': sitioData['usuario_modificacion'],
          'fecha_modificacion': sitioData['fecha_modificacion'],
          'activo': sitioData['activo'] ? 1 : 0,
        }]);

        return sitioData;
      } else if (response.statusCode == 404) {
        throw Exception('Sitio de exposición no encontrado');
      } else {
        throw Exception('Error al obtener el sitio de exposición');
      }
    } catch (e) {
      print("Error obteniendo sitio de exposición por ID: $e");
      throw e;
    }
  }

  // Cerrar la base de datos y cancelar la suscripción de conectividad
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
      await _connectivitySubscription?.cancel();
    } catch (e) {
      print("Error cerrando el servicio de sitios de exposición: $e");
    }
  }
}
