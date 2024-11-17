import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class LugarCaptacionService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  LugarCaptacionService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateLugaresCaptacion(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateLugaresCaptacion();
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
    String path = join(await getDatabasesPath(), 'lugar_captacion.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Lugar de Captación
        await db.execute('''
          CREATE TABLE lugar_captacion (
            id_lugar_captacion INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_lugar_captacion_id ON lugar_captacion(id_lugar_captacion)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // LUGAR DE CAPTACION
  Future<List<Map<String, dynamic>>> _getAllLugaresCaptacionLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('lugar_captacion', orderBy: 'nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo lugares de captación desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleLugaresCaptacion(
      List<Map<String, dynamic>> lugaresCaptacionList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var lugarCaptacion in lugaresCaptacionList) {
        batch.insert(
          'lugar_captacion',
          lugarCaptacion,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando lugares de captación en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getLugarCaptacionByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'lugar_captacion',
        where: 'id_lugar_captacion = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo lugar de captación por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteLugarCaptacionLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'lugar_captacion',
        where: 'id_lugar_captacion = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando lugar de captación desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los lugares de captación
  Future<List<Map<String, dynamic>>> listarLugaresCaptacion() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> lugaresCaptacionLocal =
        await _getAllLugaresCaptacionLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateLugaresCaptacion();

    // Retornar los datos locales
    return lugaresCaptacionLocal;
  }

  // Obtener un lugar de captación por ID
  Future<Map<String, dynamic>> obtenerLugarCaptacionPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? lugarCaptacionLocal =
        await _getLugarCaptacionByIdLocal(id);
    if (lugarCaptacionLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchLugarCaptacionById(id);
      return lugarCaptacionLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchLugarCaptacionById(id);
  }

  // Agregar un nuevo lugar de captación
  Future<Map<String, dynamic>> agregarLugarCaptacion(
      Map<String, dynamic> nuevoLugarCaptacion) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-lugar-captacion';
      final response = await httpService.post(url, nuevoLugarCaptacion);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoLugarCaptacionData =
            jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleLugaresCaptacion([
          {
            'id_lugar_captacion': nuevoLugarCaptacionData['id_lugar_captacion'],
            'nombre': nuevoLugarCaptacionData['nombre'],
            'usuario_creacion': nuevoLugarCaptacionData['usuario_creacion'],
            'fecha_creacion': nuevoLugarCaptacionData['fecha_creacion'],
            'usuario_modificacion':
                nuevoLugarCaptacionData['usuario_modificacion'],
            'fecha_modificacion': nuevoLugarCaptacionData['fecha_modificacion'],
            'activo': nuevoLugarCaptacionData['activo']
                ? 1
                : 0, // SQLite no soporta booleanos
          }
        ]);

        return nuevoLugarCaptacionData;
      } else {
        throw Exception('Error al agregar el lugar de captación');
      }
    } catch (e) {
      print("Error creando lugar de captación: $e");
      rethrow;
    }
  }

  // Actualizar un lugar de captación existente
  Future<Map<String, dynamic>> actualizarLugarCaptacion(int idLugarCaptacion,
      Map<String, dynamic> lugarCaptacionActualizado) async {
    try {
      String url =
          '$BASE_URL/v1/catalogo/captacion/update-lugar-captacion/$idLugarCaptacion';
      final response = await httpService.put(url, lugarCaptacionActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final lugarCaptacionActualizadoData =
            jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleLugaresCaptacion([
          {
            'id_lugar_captacion':
                lugarCaptacionActualizadoData['id_lugar_captacion'],
            'nombre': lugarCaptacionActualizadoData['nombre'],
            'usuario_creacion':
                lugarCaptacionActualizadoData['usuario_creacion'],
            'fecha_creacion': lugarCaptacionActualizadoData['fecha_creacion'],
            'usuario_modificacion':
                lugarCaptacionActualizadoData['usuario_modificacion'],
            'fecha_modificacion':
                lugarCaptacionActualizadoData['fecha_modificacion'],
            'activo': lugarCaptacionActualizadoData['activo'] ? 1 : 0,
          }
        ]);

        return lugarCaptacionActualizadoData;
      } else {
        throw Exception('Error al actualizar el lugar de captación');
      }
    } catch (e) {
      print("Error actualizando lugar de captación: $e");
      rethrow;
    }
  }

  // Eliminar un lugar de captación
  Future<void> eliminarLugarCaptacion(int idLugarCaptacion) async {
    try {
      String url =
          '$BASE_URL/v1/catalogo/captacion/delete-lugar-captacion/$idLugarCaptacion';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteLugarCaptacionLocal(idLugarCaptacion);
      } else {
        throw Exception('Error al eliminar el lugar de captación');
      }
    } catch (e) {
      print("Error eliminando lugar de captación: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateLugaresCaptacion() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-lugar-captacion';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> lugaresCaptacionList =
            jsonResponse.map((lugar) {
          return {
            'id_lugar_captacion': lugar['id_lugar_captacion'],
            'nombre': lugar['nombre'],
            'usuario_creacion': lugar['usuario_creacion'],
            'fecha_creacion': lugar['fecha_creacion'],
            'usuario_modificacion': lugar['usuario_modificacion'],
            'fecha_modificacion': lugar['fecha_modificacion'],
            'activo': lugar['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleLugaresCaptacion(lugaresCaptacionList);
      } else {
        throw Exception('Error al listar lugares de captación');
      }
    } catch (e) {
      print("Error actualizando lugares de captación: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchLugarCaptacionById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/lugar-captacion/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final lugarCaptacionData =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleLugaresCaptacion([
          {
            'id_lugar_captacion': lugarCaptacionData['id_lugar_captacion'],
            'nombre': lugarCaptacionData['nombre'],
            'usuario_creacion': lugarCaptacionData['usuario_creacion'],
            'fecha_creacion': lugarCaptacionData['fecha_creacion'],
            'usuario_modificacion': lugarCaptacionData['usuario_modificacion'],
            'fecha_modificacion': lugarCaptacionData['fecha_modificacion'],
            'activo': lugarCaptacionData['activo'] ? 1 : 0,
          }
        ]);

        return lugarCaptacionData;
      } else if (response.statusCode == 404) {
        throw Exception('Lugar de captación no encontrado');
      } else {
        throw Exception('Error al obtener el lugar de captación');
      }
    } catch (e) {
      print("Error obteniendo lugar de captación por ID: $e");
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
      print("Error cerrando el servicio de lugares de captación: $e");
    }
  }
}
