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
            id_captacion TEXT UNIQUE,
            id_evento_salud TEXT,
            id_persona TEXT,
            id_maternidad TEXT,
            semana_gestacion TEXT,
            trabajador_salud TEXT,
            id_silais_trabajador TEXT,
            id_establecimiento_trabajador TEXT,
            tiene_comorbilidades INTEGER,
            id_comorbilidades TEXT,
            nombre_jefe_familia TEXT,
            telefono_referencia TEXT,
            id_lugar_captacion TEXT,
            id_condicion_persona TEXT,
            fecha_captacion TEXT,
            semana_epidemiologica TEXT,
            id_silais_captacion TEXT,
            id_establecimiento_captacion TEXT,
            id_persona_captacion TEXT,
            id_sitio_exposicion TEXT,
            latitud_ocurrencia TEXT,
            longitud_ocurrencia TEXT,
            presenta_sintomas INTEGER,
            fecha_inicio_sintomas TEXT,
            id_sintomas TEXT,
            fue_referido INTEGER,
            id_silais_traslado TEXT,
            id_establecimiento_traslado TEXT,
            es_viajero INTEGER,
            fecha_ingreso_pais TEXT,
            id_lugar_ingreso_pais TEXT,
            direccion_ocurrencia TEXT,
            observaciones_captacion TEXT,
            id_puesto_notificacion TEXT,
            no_clave TEXT,
            no_lamina TEXT,
            toma_muestra INTEGER,
            tipobusqueda TEXT,
            id_diagnostico TEXT,
            fecha_toma_muestra TEXT,
            fecha_recepcion_laboratorio TEXT,
            fecha_diagnostico TEXT,
            id_resultado_diagnostico TEXT,
            densidad_parasitaria_vivax_eas TEXT,
            densidad_parasitaria_vivax_ess TEXT,
            densidad_parasitaria_falciparum_eas TEXT,
            densidad_parasitaria_falciparum_ess TEXT,
            id_silais_diagnostico TEXT,
            id_establecimiento_diagnostico TEXT,
            existencia_reinfeccion INTEGER,
            evento_salud_extranjero INTEGER,
            id_pais_ocurrencia_evento_salud TEXT,
            usuario_creacion TEXT,
            fecha_creacion TEXT,
            usuario_modificacion TEXT,
            fecha_modificacion TEXT,
            activo INTEGER,
            data TEXT
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

  // Método para listar captaciones y guardarlas localmente si hay conexión
  Future<List<Map<String, dynamic>>> listarCaptaciones() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        String url = '$BASE_URL/v1/catalogo/captacion/list-captaciones';
        final response = await httpService.get(url);

        if (response.statusCode == 200) {
          // Decodificación asegurada en UTF-8
          final decodedResponse = utf8.decode(response.bodyBytes);
          List<dynamic> jsonResponse = jsonDecode(decodedResponse);

          List<Map<String, dynamic>> captaciones = jsonResponse.map((captacion) {
            return {
              'id_captacion': captacion['id_captacion'] ?? '',
              'id_evento_salud': captacion['id_evento_salud'] ?? '',
              'id_persona': captacion['id_persona'] ?? '',
              'id_maternidad': captacion['id_maternidad'] ?? '',
              'semana_gestacion': captacion['semana_gestacion'] ?? '',
              'trabajador_salud': captacion['trabajador_salud'] ?? '',
              'id_silais_trabajador': captacion['id_silais_trabajador'] ?? '',
              'id_establecimiento_trabajador': captacion['id_establecimiento_trabajador'] ?? '',
              'tiene_comorbilidades': captacion['tiene_comorbilidades'] == true ? 1 : 0,
              'id_comorbilidades': captacion['id_comorbilidades'] ?? '',
              'nombre_jefe_familia': captacion['nombre_jefe_familia'] ?? '',
              'telefono_referencia': captacion['telefono_referencia'] ?? '',
              'id_lugar_captacion': captacion['id_lugar_captacion'] ?? '',
              'id_condicion_persona': captacion['id_condicion_persona'] ?? '',
              'fecha_captacion': captacion['fecha_captacion'] ?? '',
              'semana_epidemiologica': captacion['semana_epidemiologica'] ?? '',
              'id_silais_captacion': captacion['id_silais_captacion'] ?? '',
              'id_establecimiento_captacion': captacion['id_establecimiento_captacion'] ?? '',
              'id_persona_captacion': captacion['id_persona_captacion'] ?? '',
              'id_sitio_exposicion': captacion['id_sitio_exposicion'] ?? '',
              'latitud_ocurrencia': captacion['latitud_ocurrencia'] ?? '',
              'longitud_ocurrencia': captacion['longitud_ocurrencia'] ?? '',
              'presenta_sintomas': captacion['presenta_sintomas'] == true ? 1 : 0,
              'fecha_inicio_sintomas': captacion['fecha_inicio_sintomas'] ?? '',
              'id_sintomas': captacion['id_sintomas'] ?? '',
              'fue_referido': captacion['fue_referido'] == true ? 1 : 0,
              'id_silais_traslado': captacion['id_silais_traslado'] ?? '',
              'id_establecimiento_traslado': captacion['id_establecimiento_traslado'] ?? '',
              'es_viajero': captacion['es_viajero'] == true ? 1 : 0,
              'fecha_ingreso_pais': captacion['fecha_ingreso_pais'] ?? '',
              'id_lugar_ingreso_pais': captacion['id_lugar_ingreso_pais'] ?? '',
              'direccion_ocurrencia': captacion['direccion_ocurrencia'] ?? '',
              'observaciones_captacion': captacion['observaciones_captacion'] ?? '',
              'id_puesto_notificacion': captacion['id_puesto_notificacion'] ?? '',
              'no_clave': captacion['no_clave'] ?? '',
              'no_lamina': captacion['no_lamina'] ?? '',
              'toma_muestra': captacion['toma_muestra'] == true ? 1 : 0,
              'tipobusqueda': captacion['tipobusqueda'] ?? '',
              'id_diagnostico': captacion['id_diagnostico'] ?? '',
              'fecha_toma_muestra': captacion['fecha_toma_muestra'] ?? '',
              'fecha_recepcion_laboratorio': captacion['fecha_recepcion_laboratorio'] ?? '',
              'fecha_diagnostico': captacion['fecha_diagnostico'] ?? '',
              'id_resultado_diagnostico': captacion['id_resultado_diagnostico'] ?? '',
              'densidad_parasitaria_vivax_eas': captacion['densidad_parasitaria_vivax_eas'] ?? '',
              'densidad_parasitaria_vivax_ess': captacion['densidad_parasitaria_vivax_ess'] ?? '',
              'densidad_parasitaria_falciparum_eas': captacion['densidad_parasitaria_falciparum_eas'] ?? '',
              'densidad_parasitaria_falciparum_ess': captacion['densidad_parasitaria_falciparum_ess'] ?? '',
              'id_silais_diagnostico': captacion['id_silais_diagnostico'] ?? '',
              'id_establecimiento_diagnostico': captacion['id_establecimiento_diagnostico'] ?? '',
              'existencia_reinfeccion': captacion['existencia_reinfeccion'] == true ? 1 : 0,
              'evento_salud_extranjero': captacion['evento_salud_extranjero'] == true ? 1 : 0,
              'id_pais_ocurrencia_evento_salud': captacion['id_pais_ocurrencia_evento_salud'] ?? '',
              'usuario_creacion': captacion['usuario_creacion'] ?? '',
              'fecha_creacion': captacion['fecha_creacion'] ?? '',
              'usuario_modificacion': captacion['usuario_modificacion'] ?? '',
              'fecha_modificacion': captacion['fecha_modificacion'] ?? '',
              'activo': captacion['activo'] == true ? 1 : 0,
              'data': jsonEncode(captacion) // Guardar la respuesta completa como JSON
            };
          }).toList();

          // Guardar captaciones localmente en SQLite
          await _insertMultipleCaptaciones(captaciones);

          return captaciones;
        } else {
          throw Exception('Error al listar captaciones');
        }
      } else {
        // Si no hay conexión, devolver los datos locales
        return await _getAllCaptaciones();
      }
    } catch (e) {
      print("Error listando captaciones: $e");
      return await _getAllCaptaciones();
    }
  }

  Future<void> _insertMultipleCaptaciones(List<Map<String, dynamic>> captaciones) async {
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

  Future<List<Map<String, dynamic>>> _getAllCaptaciones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('captaciones');
    return maps.map((map) {
      return jsonDecode(map['data']) as Map<String, dynamic>;
    }).toList();
  }
}
