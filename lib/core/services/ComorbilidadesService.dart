import 'dart:convert';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class ComorbilidadesService {
  final HttpService httpService;

  ComorbilidadesService({required this.httpService});

  // Método para listar todas las comorbilidades
  Future<List<Map<String, dynamic>>> listarComorbilidades() async {
    String url = '$BASE_URL/v1/catalogo/captacion/list-comorbilidades';

    final response = await httpService.post(url, {});

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((comorbilidad) {
        return {
          'id_comorbilidades': comorbilidad['id_comorbilidades'],
          'nombre': comorbilidad['nombre'],
          'usuario_creacion': comorbilidad['usuario_creacion'],
          'fecha_creacion': comorbilidad['fecha_creacion'],
          'usuario_modificacion': comorbilidad['usuario_modificacion'],
          'fecha_modificacion': comorbilidad['fecha_modificacion'],
          'activo': comorbilidad['activo'],
        };
      }).toList();
    } else {
      throw Exception('Error al listar comorbilidades');
    }
  }

  // Método para agregar una nueva comorbilidad
  Future<Map<String, dynamic>> agregarComorbilidades(Map<String, dynamic> nuevaComorbilidad) async {
    String url = '$BASE_URL/v1/catalogo/captacion/create-comorbilidades';

    final response = await httpService.post(url, nuevaComorbilidad);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al agregar la comorbilidad');
    }
  }

  // Método para actualizar una comorbilidad existente
  Future<Map<String, dynamic>> actualizarComorbilidades(int idComorbilidad, Map<String, dynamic> comorbilidadActualizada) async {
    String url = '$BASE_URL/v1/catalogo/captacion/update-comorbilidades/$idComorbilidad';

    final response = await httpService.put(url, comorbilidadActualizada);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Comorbilidad no encontrada');
    } else {
      throw Exception('Error al actualizar la comorbilidad');
    }
  }

  // Método para eliminar una comorbilidad
  Future<void> eliminarComorbilidades(int idComorbilidad) async {
    String url = '$BASE_URL/v1/catalogo/captacion/delete-comorbilidades/$idComorbilidad';

    final response = await httpService.delete(url);

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception('Comorbilidad no encontrada');
      } else {
        throw Exception('Error al eliminar la comorbilidad');
      }
    }
  }

  // Método para obtener una comorbilidad por ID
  Future<Map<String, dynamic>> obtenerComorbilidadPorId(int id) async {
    String url = '$BASE_URL/v1/catalogo/captacion/comorbilidades/$id';

    final response = await httpService.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Comorbilidad no encontrada');
    } else {
      throw Exception('Error al obtener la comorbilidad');
    }
  }
}
