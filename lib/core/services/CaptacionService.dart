import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/utils/constants.dart';

class CaptacionService {
  final HttpService httpService;
  final StorageService storageService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  CaptacionService({
    required this.httpService,
    required this.storageService,
  }) {
    _initialize();
  }

  // Inicializar base de datos y configuraciones
  Future<void> _initialize() async {
    await database; // Inicializa la base de datos
    await _fetchAndUpdateCaptaciones(); // Sincroniza datos con el backend
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        _fetchAndUpdateCaptaciones();
      }
    });
  }

  // Obtener o inicializar la base de datos SQLite
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos SQLite
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'captacion.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE captacion (
            id_captacion INTEGER PRIMARY KEY,
            id_evento_salud INTEGER NOT NULL,
            id_persona INTEGER NOT NULL,
            id_maternidad INTEGER NOT NULL,
            semana_gestacion INTEGER,
            trabajador_salud INTEGER,
            id_silais_trabajador INTEGER,
            id_establecimiento_trabajador INTEGER,
            tiene_comorbilidades INTEGER,
            id_comorbilidades INTEGER,
            nombre_jefe_familia TEXT,
            telefono_referencia TEXT,
            id_lugar_captacion INTEGER,
            id_condicion_persona INTEGER,
            fecha_captacion TEXT,
            semana_epidemiologica INTEGER,
            id_silais_captacion INTEGER,
            id_establecimiento_captacion INTEGER,
            id_persona_captacion INTEGER,
            id_sitio_exposicion INTEGER,
            latitud_ocurrencia REAL,
            longitud_ocurrencia REAL,
            presenta_sintomas INTEGER,
            fecha_inicio_sintomas TEXT,
            id_sintomas INTEGER,
            fue_referido INTEGER,
            id_silais_traslado INTEGER,
            id_establecimiento_traslado INTEGER,
            es_viajero INTEGER,
            fecha_ingreso_pais TEXT,
            id_lugar_ingreso_pais INTEGER,
            direccion_ocurrencia TEXT,
            observaciones_captacion TEXT,
            id_puesto_notificacion INTEGER,
            no_clave TEXT,
            no_lamina INTEGER,
            toma_muestra INTEGER,
            tipobusqueda INTEGER,
            id_diagnostico INTEGER,
            fecha_toma_muestra TEXT,
            fecha_recepcion_laboratorio TEXT,
            fecha_diagnostico TEXT,
            id_resultado_diagnostico INTEGER,
            densidad_parasitaria_vivax_eas REAL,
            densidad_parasitaria_vivax_ess REAL,
            densidad_parasitaria_falciparum_eas REAL,
            densidad_parasitaria_falciparum_ess REAL,
            id_silais_diagnostico INTEGER,
            id_establecimiento_diagnostico INTEGER,
            existencia_reinfeccion INTEGER,
            evento_salud_extranjero INTEGER,
            id_pais_ocurrencia_evento_salud INTEGER,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER
          )
        ''');
      },
    );
  }

  // Crear una nueva captación
  Future<Map<String, dynamic>> crearCaptacion(Map<String, dynamic> nuevaCaptacion) async {
    final response = await httpService.post(
      '$BASE_URL/v1/catalogo/captacion/create-captacion',
      nuevaCaptacion,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al crear la captación: ${response.statusCode}');
    }
  }

  // Sincronizar captaciones desde el backend
  Future<void> _fetchAndUpdateCaptaciones() async {
    final response = await httpService.get('$BASE_URL/v1/catalogo/captacion/list-captacion');
    if (response.statusCode == 200) {
      List<dynamic> captaciones = jsonDecode(utf8.decode(response.bodyBytes));
      await _insertMultipleCaptaciones(
          captaciones.map((e) => e as Map<String, dynamic>).toList());
    } else {
      throw Exception('Error al sincronizar captaciones: ${response.statusCode}');
    }
  }

  // Insertar múltiples captaciones en la base de datos local
  Future<void> _insertMultipleCaptaciones(List<Map<String, dynamic>> captaciones) async {
    final db = await database;
    final batch = db.batch();
    for (var captacion in captaciones) {
      batch.insert('captacion', captacion, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Obtener captaciones locales
  Future<List<Map<String, dynamic>>> listarCaptacionesLocales() async {
    final db = await database;
    return await db.query('captacion');
  }

  // Cerrar base de datos y cancelar la suscripción
  Future<void> close() async {
    await _database?.close();
    await _connectivitySubscription?.cancel();
  }
}
