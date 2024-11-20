import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class MaternidadService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  MaternidadService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateMaternidad(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateMaternidad();
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
    String path = join(await getDatabasesPath(), 'maternidad.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Maternidad
        await db.execute('''
          CREATE TABLE maternidad (
            id_maternidad INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_maternidad_id ON maternidad(id_maternidad)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // MATERNIDAD
  Future<List<Map<String, dynamic>>> _getAllMaternidadLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('maternidad', orderBy: 'nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo opciones de maternidad desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleMaternidad(List<Map<String, dynamic>> maternidadList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var maternidad in maternidadList) {
        batch.insert(
          'maternidad',
          maternidad,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando opciones de maternidad en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getMaternidadByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'maternidad',
        where: 'id_maternidad = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo opción de maternidad por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteMaternidadLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'maternidad',
        where: 'id_maternidad = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando opción de maternidad desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todas las opciones de maternidad
  Future<List<Map<String, dynamic>>> listarMaternidad() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> maternidadLocal = await _getAllMaternidadLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateMaternidad();

    // Retornar los datos locales
    return maternidadLocal;
  }

  // Obtener una opción de maternidad por ID
  Future<Map<String, dynamic>> obtenerMaternidadPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? maternidadLocal = await _getMaternidadByIdLocal(id);
    if (maternidadLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchMaternidadById(id);
      return maternidadLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchMaternidadById(id);
  }

  // Agregar una nueva opción de maternidad
  Future<Map<String, dynamic>> agregarMaternidad(Map<String, dynamic> nuevaMaternidad) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-maternidad';
      final response = await httpService.post(url, nuevaMaternidad);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevaMaternidadData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleMaternidad([{
          'id_maternidad': nuevaMaternidadData['id_maternidad'],
          'nombre': nuevaMaternidadData['nombre'],
          'usuario_creacion': nuevaMaternidadData['usuario_creacion'],
          'fecha_creacion': nuevaMaternidadData['fecha_creacion'],
          'usuario_modificacion': nuevaMaternidadData['usuario_modificacion'],
          'fecha_modificacion': nuevaMaternidadData['fecha_modificacion'],
          'activo': nuevaMaternidadData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevaMaternidadData;
      } else {
        throw Exception('Error al agregar la opción de maternidad');
      }
    } catch (e) {
      print("Error creando opción de maternidad: $e");
      rethrow;
    }
  }

  // Actualizar una opción de maternidad existente
  Future<Map<String, dynamic>> actualizarMaternidad(int idMaternidad, Map<String, dynamic> maternidadActualizada) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-maternidad/$idMaternidad';
      final response = await httpService.put(url, maternidadActualizada);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final maternidadActualizadaData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleMaternidad([{
          'id_maternidad': maternidadActualizadaData['id_maternidad'],
          'nombre': maternidadActualizadaData['nombre'],
          'usuario_creacion': maternidadActualizadaData['usuario_creacion'],
          'fecha_creacion': maternidadActualizadaData['fecha_creacion'],
          'usuario_modificacion': maternidadActualizadaData['usuario_modificacion'],
          'fecha_modificacion': maternidadActualizadaData['fecha_modificacion'],
          'activo': maternidadActualizadaData['activo'] ? 1 : 0,
        }]);

        return maternidadActualizadaData;
      } else {
        throw Exception('Error al actualizar la opción de maternidad');
      }
    } catch (e) {
      print("Error actualizando opción de maternidad: $e");
      rethrow;
    }
  }

  // Eliminar una opción de maternidad
  Future<void> eliminarMaternidad(int idMaternidad) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-maternidad/$idMaternidad';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteMaternidadLocal(idMaternidad);
      } else {
        throw Exception('Error al eliminar la opción de maternidad');
      }
    } catch (e) {
      print("Error eliminando opción de maternidad: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateMaternidad() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-maternidad';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> maternidadList = jsonResponse.map((maternidad) {
          return {
            'id_maternidad': maternidad['id_maternidad'],
            'nombre': maternidad['nombre'],
            'usuario_creacion': maternidad['usuario_creacion'],
            'fecha_creacion': maternidad['fecha_creacion'],
            'usuario_modificacion': maternidad['usuario_modificacion'],
            'fecha_modificacion': maternidad['fecha_modificacion'],
            'activo': maternidad['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleMaternidad(maternidadList);
      } else {
        throw Exception('Error al listar las opciones de maternidad');
      }
    } catch (e) {
      print("Error actualizando opciones de maternidad: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchMaternidadById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/maternidad/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final maternidadData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleMaternidad([{
          'id_maternidad': maternidadData['id_maternidad'],
          'nombre': maternidadData['nombre'],
          'usuario_creacion': maternidadData['usuario_creacion'],
          'fecha_creacion': maternidadData['fecha_creacion'],
          'usuario_modificacion': maternidadData['usuario_modificacion'],
          'fecha_modificacion': maternidadData['fecha_modificacion'],
          'activo': maternidadData['activo'] ? 1 : 0,
        }]);

        return maternidadData;
      } else if (response.statusCode == 404) {
        throw Exception('Opción de maternidad no encontrada');
      } else {
        throw Exception('Error al obtener la opción de maternidad');
      }
    } catch (e) {
      print("Error obteniendo opción de maternidad por ID: $e");
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
      print("Error cerrando el servicio de maternidad: $e");
    }
  }
}
