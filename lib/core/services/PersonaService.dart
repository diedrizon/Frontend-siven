import 'dart:convert';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class PersonaService {
  final HttpService httpService;

  PersonaService({required this.httpService});

  // Listar todas las personas con decodificación en UTF-8
  Future<List<Map<String, dynamic>>> listarPersonas() async {
    String url = '$BASE_URL/v1/catalogo/persona/list-personas';
    final response = await httpService.get(url);

    if (response.statusCode == 200) {
      // Decodificación UTF-8 para manejar caracteres especiales
      final decodedResponse = utf8.decode(response.bodyBytes);
      List<dynamic> jsonResponse = jsonDecode(decodedResponse);

      return jsonResponse.map((persona) {
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
          'activo': persona['activo'],
        };
      }).toList();
    } else {
      throw Exception('Error al listar personas');
    }
  }

  // Buscar personas por nombre o apellido
  Future<List<Map<String, dynamic>>> buscarPersonasPorNombreOApellido(String busqueda) async {
    List<Map<String, dynamic>> personas = await listarPersonas();
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

  // Buscar personas por cédula o código de expediente
  Future<List<Map<String, dynamic>>> buscarPersonasPorCedulaOExpediente(String busqueda) async {
    List<Map<String, dynamic>> personas = await listarPersonas();
    return personas.where((persona) {
      return persona['cedula'].toString().contains(busqueda) ||
             persona['codigo_expediente'].toString().contains(busqueda);
    }).toList();
  }
}
