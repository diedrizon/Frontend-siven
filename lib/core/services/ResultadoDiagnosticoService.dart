import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class ResultadoDiagnosticoService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ResultadoDiagnosticoService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateResultadosDiagnostico(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateResultadosDiagnostico();
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
    String path = join(await getDatabasesPath(), 'resultado_diagnostico.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Resultado Diagnostico
        await db.execute('''
          CREATE TABLE resultado_diagnostico (
            id_resultado_diagnostico INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_resultado_diagnostico_id ON resultado_diagnostico(id_resultado_diagnostico)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // RESULTADO DIAGNOSTICO
  Future<List<Map<String, dynamic>>> _getAllResultadosDiagnosticoLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'resultado_diagnostico',
        orderBy: 'nombre ASC',
      );
      return maps;
    } catch (e) {
      print("Error obteniendo resultados de diagnóstico desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleResultadosDiagnostico(List<Map<String, dynamic>> resultadosList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var resultado in resultadosList) {
        batch.insert(
          'resultado_diagnostico',
          resultado,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando resultados de diagnóstico en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getResultadoDiagnosticoByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'resultado_diagnostico',
        where: 'id_resultado_diagnostico = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo resultado de diagnóstico por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteResultadoDiagnosticoLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'resultado_diagnostico',
        where: 'id_resultado_diagnostico = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando resultado de diagnóstico desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los resultados de diagnóstico
  Future<List<Map<String, dynamic>>> listarResultadosDiagnostico() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> resultadosLocal = await _getAllResultadosDiagnosticoLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateResultadosDiagnostico();

    // Retornar los datos locales
    return resultadosLocal;
  }

  // Obtener un resultado de diagnóstico por ID
  Future<Map<String, dynamic>> obtenerResultadoDiagnosticoPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? resultadoLocal = await _getResultadoDiagnosticoByIdLocal(id);
    if (resultadoLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchResultadoDiagnosticoById(id);
      return resultadoLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchResultadoDiagnosticoById(id);
  }

  // Agregar un nuevo resultado de diagnóstico
  Future<Map<String, dynamic>> agregarResultadoDiagnostico(Map<String, dynamic> nuevoResultado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-resultados-diagnostico';
      final response = await httpService.post(url, nuevoResultado);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoResultadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleResultadosDiagnostico([{
          'id_resultado_diagnostico': nuevoResultadoData['id_resultado_diagnostico'],
          'nombre': nuevoResultadoData['nombre'],
          'usuario_creacion': nuevoResultadoData['usuario_creacion'],
          'fecha_creacion': nuevoResultadoData['fecha_creacion'],
          'usuario_modificacion': nuevoResultadoData['usuario_modificacion'],
          'fecha_modificacion': nuevoResultadoData['fecha_modificacion'],
          'activo': nuevoResultadoData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevoResultadoData;
      } else {
        throw Exception('Error al agregar el resultado de diagnóstico');
      }
    } catch (e) {
      print("Error creando resultado de diagnóstico: $e");
      rethrow;
    }
  }

  // Actualizar un resultado de diagnóstico existente
  Future<Map<String, dynamic>> actualizarResultadoDiagnostico(int idResultado, Map<String, dynamic> resultadoActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-resultados-diagnostico/$idResultado';
      final response = await httpService.put(url, resultadoActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final resultadoActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleResultadosDiagnostico([{
          'id_resultado_diagnostico': resultadoActualizadoData['id_resultado_diagnostico'],
          'nombre': resultadoActualizadoData['nombre'],
          'usuario_creacion': resultadoActualizadoData['usuario_creacion'],
          'fecha_creacion': resultadoActualizadoData['fecha_creacion'],
          'usuario_modificacion': resultadoActualizadoData['usuario_modificacion'],
          'fecha_modificacion': resultadoActualizadoData['fecha_modificacion'],
          'activo': resultadoActualizadoData['activo'] ? 1 : 0,
        }]);

        return resultadoActualizadoData;
      } else {
        throw Exception('Error al actualizar el resultado de diagnóstico');
      }
    } catch (e) {
      print("Error actualizando resultado de diagnóstico: $e");
      rethrow;
    }
  }

  // Eliminar un resultado de diagnóstico
  Future<void> eliminarResultadoDiagnostico(int idResultado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-resultados-diagnostico/$idResultado';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteResultadoDiagnosticoLocal(idResultado);
      } else {
        throw Exception('Error al eliminar el resultado de diagnóstico');
      }
    } catch (e) {
      print("Error eliminando resultado de diagnóstico: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateResultadosDiagnostico() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-resultados-diagnostico';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> resultadosList = jsonResponse.map((resultado) {
          return {
            'id_resultado_diagnostico': resultado['id_resultado_diagnostico'],
            'nombre': resultado['nombre'],
            'usuario_creacion': resultado['usuario_creacion'],
            'fecha_creacion': resultado['fecha_creacion'],
            'usuario_modificacion': resultado['usuario_modificacion'],
            'fecha_modificacion': resultado['fecha_modificacion'],
            'activo': resultado['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleResultadosDiagnostico(resultadosList);
      } else {
        throw Exception('Error al listar resultados de diagnóstico');
      }
    } catch (e) {
      print("Error actualizando resultados de diagnóstico: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchResultadoDiagnosticoById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/resultados-diagnostico/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final resultadoData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleResultadosDiagnostico([{
          'id_resultado_diagnostico': resultadoData['id_resultado_diagnostico'],
          'nombre': resultadoData['nombre'],
          'usuario_creacion': resultadoData['usuario_creacion'],
          'fecha_creacion': resultadoData['fecha_creacion'],
          'usuario_modificacion': resultadoData['usuario_modificacion'],
          'fecha_modificacion': resultadoData['fecha_modificacion'],
          'activo': resultadoData['activo'] ? 1 : 0,
        }]);

        return resultadoData;
      } else if (response.statusCode == 404) {
        throw Exception('Resultado de diagnóstico no encontrado');
      } else {
        throw Exception('Error al obtener el resultado de diagnóstico');
      }
    } catch (e) {
      print("Error obteniendo resultado de diagnóstico por ID: $e");
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
      print("Error cerrando el servicio de resultados de diagnóstico: $e");
    }
  }
}
