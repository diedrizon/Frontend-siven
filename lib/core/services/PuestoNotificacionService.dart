import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siven_app/core/utils/constants.dart';

class PuestoNotificacionService {
  final HttpService httpService;
  final StorageService storageService;
  static Database? _database;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  PuestoNotificacionService({
    required this.httpService,
    required this.storageService,
  }) {
    _initialize();
  }

  // Inicializar base de datos y configuraciones
  Future<void> _initialize() async {
    await database; // Inicializa la base de datos
    await _fetchAndUpdatePuestosNotificacion(); // Sincroniza datos con el backend
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        _fetchAndUpdatePuestosNotificacion();
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
    String path = join(await getDatabasesPath(), 'puesto_notificacion.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE puesto_notificacion (
            id_puesto_notificacion INTEGER PRIMARY KEY,
            nombre TEXT,
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

  // Crear un nuevo puesto de notificación
  Future<Map<String, dynamic>> crearPuestoNotificacion(Map<String, dynamic> nuevoPuesto) async {
    final response = await httpService.post(
      '$BASE_URL/v1/catalogo/captacion/create-puesto-notificacion',
      nuevoPuesto,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al crear el puesto de notificación: ${response.statusCode}');
    }
  }

  // Sincronizar puestos de notificación desde el backend
  Future<void> _fetchAndUpdatePuestosNotificacion() async {
    final response = await httpService.get('$BASE_URL/v1/catalogo/captacion/list-puesto-notificacion');
    if (response.statusCode == 200) {
      List<dynamic> puestos = jsonDecode(utf8.decode(response.bodyBytes));
      await _insertMultiplePuestosNotificacion(
          puestos.map((e) => e as Map<String, dynamic>).toList());
    } else {
      throw Exception('Error al sincronizar puestos de notificación: ${response.statusCode}');
    }
  }

  // Insertar múltiples puestos de notificación en la base de datos local
  Future<void> _insertMultiplePuestosNotificacion(List<Map<String, dynamic>> puestos) async {
    final db = await database;
    final batch = db.batch();
    for (var puesto in puestos) {
      batch.insert('puesto_notificacion', puesto, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Obtener puestos de notificación locales
  Future<List<Map<String, dynamic>>> listarPuestosNotificacionLocales() async {
    final db = await database;
    return await db.query('puesto_notificacion');
  }

  // Cerrar base de datos y cancelar la suscripción
  Future<void> close() async {
    await _database?.close();
    await _connectivitySubscription?.cancel();
  }
}
