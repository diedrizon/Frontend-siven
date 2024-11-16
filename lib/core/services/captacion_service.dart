// captacion_service.dart

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
      version: 2, // Incrementamos la versión para aplicar los cambios
      onCreate: (db, version) async {
        await db.execute('''
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
            establecimientoSalud TEXT,
            sexo TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Agregamos la columna 'sexo' si no existe
          await db.execute('ALTER TABLE captaciones ADD COLUMN sexo TEXT');
        }
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

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        // Construcción de URL con parámetros
        String url = '$BASE_URL$CATALOGOS_CAPTACION/buscar?';

        if (fechaInicio != null) {
          url +=
              'fechaInicio=${fechaInicio.toIso8601String().substring(0, 10)}&';
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

        // Quitar '&' al final si existe
        if (url.endsWith('&')) {
          url = url.substring(0, url.length - 1);
        }

        // Realizar la solicitud HTTP
        final response = await httpService.get(url);

        // Verificar si la respuesta es exitosa
        if (response.statusCode == 200) {
          // Decodificación UTF-8
          final decodedResponse = utf8.decode(response.bodyBytes);
          List<dynamic> jsonResponse = jsonDecode(decodedResponse);

          List<Map<String, dynamic>> captaciones = jsonResponse.map((captacion) {
            return {
              'idCaptacion': captacion['idCaptacion'],
              'codigoExpediente': captacion['codigoExpediente'],
              'cedula': captacion['cedula'],
              'nombreCompleto': captacion['nombreCompleto'],
              'municipio': captacion['municipio'],
              'departamento': captacion['departamento'],
              'fechaCaptacion': captacion['fechaCaptacion'],
              'activo': captacion['activo'] == true || captacion['activo'] == 1 ? 1 : 0,
              'establecimientoSalud': captacion['establecimientoSalud'],
              'sexo': captacion['sexo'], // Incluimos el campo 'sexo'
            };
          }).toList();

          // Guardar captaciones localmente en SQLite
          await _insertMultipleCaptaciones(captaciones);

          return captaciones;
        } else {
          throw Exception('Error al obtener captaciones: ${response.statusCode}');
        }
      } else {
        // Si no hay conexión, devolver los datos locales filtrados
        return await _getCaptacionesFromLocalDB(
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          idSilais: idSilais,
          idEventoSalud: idEventoSalud,
          idEstablecimiento: idEstablecimiento,
        );
      }
    } catch (e) {
      print("Error buscando captaciones: $e");
      return await _getAllCaptaciones();
    }
  }

  // Método para analizar captaciones llamando al endpoint "/analisis"
  Future<Map<String, dynamic>> analizarCaptaciones({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? idSilais,
    int? idEventoSalud,
    int? idEstablecimiento,
  }) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        // Construcción de URL con parámetros para el análisis
        String url = '$BASE_URL$CATALOGOS_CAPTACION/analisis?';

        if (fechaInicio != null) {
          url +=
              'fechaInicio=${fechaInicio.toIso8601String().substring(0, 10)}&';
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

        // Quitar '&' al final si existe
        if (url.endsWith('&')) {
          url = url.substring(0, url.length - 1);
        }

        // Realizar la solicitud HTTP al backend
        final response = await httpService.get(url);

        // Verificar si la respuesta es exitosa
        if (response.statusCode == 200) {
          // Decodificación UTF-8 para leer la respuesta
          final decodedResponse = utf8.decode(response.bodyBytes);
          Map<String, dynamic> jsonResponse = jsonDecode(decodedResponse);

          // Retornar la respuesta tal cual
          return jsonResponse;
        } else {
          throw Exception('Error al obtener análisis: ${response.statusCode}');
        }
      } else {
        // Si no hay conexión, realizar el análisis localmente
        return await _analizarCaptacionesLocalmente(
          fechaInicio: fechaInicio,
          fechaFin: fechaFin,
          idSilais: idSilais,
          idEventoSalud: idEventoSalud,
          idEstablecimiento: idEstablecimiento,
        );
      }
    } catch (e) {
      print("Error al analizar captaciones: $e");
      return {}; // Devuelve un mapa vacío en caso de error
    }
  }

  // Método para insertar múltiples captaciones en la base de datos
  Future<void> _insertMultipleCaptaciones(
      List<Map<String, dynamic>> captaciones) async {
    final db = await database;
    Batch batch = db.batch();
    for (var captacion in captaciones) {
      batch.insert(
        'captaciones',
        captacion,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Método para obtener todas las captaciones guardadas en la base de datos
  Future<List<Map<String, dynamic>>> _getAllCaptaciones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('captaciones');
    return maps;
  }

  // Método para obtener captaciones de la base de datos local con filtros
  Future<List<Map<String, dynamic>>> _getCaptacionesFromLocalDB({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? idSilais,
    int? idEventoSalud,
    int? idEstablecimiento,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (fechaInicio != null) {
      whereClause += 'fechaCaptacion >= ?';
      whereArgs.add(fechaInicio.toIso8601String());
    }

    if (fechaFin != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'fechaCaptacion <= ?';
      whereArgs.add(fechaFin.toIso8601String());
    }

    // Si necesitas filtrar por idSilais, idEventoSalud, idEstablecimiento, asegúrate de tener estos campos almacenados en SQLite

    final List<Map<String, dynamic>> maps = await db.query(
      'captaciones',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return maps;
  }

  // Método para analizar captaciones localmente en caso de no tener conexión
  Future<Map<String, dynamic>> _analizarCaptacionesLocalmente({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? idSilais,
    int? idEventoSalud,
    int? idEstablecimiento,
  }) async {
    final captaciones = await _getCaptacionesFromLocalDB(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      idSilais: idSilais,
      idEventoSalud: idEventoSalud,
      idEstablecimiento: idEstablecimiento,
    );

    int casosRegistrados = captaciones.length;
    int casosActivos = captaciones.where((c) => c['activo'] == 1).length;
    int casosFinalizados = casosRegistrados - casosActivos;

    // Distribución por género
    Map<String, int> distribucionGenero = {};
    for (var captacion in captaciones) {
      String genero = captacion['sexo'] ?? 'Desconocido';
      if (distribucionGenero.containsKey(genero)) {
        distribucionGenero[genero] = distribucionGenero[genero]! + 1;
      } else {
        distribucionGenero[genero] = 1;
      }
    }

    // Distribución por localidad
    Map<String, int> distribucionLocalidad = {};
    for (var captacion in captaciones) {
      String localidad = captacion['municipio'] ?? 'Desconocido';
      if (distribucionLocalidad.containsKey(localidad)) {
        distribucionLocalidad[localidad] = distribucionLocalidad[localidad]! + 1;
      } else {
        distribucionLocalidad[localidad] = 1;
      }
    }

    // Máximos de incidencia por fecha
    Map<String, int> maximosIncidencia = {};
    for (var captacion in captaciones) {
      String fecha = captacion['fechaCaptacion']?.substring(0, 10) ?? 'Desconocido';
      if (maximosIncidencia.containsKey(fecha)) {
        maximosIncidencia[fecha] = maximosIncidencia[fecha]! + 1;
      } else {
        maximosIncidencia[fecha] = 1;
      }
    }

    return {
      'casosRegistrados': casosRegistrados,
      'casosActivos': casosActivos,
      'casosFinalizados': casosFinalizados,
      'distribucionGenero': distribucionGenero,
      'distribucionLocalidad': distribucionLocalidad,
      'maximosIncidencia': maximosIncidencia,
    };
  }

  // Método para filtrar captaciones por datos de la persona (conectado o local)
  Future<List<Map<String, dynamic>>> filtrarPorDatosPersona(
      String filtro) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        // Realizar búsqueda en el backend
        String url = '$BASE_URL$CATALOGOS_CAPTACION/filtrar?filtro=$filtro';
        final response = await httpService.get(url);

        // Verificar si la respuesta es exitosa
        if (response.statusCode == 200) {
          // Decodificación UTF-8
          final decodedResponse = utf8.decode(response.bodyBytes);
          List<dynamic> jsonResponse = jsonDecode(decodedResponse);

          List<Map<String, dynamic>> captaciones = jsonResponse.map((captacion) {
            return {
              'idCaptacion': captacion['idCaptacion'],
              'codigoExpediente': captacion['codigoExpediente'],
              'cedula': captacion['cedula'],
              'nombreCompleto': captacion['nombreCompleto'],
              'municipio': captacion['municipio'],
              'departamento': captacion['departamento'],
              'fechaCaptacion': captacion['fechaCaptacion'],
              'activo': captacion['activo'] == true || captacion['activo'] == 1 ? 1 : 0,
              'establecimientoSalud': captacion['establecimientoSalud'],
              'sexo': captacion['sexo'], // Incluimos el campo 'sexo'
            };
          }).toList();

          // Guardar captaciones localmente en SQLite
          await _insertMultipleCaptaciones(captaciones);

          return captaciones;
        } else {
          throw Exception('Error al filtrar captaciones: ${response.statusCode}');
        }
      } else {
        // Si no hay conexión, realizar búsqueda local
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
