import 'dart:convert';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class CaptacionService {
  final HttpService httpService;

  CaptacionService({required this.httpService});

  // Método para buscar captaciones
  Future<List<Map<String, dynamic>>> buscarCaptaciones({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? idSilais,
    int? idEventoSalud,
    int? idEstablecimiento,
  }) async {
    // Construir la URL con parámetros de consulta
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

    // Eliminar el último '&' si existe
    if (url.endsWith('&')) {
      url = url.substring(0, url.length - 1);
    }

    final response = await httpService.get(url);

    // Mapear la respuesta JSON a una lista de mapas
    List<dynamic> jsonResponse = jsonDecode(response.body);

    // Mapeo a una lista de objetos CaptacionDTO con todos los campos
    return jsonResponse.map((captacion) {
      return {
        'idCaptacion': captacion['idCaptacion'],
        'codigoExpediente': captacion['codigoExpediente'],
        'cedula': captacion['cedula'],
        'nombreCompleto': captacion['nombreCompleto'],
        'municipio': captacion['municipio'],
        'departamento': captacion['departamento'],
        'fechaCaptacion': captacion['fechaCaptacion'],
        'activo': captacion['activo'],
        'establecimientoSalud': captacion['establecimientoSalud'],
      };
    }).toList();
  }

  // Método para filtrar captaciones por datos de la persona
  Future<List<Map<String, dynamic>>> filtrarPorDatosPersona(String filtro) async {
    String url = '$BASE_URL$CATALOGOS_CAPTACION/filtrar?filtro=$filtro';

    final response = await httpService.get(url);

    List<dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse.map((captacion) {
      return {
        'idCaptacion': captacion['idCaptacion'],
        'codigoExpediente': captacion['codigoExpediente'],
        'cedula': captacion['cedula'],
        'nombreCompleto': captacion['nombreCompleto'],
        'municipio': captacion['municipio'],
        'departamento': captacion['departamento'],
        'fechaCaptacion': captacion['fechaCaptacion'],
        'activo': captacion['activo'],
        'establecimientoSalud': captacion['establecimientoSalud'],
      };
    }).toList();
  }
}
