import 'dart:convert';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class CatalogServiceRedServicio {
  final HttpService httpService;

  CatalogServiceRedServicio({required this.httpService});

  // Obtener todos los SILAIS
  Future<List<Map<String, dynamic>>> getAllSilais() async {
    final response =
        await httpService.get('$BASE_URL$CATALOGOS_RED_DE_SERVICIO/list-silais');

    List<dynamic> jsonResponse = jsonDecode(response.body);

    // Mapeo explícito para asegurar que devolvemos List<Map<String, dynamic>>
    return jsonResponse.map((silais) {
      return {
        'id_silais': silais['id_silais'],
        'nombre': silais['nombre'],
      };
    }).toList();
  }

  // Obtener un SILAIS por ID
  Future<Map<String, dynamic>> getSilaisById(int id) async {
    final response = await httpService.get('$BASE_URL$CATALOGOS_RED_DE_SERVICIO/silais/$id');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Crear un nuevo SILAIS
  Future<Map<String, dynamic>> createSilais(Map<String, dynamic> silais) async {
    final response = await httpService.post(
        '$BASE_URL$CATALOGOS_RED_DE_SERVICIO/create-silais', silais);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Actualizar un SILAIS
  Future<Map<String, dynamic>> updateSilais(int id, Map<String, dynamic> silais) async {
    final response = await httpService.put(
        '$BASE_URL$CATALOGOS_RED_DE_SERVICIO/update-silais/$id', silais);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Eliminar un SILAIS
  Future<void> deleteSilais(int id) async {
    await httpService.delete('$BASE_URL$CATALOGOS_RED_DE_SERVICIO/delete-silais/$id');
  }

  // Obtener todos los establecimientos
  Future<List<Map<String, dynamic>>> getAllEstablecimientos() async {
    final response = await httpService.get('$BASE_URL$CATALOGOS_RED_DE_SERVICIO/list-establecimientos');
    List<dynamic> jsonResponse = jsonDecode(response.body);

    // Mapeo explícito a List<Map<String, dynamic>>
    return jsonResponse.map((establecimiento) {
      return {
        'id_establecimiento': establecimiento['id_establecimiento'],
        'nombre': establecimiento['nombre'],
      };
    }).toList();
  }

  // Obtener un establecimiento por ID
  Future<Map<String, dynamic>> getEstablecimientoById(int id) async {
    final response = await httpService.get('$BASE_URL$CATALOGOS_RED_DE_SERVICIO/establecimiento/$id');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Obtener establecimientos por ID de SILAIS
  Future<List<Map<String, dynamic>>> getEstablecimientosBySilais(int idSilais) async {
    final response = await httpService.get(
        '$BASE_URL$CATALOGOS_RED_DE_SERVICIO/silais/$idSilais/establecimientos');
    List<dynamic> jsonResponse = jsonDecode(response.body);

    // Mapeo explícito a List<Map<String, dynamic>>
    return jsonResponse.map((establecimiento) {
      return {
        'id_establecimiento': establecimiento['id_establecimiento'],
        'nombre': establecimiento['nombre'],
      };
    }).toList();
  }
}
