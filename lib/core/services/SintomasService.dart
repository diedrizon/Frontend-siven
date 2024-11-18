import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class SintomasService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SintomasService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdateSintomas(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdateSintomas();
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
    String path = join(await getDatabasesPath(), 'sintomas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Síntomas
        await db.execute('''
          CREATE TABLE sintomas (
            id_sintomas INTEGER PRIMARY KEY,
            nombre TEXT,
            id_evento_salud INTEGER,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_sintomas_id ON sintomas(id_sintomas)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // SÍNTOMAS
  Future<List<Map<String, dynamic>>> _getAllSintomasLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('sintomas', orderBy: 'nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo síntomas desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultipleSintomas(List<Map<String, dynamic>> sintomasList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var sintoma in sintomasList) {
        batch.insert(
          'sintomas',
          sintoma,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando síntomas en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getSintomaByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sintomas',
        where: 'id_sintomas = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo síntoma por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deleteSintomaLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'sintomas',
        where: 'id_sintomas = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando síntoma desde local: $e");
    }
  }

  // Métodos Públicos

  // Obtener todos los síntomas
  Future<List<Map<String, dynamic>>> listarSintomas() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> sintomasLocal = await _getAllSintomasLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdateSintomas();

    // Retornar los datos locales
    return sintomasLocal;
  }

  // Obtener un síntoma por ID
  Future<Map<String, dynamic>> obtenerSintomaPorId(int id) async {
    // Primero, intentar obtener desde local
    Map<String, dynamic>? sintomaLocal = await _getSintomaByIdLocal(id);
    if (sintomaLocal != null) {
      // En segundo plano, actualizar desde la red
      _fetchSintomaById(id);
      return sintomaLocal;
    }

    // Si no está en local, obtener desde la red
    return await _fetchSintomaById(id);
  }

  // Agregar un nuevo síntoma
  Future<Map<String, dynamic>> agregarSintoma(Map<String, dynamic> nuevoSintoma) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/create-sintomas';
      final response = await httpService.post(url, nuevoSintoma);

      if (response.statusCode == 201 || response.statusCode == 200) { // Asegúrate de que el servidor responda con 200 o 201
        final decodedResponse = utf8.decode(response.bodyBytes);
        final nuevoSintomaData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleSintomas([{
          'id_sintomas': nuevoSintomaData['id_sintomas'],
          'nombre': nuevoSintomaData['nombre'],
          'id_evento_salud': nuevoSintomaData['id_evento_salud'],
          'usuario_creacion': nuevoSintomaData['usuario_creacion'],
          'fecha_creacion': nuevoSintomaData['fecha_creacion'],
          'usuario_modificacion': nuevoSintomaData['usuario_modificacion'],
          'fecha_modificacion': nuevoSintomaData['fecha_modificacion'],
          'activo': nuevoSintomaData['activo'] ? 1 : 0, // SQLite no soporta booleanos
        }]);

        return nuevoSintomaData;
      } else {
        throw Exception('Error al agregar el síntoma');
      }
    } catch (e) {
      print("Error creando síntoma: $e");
      rethrow;
    }
  }

  // Actualizar un síntoma existente
  Future<Map<String, dynamic>> actualizarSintoma(int idSintoma, Map<String, dynamic> sintomaActualizado) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/update-sintomas/$idSintoma';
      final response = await httpService.put(url, sintomaActualizado);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final sintomaActualizadoData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Actualizar en local
        await _insertMultipleSintomas([{
          'id_sintomas': sintomaActualizadoData['id_sintomas'],
          'nombre': sintomaActualizadoData['nombre'],
          'id_evento_salud': sintomaActualizadoData['id_evento_salud'],
          'usuario_creacion': sintomaActualizadoData['usuario_creacion'],
          'fecha_creacion': sintomaActualizadoData['fecha_creacion'],
          'usuario_modificacion': sintomaActualizadoData['usuario_modificacion'],
          'fecha_modificacion': sintomaActualizadoData['fecha_modificacion'],
          'activo': sintomaActualizadoData['activo'] ? 1 : 0,
        }]);

        return sintomaActualizadoData;
      } else {
        throw Exception('Error al actualizar el síntoma');
      }
    } catch (e) {
      print("Error actualizando síntoma: $e");
      rethrow;
    }
  }

  // Eliminar un síntoma
  Future<void> eliminarSintoma(int idSintoma) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/delete-sintomas/$idSintoma';
      final response = await httpService.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) { // Asumiendo 200 o 204
        // Eliminar de local
        await _deleteSintomaLocal(idSintoma);
      } else {
        throw Exception('Error al eliminar el síntoma');
      }
    } catch (e) {
      print("Error eliminando síntoma: $e");
      rethrow;
    }
  }

  // Métodos internos para actualizar el caché desde la red

  Future<void> _fetchAndUpdateSintomas() async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/list-sintomas';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> sintomasList = jsonResponse.map((sintoma) {
          return {
            'id_sintomas': sintoma['id_sintomas'],
            'nombre': sintoma['nombre'],
            'id_evento_salud': sintoma['id_evento_salud'],
            'usuario_creacion': sintoma['usuario_creacion'],
            'fecha_creacion': sintoma['fecha_creacion'],
            'usuario_modificacion': sintoma['usuario_modificacion'],
            'fecha_modificacion': sintoma['fecha_modificacion'],
            'activo': sintoma['activo'] ? 1 : 0,
          };
        }).toList();

        // Insertar en local
        await _insertMultipleSintomas(sintomasList);
      } else {
        throw Exception('Error al listar síntomas');
      }
    } catch (e) {
      print("Error actualizando síntomas: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  Future<Map<String, dynamic>> _fetchSintomaById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/captacion/sintomas/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final sintomaData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultipleSintomas([{
          'id_sintomas': sintomaData['id_sintomas'],
          'nombre': sintomaData['nombre'],
          'id_evento_salud': sintomaData['id_evento_salud'],
          'usuario_creacion': sintomaData['usuario_creacion'],
          'fecha_creacion': sintomaData['fecha_creacion'],
          'usuario_modificacion': sintomaData['usuario_modificacion'],
          'fecha_modificacion': sintomaData['fecha_modificacion'],
          'activo': sintomaData['activo'] ? 1 : 0,
        }]);

        return sintomaData;
      } else if (response.statusCode == 404) {
        throw Exception('Síntoma no encontrado');
      } else {
        throw Exception('Error al obtener el síntoma');
      }
    } catch (e) {
      print("Error obteniendo síntoma por ID: $e");
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
      print("Error cerrando el servicio de síntomas: $e");
    }
  }
}
