import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class ComorbilidadesService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ComorbilidadesService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateComorbilidades(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateComorbilidades();
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
    String path = join(await getDatabasesPath(), 'comorbilidades.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Comorbilidades
        await db.execute('''
          CREATE TABLE comorbilidades (
            id_comorbilidades INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_comorbilidades_id ON comorbilidades(id_comorbilidades)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // COMORBILIDADES
  Future<List<Map<String, dynamic>>> _getAllComorbilidadesLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('comorbilidades', orderBy: 'nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo comorbilidades desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleComorbilidades(List<Map<String, dynamic>> comorbilidadesList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var comorbilidad in comorbilidadesList) {
        batch.insert(
          'comorbilidades',
          comorbilidad,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando comorbilidades en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getComorbilidadByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'comorbilidades',
        where: 'id_comorbilidades = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo comorbilidad por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteComorbilidadLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'comorbilidades',
        where: 'id_comorbilidades = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando comorbilidad desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todas las comorbilidades
  Future<List<Map<String, dynamic>>> listarComorbilidades() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> comorbilidadesLocal = await _getAllComorbilidadesLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateComorbilidades();

    // Retornar los datos locales
    return comorbilidadesLocal;
  }

  // Obtener una comorbilidad por ID
  Future<Map<String, dynamic>> obtenerComorbilidadPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? comorbilidadLocal = await _getComorbilidadByIdLocal(id);
    if (comorbilidadLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchComorbilidadById(id);
      return comorbilidadLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchComorbilidadById(id);
  }

  // Agregar una nueva comorbilidad
  Future<Map<String, dynamic>> agregarComorbilidades(Map<String, dynamic> nuevaComorbilidad) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-comorbilidades';
      final response = await httpService.post(url, nuevaComorbilidad);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevaComorbilidadData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleComorbilidades([{
          'id_comorbilidades': nuevaComorbilidadData['id_comorbilidades'],
          'nombre': nuevaComorbilidadData['nombre'],
          'usuario_creacion': nuevaComorbilidadData['usuario_creacion'],
          'fecha_creacion': nuevaComorbilidadData['fecha_creacion'],
          'usuario_modificacion': nuevaComorbilidadData['usuario_modificacion'],
          'fecha_modificacion': nuevaComorbilidadData['fecha_modificacion'],
          'activo': nuevaComorbilidadData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevaComorbilidadData;
      } else {
        throw Exception('Error al agregar la comorbilidad');
      }
    } catch (e) {
      print("Error creando comorbilidad: $e");
      rethrow;
    }
  }

  // Actualizar una comorbilidad existente
  Future<Map<String, dynamic>> actualizarComorbilidades(int idComorbilidad, Map<String, dynamic> comorbilidadActualizada) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-comorbilidades/$idComorbilidad';
      final response = await httpService.put(url, comorbilidadActualizada);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final comorbilidadActualizadaData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleComorbilidades([{
          'id_comorbilidades': comorbilidadActualizadaData['id_comorbilidades'],
          'nombre': comorbilidadActualizadaData['nombre'],
          'usuario_creacion': comorbilidadActualizadaData['usuario_creacion'],
          'fecha_creacion': comorbilidadActualizadaData['fecha_creacion'],
          'usuario_modificacion': comorbilidadActualizadaData['usuario_modificacion'],
          'fecha_modificacion': comorbilidadActualizadaData['fecha_modificacion'],
          'activo': comorbilidadActualizadaData['activo'] ? 1 : 0,
        }]);

        return comorbilidadActualizadaData;
      } else if (response.statusCode == 404) {
        throw Exception('Comorbilidad no encontrada');
      } else {
        throw Exception('Error al actualizar la comorbilidad');
      }
    } catch (e) {
      print("Error actualizando comorbilidad: $e");
      rethrow;
    }
  }

  // Eliminar una comorbilidad
  Future<void> eliminarComorbilidades(int idComorbilidad) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-comorbilidades/$idComorbilidad';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteComorbilidadLocal(idComorbilidad);
      } else if (response.statusCode == 404) {
        throw Exception('Comorbilidad no encontrada');
      } else {
        throw Exception('Error al eliminar la comorbilidad');
      }
    } catch (e) {
      print("Error eliminando comorbilidad: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateComorbilidades() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-comorbilidades';
      final response = await httpService.post(url, {});

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> comorbilidadesList = jsonResponse.map((comorbilidad) {
          return {
            'id_comorbilidades': comorbilidad['id_comorbilidades'],
            'nombre': comorbilidad['nombre'],
            'usuario_creacion': comorbilidad['usuario_creacion'],
            'fecha_creacion': comorbilidad['fecha_creacion'],
            'usuario_modificacion': comorbilidad['usuario_modificacion'],
            'fecha_modificacion': comorbilidad['fecha_modificacion'],
            'activo': comorbilidad['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleComorbilidades(comorbilidadesList);
      } else {
        throw Exception('Error al listar comorbilidades');
      }
    } catch (e) {
      print("Error actualizando comorbilidades: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchComorbilidadById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/comorbilidades/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final comorbilidadData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleComorbilidades([{
          'id_comorbilidades': comorbilidadData['id_comorbilidades'],
          'nombre': comorbilidadData['nombre'],
          'usuario_creacion': comorbilidadData['usuario_creacion'],
          'fecha_creacion': comorbilidadData['fecha_creacion'],
          'usuario_modificacion': comorbilidadData['usuario_modificacion'],
          'fecha_modificacion': comorbilidadData['fecha_modificacion'],
          'activo': comorbilidadData['activo'] ? 1 : 0,
        }]);

        return comorbilidadData;
      } else if (response.statusCode == 404) {
        throw Exception('Comorbilidad no encontrada');
      } else {
        throw Exception('Error al obtener la comorbilidad');
      }
    } catch (e) {
      print("Error obteniendo comorbilidad por ID: $e");
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
      print("Error cerrando el servicio de comorbilidades: $e");
    }
  }
}
