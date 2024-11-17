import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class LugarIngresoPaisService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  LugarIngresoPaisService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateLugarIngresoPais(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateLugarIngresoPais();
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
    String path = join(await getDatabasesPath(), 'lugar_ingreso_pais.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Lugar de Ingreso por País
        await db.execute('''
          CREATE TABLE lugar_ingreso_pais (
            id_lugar_ingreso_pais INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_lugar_ingreso_pais_id ON lugar_ingreso_pais(id_lugar_ingreso_pais)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // LUGAR DE INGRESO PAIS
  Future<List<Map<String, dynamic>>> _getAllLugarIngresoPaisLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'lugar_ingreso_pais',
        orderBy: 'nombre ASC',
      );
      return maps;
    } catch (e) {
      print("Error obteniendo lugares de ingreso por país desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleLugarIngresoPais(List<Map<String, dynamic>> lugaresList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var lugar in lugaresList) {
        batch.insert(
          'lugar_ingreso_pais',
          lugar,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando lugares de ingreso por país en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getLugarIngresoPaisByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'lugar_ingreso_pais',
        where: 'id_lugar_ingreso_pais = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo lugar de ingreso por país por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteLugarIngresoPaisLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'lugar_ingreso_pais',
        where: 'id_lugar_ingreso_pais = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando lugar de ingreso por país desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los lugares de ingreso por país
  Future<List<Map<String, dynamic>>> listarLugarIngresoPais() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> lugaresLocal = await _getAllLugarIngresoPaisLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateLugarIngresoPais();

    // Retornar los datos locales
    return lugaresLocal;
  }

  // Obtener un lugar de ingreso por país por ID
  Future<Map<String, dynamic>> obtenerLugarIngresoPaisPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? lugarLocal = await _getLugarIngresoPaisByIdLocal(id);
    if (lugarLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchLugarIngresoPaisById(id);
      return lugarLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchLugarIngresoPaisById(id);
  }

  // Agregar un nuevo lugar de ingreso por país
  Future<Map<String, dynamic>> agregarLugarIngresoPais(Map<String, dynamic> nuevoLugar) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-lugar-ingreso';
      final response = await httpService.post(url, nuevoLugar);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoLugarData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleLugarIngresoPais([{
          'id_lugar_ingreso_pais': nuevoLugarData['id_lugar_ingreso_pais'],
          'nombre': nuevoLugarData['nombre'],
          'usuario_creacion': nuevoLugarData['usuario_creacion'],
          'fecha_creacion': nuevoLugarData['fecha_creacion'],
          'usuario_modificacion': nuevoLugarData['usuario_modificacion'],
          'fecha_modificacion': nuevoLugarData['fecha_modificacion'],
          'activo': nuevoLugarData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevoLugarData;
      } else {
        throw Exception('Error al agregar el lugar de ingreso por país');
      }
    } catch (e) {
      print("Error creando lugar de ingreso por país: $e");
      rethrow;
    }
  }

  // Actualizar un lugar de ingreso por país existente
  Future<Map<String, dynamic>> actualizarLugarIngresoPais(int idLugar, Map<String, dynamic> lugarActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-lugar-ingreso-pais/$idLugar';
      final response = await httpService.put(url, lugarActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final lugarActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleLugarIngresoPais([{
          'id_lugar_ingreso_pais': lugarActualizadoData['id_lugar_ingreso_pais'],
          'nombre': lugarActualizadoData['nombre'],
          'usuario_creacion': lugarActualizadoData['usuario_creacion'],
          'fecha_creacion': lugarActualizadoData['fecha_creacion'],
          'usuario_modificacion': lugarActualizadoData['usuario_modificacion'],
          'fecha_modificacion': lugarActualizadoData['fecha_modificacion'],
          'activo': lugarActualizadoData['activo'] ? 1 : 0,
        }]);

        return lugarActualizadoData;
      } else {
        throw Exception('Error al actualizar el lugar de ingreso por país');
      }
    } catch (e) {
      print("Error actualizando lugar de ingreso por país: $e");
      rethrow;
    }
  }

  // Eliminar un lugar de ingreso por país
  Future<void> eliminarLugarIngresoPais(int idLugar) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-lugar-ingreso-pais/$idLugar';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteLugarIngresoPaisLocal(idLugar);
      } else {
        throw Exception('Error al eliminar el lugar de ingreso por país');
      }
    } catch (e) {
      print("Error eliminando lugar de ingreso por país: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateLugarIngresoPais() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-lugar-ingreso-pais';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> lugaresList = jsonResponse.map((lugar) {
          return {
            'id_lugar_ingreso_pais': lugar['id_lugar_ingreso_pais'],
            'nombre': lugar['nombre'],
            'usuario_creacion': lugar['usuario_creacion'],
            'fecha_creacion': lugar['fecha_creacion'],
            'usuario_modificacion': lugar['usuario_modificacion'],
            'fecha_modificacion': lugar['fecha_modificacion'],
            'activo': lugar['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleLugarIngresoPais(lugaresList);
      } else {
        throw Exception('Error al listar lugares de ingreso por país');
      }
    } catch (e) {
      print("Error actualizando lugares de ingreso por país: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchLugarIngresoPaisById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/lugar-ingreso/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final lugarData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleLugarIngresoPais([{
          'id_lugar_ingreso_pais': lugarData['id_lugar_ingreso_pais'],
          'nombre': lugarData['nombre'],
          'usuario_creacion': lugarData['usuario_creacion'],
          'fecha_creacion': lugarData['fecha_creacion'],
          'usuario_modificacion': lugarData['usuario_modificacion'],
          'fecha_modificacion': lugarData['fecha_modificacion'],
          'activo': lugarData['activo'] ? 1 : 0,
        }]);

        return lugarData;
      } else if (response.statusCode == 404) {
        throw Exception('Lugar de ingreso por país no encontrado');
      } else {
        throw Exception('Error al obtener el lugar de ingreso por país');
      }
    } catch (e) {
      print("Error obteniendo lugar de ingreso por país por ID: $e");
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
      print("Error cerrando el servicio de lugares de ingreso por país: $e");
    }
  }
}
