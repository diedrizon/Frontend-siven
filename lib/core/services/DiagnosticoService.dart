import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class DiagnosticoService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  DiagnosticoService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateDiagnosticos(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateDiagnosticos();
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
    String path = join(await getDatabasesPath(), 'diagnostico.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Diagnostico
        await db.execute('''
          CREATE TABLE diagnostico (
            id_diagnostico INTEGER PRIMARY KEY,
            nombre TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_diagnostico_id ON diagnostico(id_diagnostico)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // DIAGNOSTICO
  Future<List<Map<String, dynamic>>> _getAllDiagnosticoLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'diagnostico',
        orderBy: 'nombre ASC',
      );
      return maps;
    } catch (e) {
      print("Error obteniendo diagnósticos desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleDiagnostico(List<Map<String, dynamic>> diagnosticosList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var diagnostico in diagnosticosList) {
        batch.insert(
          'diagnostico',
          diagnostico,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando diagnósticos en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getDiagnosticoByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'diagnostico',
        where: 'id_diagnostico = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo diagnóstico por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteDiagnosticoLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'diagnostico',
        where: 'id_diagnostico = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando diagnóstico desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  // Obtener todos los diagnósticos
  Future<List<Map<String, dynamic>>> listarDiagnosticos() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> diagnosticosLocal = await _getAllDiagnosticoLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateDiagnosticos();

    // Retornar los datos locales
    return diagnosticosLocal;
  }

  // Obtener un diagnóstico por ID
  Future<Map<String, dynamic>> obtenerDiagnosticoPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? diagnosticoLocal = await _getDiagnosticoByIdLocal(id);
    if (diagnosticoLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchDiagnosticoById(id);
      return diagnosticoLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchDiagnosticoById(id);
  }

  // Agregar un nuevo diagnóstico
  Future<Map<String, dynamic>> agregarDiagnostico(Map<String, dynamic> nuevoDiagnostico) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-diagnostico';
      final response = await httpService.post(url, nuevoDiagnostico);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoDiagnosticoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleDiagnostico([{
          'id_diagnostico': nuevoDiagnosticoData['id_diagnostico'],
          'nombre': nuevoDiagnosticoData['nombre'],
          'usuario_creacion': nuevoDiagnosticoData['usuario_creacion'],
          'fecha_creacion': nuevoDiagnosticoData['fecha_creacion'],
          'usuario_modificacion': nuevoDiagnosticoData['usuario_modificacion'],
          'fecha_modificacion': nuevoDiagnosticoData['fecha_modificacion'],
          'activo': nuevoDiagnosticoData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevoDiagnosticoData;
      } else {
        throw Exception('Error al agregar el diagnóstico');
      }
    } catch (e) {
      print("Error creando diagnóstico: $e");
      rethrow;
    }
  }

  // Actualizar un diagnóstico existente
  Future<Map<String, dynamic>> actualizarDiagnostico(int idDiagnostico, Map<String, dynamic> diagnosticoActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-diagnostico/$idDiagnostico';
      final response = await httpService.put(url, diagnosticoActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final diagnosticoActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleDiagnostico([{
          'id_diagnostico': diagnosticoActualizadoData['id_diagnostico'],
          'nombre': diagnosticoActualizadoData['nombre'],
          'usuario_creacion': diagnosticoActualizadoData['usuario_creacion'],
          'fecha_creacion': diagnosticoActualizadoData['fecha_creacion'],
          'usuario_modificacion': diagnosticoActualizadoData['usuario_modificacion'],
          'fecha_modificacion': diagnosticoActualizadoData['fecha_modificacion'],
          'activo': diagnosticoActualizadoData['activo'] ? 1 : 0,
        }]);

        return diagnosticoActualizadoData;
      } else {
        throw Exception('Error al actualizar el diagnóstico');
      }
    } catch (e) {
      print("Error actualizando diagnóstico: $e");
      rethrow;
    }
  }

  // Eliminar un diagnóstico
  Future<void> eliminarDiagnostico(int idDiagnostico) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-diagnostico/$idDiagnostico';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteDiagnosticoLocal(idDiagnostico);
      } else {
        throw Exception('Error al eliminar el diagnóstico');
      }
    } catch (e) {
      print("Error eliminando diagnóstico: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateDiagnosticos() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-diagnostico';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> diagnosticosList = jsonResponse.map((diagnostico) {
          return {
            'id_diagnostico': diagnostico['id_diagnostico'],
            'nombre': diagnostico['nombre'],
            'usuario_creacion': diagnostico['usuario_creacion'],
            'fecha_creacion': diagnostico['fecha_creacion'],
            'usuario_modificacion': diagnostico['usuario_modificacion'],
            'fecha_modificacion': diagnostico['fecha_modificacion'],
            'activo': diagnostico['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleDiagnostico(diagnosticosList);
      } else {
        throw Exception('Error al listar diagnósticos');
      }
    } catch (e) {
      print("Error actualizando diagnósticos: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchDiagnosticoById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/diagnostico/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final diagnosticoData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleDiagnostico([{
          'id_diagnostico': diagnosticoData['id_diagnostico'],
          'nombre': diagnosticoData['nombre'],
          'usuario_creacion': diagnosticoData['usuario_creacion'],
          'fecha_creacion': diagnosticoData['fecha_creacion'],
          'usuario_modificacion': diagnosticoData['usuario_modificacion'],
          'fecha_modificacion': diagnosticoData['fecha_modificacion'],
          'activo': diagnosticoData['activo'] ? 1 : 0,
        }]);

        return diagnosticoData;
      } else if (response.statusCode == 404) {
        throw Exception('Diagnóstico no encontrado');
      } else {
        throw Exception('Error al obtener el diagnóstico');
      }
    } catch (e) {
      print("Error obteniendo diagnóstico por ID: $e");
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
      print("Error cerrando el servicio de diagnósticos: $e");
    }
  }
}
