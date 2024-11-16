import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class EventoSaludService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  EventoSaludService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateEventosSalud(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateEventosSalud();
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
    String path = join(await getDatabasesPath(), 'eventos_salud.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Eventos de Salud
        await db.execute('''
          CREATE TABLE eventos_salud (
            id_evento_salud INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_eventos_salud_id ON eventos_salud(id_evento_salud)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // EVENTOS DE SALUD
  Future<List<Map<String, dynamic>>> _getAllEventosSaludLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('eventos_salud', orderBy: 'nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo eventos de salud desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleEventosSalud(List<Map<String, dynamic>> eventosSaludList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var eventoSalud in eventosSaludList) {
        batch.insert(
          'eventos_salud',
          eventoSalud,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando eventos de salud en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getEventoSaludByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'eventos_salud',
        where: 'id_evento_salud = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo evento de salud por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteEventoSaludLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'eventos_salud',
        where: 'id_evento_salud = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando evento de salud desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los eventos de salud
  Future<List<Map<String, dynamic>>> listarEventosSalud() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> eventosSaludLocal = await _getAllEventosSaludLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateEventosSalud();

    // Retornar los datos locales
    return eventosSaludLocal;
  }

  // Obtener un evento de salud por ID
  Future<Map<String, dynamic>> obtenerEventoSaludPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? eventoSaludLocal = await _getEventoSaludByIdLocal(id);
    if (eventoSaludLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchEventoSaludById(id);
      return eventoSaludLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchEventoSaludById(id);
  }

  // Agregar un nuevo evento de salud
  Future<Map<String, dynamic>> agregarEventoSalud(Map<String, dynamic> nuevoEvento) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-evento-salud';
      final response = await httpService.post(url, nuevoEvento);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevaEventoSaludData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleEventosSalud([{
          'id_evento_salud': nuevaEventoSaludData['id_evento_salud'],
          'nombre': nuevaEventoSaludData['nombre'],
          'usuario_creacion': nuevaEventoSaludData['usuario_creacion'],
          'fecha_creacion': nuevaEventoSaludData['fecha_creacion'],
          'activo': nuevaEventoSaludData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevaEventoSaludData;
      } else {
        throw Exception('Error al agregar el evento de salud');
      }
    } catch (e) {
      print("Error creando evento de salud: $e");
      rethrow;
    }
  }

  // Actualizar un evento de salud existente
  Future<Map<String, dynamic>> actualizarEventoSalud(int idEventoSalud, Map<String, dynamic> eventoActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-evento-salud/$idEventoSalud';
      final response = await httpService.put(url, eventoActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final eventoActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleEventosSalud([{
          'id_evento_salud': eventoActualizadoData['id_evento_salud'],
          'nombre': eventoActualizadoData['nombre'],
          'usuario_creacion': eventoActualizadoData['usuario_creacion'],
          'fecha_creacion': eventoActualizadoData['fecha_creacion'],
          'activo': eventoActualizadoData['activo'] ? 1 : 0,
        }]);

        return eventoActualizadoData;
      } else {
        throw Exception('Error al actualizar el evento de salud');
      }
    } catch (e) {
      print("Error actualizando evento de salud: $e");
      rethrow;
    }
  }

  // Eliminar un evento de salud
  Future<void> eliminarEventoSalud(int idEventoSalud) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-evento-salud/$idEventoSalud';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteEventoSaludLocal(idEventoSalud);
      } else {
        throw Exception('Error al eliminar el evento de salud');
      }
    } catch (e) {
      print("Error eliminando evento de salud: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateEventosSalud() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-evento-salud';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> eventosSaludList = jsonResponse.map((evento) {
          return {
            'id_evento_salud': evento['id_evento_salud'],
            'nombre': evento['nombre'],
            'usuario_creacion': evento['usuario_creacion'],
            'fecha_creacion': evento['fecha_creacion'],
            'activo': evento['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleEventosSalud(eventosSaludList);
      } else {
        throw Exception('Error al listar eventos de salud');
      }
    } catch (e) {
      print("Error actualizando eventos de salud: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchEventoSaludById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/evento-salud/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final eventoSaludData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleEventosSalud([{
          'id_evento_salud': eventoSaludData['id_evento_salud'],
          'nombre': eventoSaludData['nombre'],
          'usuario_creacion': eventoSaludData['usuario_creacion'],
          'fecha_creacion': eventoSaludData['fecha_creacion'],
          'activo': eventoSaludData['activo'] ? 1 : 0,
        }]);

        return eventoSaludData;
      } else if (response.statusCode == 404) {
        throw Exception('Evento de salud no encontrado');
      } else {
        throw Exception('Error al obtener el evento de salud');
      }
    } catch (e) {
      print("Error obteniendo evento de salud por ID: $e");
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
      print("Error cerrando el servicio de eventos de salud: $e");
    }
  }
}
