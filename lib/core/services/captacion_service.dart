import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class CaptacionService {
  final HttpService httpService;
  static Database? _database;

  CaptacionService({required this.httpService});

  // Inicializar la base de datos SQLite
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'captaciones.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE captaciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idCaptacion TEXT UNIQUE,
            codigoExpediente TEXT,
            cedula TEXT,
            nombreCompleto TEXT,
            municipio TEXT,
            departamento TEXT,
            fechaCaptacion TEXT,
            activo INTEGER,
            establecimientoSalud TEXT
          )
          '''
        );
      },
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Método para buscar captaciones y almacenarlas localmente
  Future<List<Map<String, dynamic>>> buscarCaptaciones({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? idSilais,
    int? idEventoSalud,
    int? idEstablecimiento,
  }) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        // Si hay conexión, obtener datos del backend
        String url = '$BASE_URL$CATALOGOS_CAPTACION/buscar?';

        if (fechaInicio != null) {
          url += 'fechaInicio=${fechaInicio.toIso8601String().substring(0, 10)}&';
        }
        if (fechaFin != null) {
          url += 'fechaFin=${fechaFin.toIso8601String().substring(0, 10)}&';
        }
        if (idSilais != null) {
          url += 'idSilais=$idSilais&';
        }
        if (idEventoSalud != null) {
          url += 'idEventoSalud=$idEventoSalud&';
        }
        if (idEstablecimiento != null) {
          url += 'idEstablecimiento=$idEstablecimiento&';
        }

        if (url.endsWith('&')) {
          url = url.substring(0, url.length - 1);
        }

        final response = await httpService.get(url);
        
        // Decodificar usando bodyBytes para manejar caracteres especiales
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> captaciones = jsonResponse.map((captacion) {
          return {
            'idCaptacion': captacion['idCaptacion'],
            'codigoExpediente': captacion['codigoExpediente'],
            'cedula': captacion['cedula'],
            'nombreCompleto': captacion['nombreCompleto'],
            'municipio': captacion['municipio'],
            'departamento': captacion['departamento'],
            'fechaCaptacion': captacion['fechaCaptacion'],
            'activo': captacion['activo'] == true ? 1 : 0,
            'establecimientoSalud': captacion['establecimientoSalud'],
          };
        }).toList();

        // Guardar captaciones localmente en SQLite
        await _insertMultipleCaptaciones(captaciones);

        return captaciones;
      } else {
        // Si no hay conexión, devolver los datos locales
        return await _getAllCaptaciones();
      }
    } catch (e) {
      print("Error buscando captaciones: $e");
      return await _getAllCaptaciones();
    }
  }

  // Método para insertar múltiples captaciones en la base de datos
  Future<void> _insertMultipleCaptaciones(List<Map<String, dynamic>> captaciones) async {
    final db = await database;
    Batch batch = db.batch();
    for (var captacion in captaciones) {
      // Codificar cadenas a UTF-8 antes de almacenarlas
      final encodedData = {
        'idCaptacion': utf8.encode(captacion['idCaptacion']),
        'codigoExpediente': utf8.encode(captacion['codigoExpediente']),
        'cedula': utf8.encode(captacion['cedula']),
        'nombreCompleto': utf8.encode(captacion['nombreCompleto']),
        'municipio': utf8.encode(captacion['municipio']),
        'departamento': utf8.encode(captacion['departamento']),
        'fechaCaptacion': utf8.encode(captacion['fechaCaptacion']),
        'activo': captacion['activo'],
        'establecimientoSalud': utf8.encode(captacion['establecimientoSalud']),
      };
      batch.insert(
        'captaciones',
        encodedData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Método para obtener todas las captaciones guardadas en la base de datos
  Future<List<Map<String, dynamic>>> _getAllCaptaciones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('captaciones');

    // Decodificar todas las cadenas UTF-8 al recuperar desde SQLite
    return maps.map((map) {
      return {
        'idCaptacion': utf8.decode(map['idCaptacion']),
        'codigoExpediente': utf8.decode(map['codigoExpediente']),
        'cedula': utf8.decode(map['cedula']),
        'nombreCompleto': utf8.decode(map['nombreCompleto']),
        'municipio': utf8.decode(map['municipio']),
        'departamento': utf8.decode(map['departamento']),
        'fechaCaptacion': utf8.decode(map['fechaCaptacion']),
        'activo': map['activo'],
        'establecimientoSalud': utf8.decode(map['establecimientoSalud']),
      };
    }).toList();
  }

  // Método para filtrar captaciones por datos de la persona (conectado o local)
  Future<List<Map<String, dynamic>>> filtrarPorDatosPersona(String filtro) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        // Si hay conexión, obtener datos del backend
        String url = '$BASE_URL$CATALOGOS_CAPTACION/filtrar?filtro=$filtro';
        final response = await httpService.get(url);
        List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> captaciones = jsonResponse.map((captacion) {
          return {
            'idCaptacion': captacion['idCaptacion'],
            'codigoExpediente': captacion['codigoExpediente'],
            'cedula': captacion['cedula'],
            'nombreCompleto': captacion['nombreCompleto'],
            'municipio': captacion['municipio'],
            'departamento': captacion['departamento'],
            'fechaCaptacion': captacion['fechaCaptacion'],
            'activo': captacion['activo'] == true ? 1 : 0,
            'establecimientoSalud': captacion['establecimientoSalud'],
          };
        }).toList();

        // Guardar captaciones localmente en SQLite
        await _insertMultipleCaptaciones(captaciones);

        return captaciones;
      } else {
        // Si no hay conexión, devolver los datos locales que coincidan
        final db = await database;
        return await db.query(
          'captaciones',
          where: 'nombreCompleto LIKE ? OR cedula LIKE ?',
          whereArgs: ['%$filtro%', '%$filtro%'],
        );
      }
    } catch (e) {
      print("Error filtrando captaciones: $e");
      return await _getAllCaptaciones();
    }
  }
}
