import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class CondicionPersonaService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  CondicionPersonaService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateCondicionesPersona(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateCondicionesPersona();
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
    String path = join(await getDatabasesPath(), 'condicion_persona.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Condición de Persona
        await db.execute('''
          CREATE TABLE condicion_persona (
            id_condicion_persona INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_condicion_persona_id ON condicion_persona(id_condicion_persona)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // CONDICION DE PERSONA
  Future<List<Map<String, dynamic>>> _getAllCondicionesPersonaLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('condicion_persona', orderBy: 'nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo condiciones de persona desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleCondicionesPersona(
      List<Map<String, dynamic>> condicionesPersonaList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var condicionPersona in condicionesPersonaList) {
        batch.insert(
          'condicion_persona',
          condicionPersona,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando condiciones de persona en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getCondicionPersonaByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'condicion_persona',
        where: 'id_condicion_persona = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo condición de persona por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteCondicionPersonaLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'condicion_persona',
        where: 'id_condicion_persona = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando condición de persona desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todas las condiciones de persona
  Future<List<Map<String, dynamic>>> listarCondicionesPersona() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> condicionesPersonaLocal =
        await _getAllCondicionesPersonaLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateCondicionesPersona();

    // Retornar los datos locales
    return condicionesPersonaLocal;
  }

  // Obtener una condición de persona por ID
  Future<Map<String, dynamic>> obtenerCondicionPersonaPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? condicionPersonaLocal =
        await _getCondicionPersonaByIdLocal(id);
    if (condicionPersonaLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchCondicionPersonaById(id);
      return condicionPersonaLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchCondicionPersonaById(id);
  }

  // Agregar una nueva condición de persona
  Future<Map<String, dynamic>> agregarCondicionPersona(
      Map<String, dynamic> nuevaCondicionPersona) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-condicion-persona';
      final response = await httpService.post(url, nuevaCondicionPersona);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevaCondicionPersonaData =
            jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleCondicionesPersona([
          {
            'id_condicion_persona':
                nuevaCondicionPersonaData['id_condicion_persona'],
            'nombre': nuevaCondicionPersonaData['nombre'],
            'usuario_creacion': nuevaCondicionPersonaData['usuario_creacion'],
            'fecha_creacion': nuevaCondicionPersonaData['fecha_creacion'],
            'usuario_modificacion':
                nuevaCondicionPersonaData['usuario_modificacion'],
            'fecha_modificacion':
                nuevaCondicionPersonaData['fecha_modificacion'],
            'activo': nuevaCondicionPersonaData['activo']
                ? 1
                : 0, // SQLite no soporta booleanos
          }
        ]);

        return nuevaCondicionPersonaData;
      } else {
        throw Exception('Error al agregar la condición de persona');
      }
    } catch (e) {
      print("Error creando condición de persona: $e");
      rethrow;
    }
  }

  // Actualizar una condición de persona existente
  Future<Map<String, dynamic>> actualizarCondicionPersona(
      int idCondicionPersona,
      Map<String, dynamic> condicionPersonaActualizada) async {
    try {
      String url =
          '$BASE_URL/v1/catalogo/captacion/update-condicion-persona/$idCondicionPersona';
      final response = await httpService.put(url, condicionPersonaActualizada);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final condicionPersonaActualizadaData =
            jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleCondicionesPersona([
          {
            'id_condicion_persona':
                condicionPersonaActualizadaData['id_condicion_persona'],
            'nombre': condicionPersonaActualizadaData['nombre'],
            'usuario_creacion':
                condicionPersonaActualizadaData['usuario_creacion'],
            'fecha_creacion': condicionPersonaActualizadaData['fecha_creacion'],
            'usuario_modificacion':
                condicionPersonaActualizadaData['usuario_modificacion'],
            'fecha_modificacion':
                condicionPersonaActualizadaData['fecha_modificacion'],
            'activo': condicionPersonaActualizadaData['activo'] ? 1 : 0,
          }
        ]);

        return condicionPersonaActualizadaData;
      } else {
        throw Exception('Error al actualizar la condición de persona');
      }
    } catch (e) {
      print("Error actualizando condición de persona: $e");
      rethrow;
    }
  }

  // Eliminar una condición de persona
  Future<void> eliminarCondicionPersona(int idCondicionPersona) async {
    try {
      String url =
          '$BASE_URL/v1/catalogo/captacion/delete-condicion-persona/$idCondicionPersona';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteCondicionPersonaLocal(idCondicionPersona);
      } else {
        throw Exception('Error al eliminar la condición de persona');
      }
    } catch (e) {
      print("Error eliminando condición de persona: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateCondicionesPersona() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-condicion-persona';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> condicionesPersonaList =
            jsonResponse.map((condicion) {
          return {
            'id_condicion_persona': condicion['id_condicion_persona'],
            'nombre': condicion['nombre'],
            'usuario_creacion': condicion['usuario_creacion'],
            'fecha_creacion': condicion['fecha_creacion'],
            'usuario_modificacion': condicion['usuario_modificacion'],
            'fecha_modificacion': condicion['fecha_modificacion'],
            'activo': condicion['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleCondicionesPersona(condicionesPersonaList);
      } else {
        throw Exception('Error al listar condiciones de persona');
      }
    } catch (e) {
      print("Error actualizando condiciones de persona: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchCondicionPersonaById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/condicion-persona/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final condicionPersonaData =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleCondicionesPersona([
          {
            'id_condicion_persona':
                condicionPersonaData['id_condicion_persona'],
            'nombre': condicionPersonaData['nombre'],
            'usuario_creacion': condicionPersonaData['usuario_creacion'],
            'fecha_creacion': condicionPersonaData['fecha_creacion'],
            'usuario_modificacion':
                condicionPersonaData['usuario_modificacion'],
            'fecha_modificacion': condicionPersonaData['fecha_modificacion'],
            'activo': condicionPersonaData['activo'] ? 1 : 0,
          }
        ]);

        return condicionPersonaData;
      } else if (response.statusCode == 404) {
        throw Exception('Condición de persona no encontrada');
      } else {
        throw Exception('Error al obtener la condición de persona');
      }
    } catch (e) {
      print("Error obteniendo condición de persona por ID: $e");
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
      print("Error cerrando el servicio de condiciones de persona: $e");
    }
  }
}
