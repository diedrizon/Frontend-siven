import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class PersonaService {
  final HttpService httpService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  PersonaService({required this.httpService}) {
    _initialize();
  }

  // Inicializar la base de datos y configurar escuchas de conectividad
  Future<void> _initialize() async {
    await database;
    await _fetchAndUpdatePersonas(); // Intentar actualizar al iniciar

    // Escuchar cambios en la conectividad para actualizar datos en segundo plano
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        _fetchAndUpdatePersonas();
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
    String path = join(await getDatabasesPath(), 'personas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla para Personas
        await db.execute('''
          CREATE TABLE personas (
            id_persona INTEGER PRIMARY KEY,
            codigo_expediente TEXT,
            cedula TEXT,
            primer_nombre TEXT,
            segundo_nombre TEXT,
            primer_apellido TEXT,
            segundo_apellido TEXT,
            fecha_nacimiento TEXT,
            sexo TEXT,
            grupo_etnico TEXT,
            ocupacion TEXT,
            email TEXT,
            escolaridad TEXT,
            estado_civil TEXT,
            telefono TEXT,
            tipo_telefono TEXT,
            pais_telefono TEXT,
            departamento TEXT,
            municipio TEXT,
            direccion_domicilio TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_personas_id ON personas(id_persona)');
        await db.execute('CREATE INDEX idx_personas_cedula ON personas(cedula)');
        await db.execute('CREATE INDEX idx_personas_codigo_expediente ON personas(codigo_expediente)');
      },
    );
  }

  // Métodos de ayuda para interactuar con SQLite

  // PERSONAS
  Future<List<Map<String, dynamic>>> _getAllPersonasLocal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('personas', orderBy: 'primer_nombre ASC');
      return maps;
    } catch (e) {
      print("Error obteniendo personas desde local: $e");
      return [];
    }
  }

  Future<void> _insertMultiplePersonas(List<Map<String, dynamic>> personasList) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var persona in personasList) {
        batch.insert(
          'personas',
          persona,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error insertando personas en local: $e");
    }
  }

  Future<Map<String, dynamic>?> _getPersonaByIdLocal(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'personas',
        where: 'id_persona = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      print("Error obteniendo persona por ID desde local: $e");
      return null;
    }
  }

  Future<void> _deletePersonaLocal(int id) async {
    try {
      final db = await database;
      await db.delete(
        'personas',
        where: 'id_persona = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error eliminando persona desde local: $e");
    }
  }

  // Métodos Públicos sin modificar la interfaz

  /// Listar todas las personas
  Future<List<Map<String, dynamic>>> listarPersonas() async {
    // Primero, obtener desde local
    List<Map<String, dynamic>> personasLocal = await _getAllPersonasLocal();

    // Luego, en segundo plano, actualizar desde la red
    _fetchAndUpdatePersonas();

    // Retornar los datos locales
    return personasLocal;
  }

  /// Buscar personas por nombre o apellido
  Future<List<Map<String, dynamic>>> buscarPersonasPorNombreOApellido(String busqueda) async {
    List<Map<String, dynamic>> personas = await _getAllPersonasLocal();
    final busquedaLower = busqueda.toLowerCase();

    return personas.where((persona) {
      final primerNombre = persona['primer_nombre']?.toString().toLowerCase() ?? '';
      final segundoNombre = persona['segundo_nombre']?.toString().toLowerCase() ?? '';
      final primerApellido = persona['primer_apellido']?.toString().toLowerCase() ?? '';
      final segundoApellido = persona['segundo_apellido']?.toString().toLowerCase() ?? '';

      return primerNombre.contains(busquedaLower) ||
             segundoNombre.contains(busquedaLower) ||
             primerApellido.contains(busquedaLower) ||
             segundoApellido.contains(busquedaLower);
    }).toList();
  }

  /// Buscar personas por cédula o código de expediente
Future<List<Map<String, dynamic>>> buscarPersonasPorCedulaOExpediente(String busqueda) async {
  List<Map<String, dynamic>> personas = await _getAllPersonasLocal();
  final busquedaLower = busqueda.toLowerCase();

  return personas.where((persona) {
    final cedula = persona['cedula']?.toString().toLowerCase() ?? '';
    final codigoExpediente = persona['codigo_expediente']?.toString().toLowerCase() ?? '';

    return cedula.contains(busquedaLower) || codigoExpediente.contains(busquedaLower);
  }).toList();
}


  // Métodos internos para actualizar el caché desde la red

  /// Fetch y actualizar el caché local de personas desde la red
  Future<void> _fetchAndUpdatePersonas() async {
    try {
      String url = '$BASE_URL/v1/catalogo/persona/list-personas';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        // Decodificación UTF-8 para manejar caracteres especiales
        final decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> jsonResponse = jsonDecode(decodedResponse);

        List<Map<String, dynamic>> personasList = jsonResponse.map((persona) {
          return {
            'id_persona': persona['id_persona'],
            'codigo_expediente': persona['codigo_expediente'],
            'cedula': persona['cedula'],
            'primer_nombre': persona['primer_nombre'],
            'segundo_nombre': persona['segundo_nombre'],
            'primer_apellido': persona['primer_apellido'],
            'segundo_apellido': persona['segundo_apellido'],
            'fecha_nacimiento': persona['fecha_nacimiento'],
            'sexo': persona['sexo'],
            'grupo_etnico': persona['grupo_etnico'],
            'ocupacion': persona['ocupacion'],
            'email': persona['email'],
            'escolaridad': persona['escolaridad'],
            'estado_civil': persona['estado_civil'],
            'telefono': persona['telefono'],
            'tipo_telefono': persona['tipo_telefono'],
            'pais_telefono': persona['pais_telefono'],
            'departamento': persona['departamento'],
            'municipio': persona['municipio'],
            'direccion_domicilio': persona['direccion_domicilio'],
            'usuario_creacion': persona['usuario_creacion'],
            'fecha_creacion': persona['fecha_creacion'],
            'usuario_modificacion': persona['usuario_modificacion'],
            'fecha_modificacion': persona['fecha_modificacion'],
            'activo': persona['activo'] ? 1 : 0, // SQLite no soporta booleanos
          };
        }).toList();

        // Insertar en local
        await _insertMultiplePersonas(personasList);
      } else {
        throw Exception('Error al listar personas');
      }
    } catch (e) {
      print("Error actualizando personas: $e");
      // No lanzar excepción para no interrumpir la UI
    }
  }

  /// Fetch una persona por ID desde la red y actualizar el caché local
  Future<Map<String, dynamic>> _fetchPersonaById(int id) async {
    try {
      String url = '$BASE_URL/v1/catalogo/persona/persona/$id';
      final response = await httpService.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final personaData = jsonDecode(decodedResponse) as Map<String, dynamic>;

        // Insertar en local
        await _insertMultiplePersonas([{
          'id_persona': personaData['id_persona'],
          'codigo_expediente': personaData['codigo_expediente'],
          'cedula': personaData['cedula'],
          'primer_nombre': personaData['primer_nombre'],
          'segundo_nombre': personaData['segundo_nombre'],
          'primer_apellido': personaData['primer_apellido'],
          'segundo_apellido': personaData['segundo_apellido'],
          'fecha_nacimiento': personaData['fecha_nacimiento'],
          'sexo': personaData['sexo'],
          'grupo_etnico': personaData['grupo_etnico'],
          'ocupacion': personaData['ocupacion'],
          'email': personaData['email'],
          'escolaridad': personaData['escolaridad'],
          'estado_civil': personaData['estado_civil'],
          'telefono': personaData['telefono'],
          'tipo_telefono': personaData['tipo_telefono'],
          'pais_telefono': personaData['pais_telefono'],
          'departamento': personaData['departamento'],
          'municipio': personaData['municipio'],
          'direccion_domicilio': personaData['direccion_domicilio'],
          'usuario_creacion': personaData['usuario_creacion'],
          'fecha_creacion': personaData['fecha_creacion'],
          'usuario_modificacion': personaData['usuario_modificacion'],
          'fecha_modificacion': personaData['fecha_modificacion'],
          'activo': personaData['activo'] ? 1 : 0,
        }]);

        return personaData;
      } else if (response.statusCode == 404) {
        throw Exception('Persona no encontrada');
      } else {
        throw Exception('Error al obtener la persona');
      }
    } catch (e) {
      print("Error obteniendo persona por ID: $e");
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
      print("Error cerrando el servicio de personas: $e");
    }
  }
}
