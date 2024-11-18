import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class PuestoNotificacionService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  PuestoNotificacionService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdatePuestosNotificacion(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdatePuestosNotificacion();
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
    String path = join(await getDatabasesPath(), 'puesto_notificacion.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Puesto de Notificación
        await db.execute('''
          CREATE TABLE puesto_notificacion (
            id_puesto_notificacion INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_puesto_notificacion_id ON puesto_notificacion(id_puesto_notificacion)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // PUESTO DE NOTIFICACION
  Future<List<Map<String, dynamic>>> _getAllPuestosNotificacionLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'puesto_notificacion',
        orderBy: 'nombre ASC',
      );
      return maps;
    } catch (e) {
      print("Error obteniendo puestos de notificación desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultiplePuestosNotificacion(List<Map<String, dynamic>> puestosList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var puesto in puestosList) {
        batch.insert(
          'puesto_notificacion',
          puesto,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando puestos de notificación en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getPuestoNotificacionByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'puesto_notificacion',
        where: 'id_puesto_notificacion = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo puesto de notificación por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deletePuestoNotificacionLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'puesto_notificacion',
        where: 'id_puesto_notificacion = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando puesto de notificación desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los puestos de notificación
  Future<List<Map<String, dynamic>>> listarPuestosNotificacion() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> puestosLocal = await _getAllPuestosNotificacionLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdatePuestosNotificacion();

    // Retornar los datos locales
    return puestosLocal;
  }

  // Obtener un puesto de notificación por ID
  Future<Map<String, dynamic>> obtenerPuestoNotificacionPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? puestoLocal = await _getPuestoNotificacionByIdLocal(id);
    if (puestoLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchPuestoNotificacionById(id);
      return puestoLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchPuestoNotificacionById(id);
  }

  // Agregar un nuevo puesto de notificación
  Future<Map<String, dynamic>> agregarPuestoNotificacion(Map<String, dynamic> nuevoPuesto) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-puesto-notificacion';
      final response = await httpService.post(url, nuevoPuesto);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoPuestoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultiplePuestosNotificacion([{
          'id_puesto_notificacion': nuevoPuestoData['id_puesto_notificacion'],
          'nombre': nuevoPuestoData['nombre'],
          'usuario_creacion': nuevoPuestoData['usuario_creacion'],
          'fecha_creacion': nuevoPuestoData['fecha_creacion'],
          'usuario_modificacion': nuevoPuestoData['usuario_modificacion'],
          'fecha_modificacion': nuevoPuestoData['fecha_modificacion'],
          'activo': nuevoPuestoData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevoPuestoData;
      } else {
        throw Exception('Error al agregar el puesto de notificación');
      }
    } catch (e) {
      print("Error creando puesto de notificación: $e");
      rethrow;
    }
  }

  // Actualizar un puesto de notificación existente
  Future<Map<String, dynamic>> actualizarPuestoNotificacion(int idPuesto, Map<String, dynamic> puestoActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-puesto-notificacion/$idPuesto';
      final response = await httpService.put(url, puestoActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final puestoActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultiplePuestosNotificacion([{
          'id_puesto_notificacion': puestoActualizadoData['id_puesto_notificacion'],
          'nombre': puestoActualizadoData['nombre'],
          'usuario_creacion': puestoActualizadoData['usuario_creacion'],
          'fecha_creacion': puestoActualizadoData['fecha_creacion'],
          'usuario_modificacion': puestoActualizadoData['usuario_modificacion'],
          'fecha_modificacion': puestoActualizadoData['fecha_modificacion'],
          'activo': puestoActualizadoData['activo'] ? 1 : 0,
        }]);

        return puestoActualizadoData;
      } else {
        throw Exception('Error al actualizar el puesto de notificación');
      }
    } catch (e) {
      print("Error actualizando puesto de notificación: $e");
      rethrow;
    }
  }

  // Eliminar un puesto de notificación
  Future<void> eliminarPuestoNotificacion(int idPuesto) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-puesto-notificacion/$idPuesto';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deletePuestoNotificacionLocal(idPuesto);
      } else {
        throw Exception('Error al eliminar el puesto de notificación');
      }
    } catch (e) {
      print("Error eliminando puesto de notificación: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdatePuestosNotificacion() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-puesto-notificacion';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> puestosList = jsonResponse.map((puesto) {
          return {
            'id_puesto_notificacion': puesto['id_puesto_notificacion'],
            'nombre': puesto['nombre'],
            'usuario_creacion': puesto['usuario_creacion'],
            'fecha_creacion': puesto['fecha_creacion'],
            'usuario_modificacion': puesto['usuario_modificacion'],
            'fecha_modificacion': puesto['fecha_modificacion'],
            'activo': puesto['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultiplePuestosNotificacion(puestosList);
      } else {
        throw Exception('Error al listar puestos de notificación');
      }
    } catch (e) {
      print("Error actualizando puestos de notificación: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchPuestoNotificacionById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/puesto-notificacion/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final puestoData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultiplePuestosNotificacion([{
          'id_puesto_notificacion': puestoData['id_puesto_notificacion'],
          'nombre': puestoData['nombre'],
          'usuario_creacion': puestoData['usuario_creacion'],
          'fecha_creacion': puestoData['fecha_creacion'],
          'usuario_modificacion': puestoData['usuario_modificacion'],
          'fecha_modificacion': puestoData['fecha_modificacion'],
          'activo': puestoData['activo'] ? 1 : 0,
        }]);

        return puestoData;
      } else if (response.statusCode == 404) {
        throw Exception('Puesto de notificación no encontrado');
      } else {
        throw Exception('Error al obtener el puesto de notificación');
      }
    } catch (e) {
      print("Error obteniendo puesto de notificación por ID: $e");
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
      print("Error cerrando el servicio de puestos de notificación: $e");
    }
  }
}
