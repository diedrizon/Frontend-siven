import 'dart:convert';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class MaternidadService {
  final HttpService httpService;

  MaternidadService({required this.httpService});

  // Método para listar todas las opciones de maternidad
  Future<List<Map<String, dynamic>>> listarMaternidad() async {
    String url = '$BASE_URL/v1/catalogo/captacion/list-maternidad';

    final response = await httpService.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((maternidad) {
        return {
          'id_maternidad': maternidad['id_maternidad'],
          'nombre': maternidad['nombre'],
          'usuario_creacion': maternidad['usuario_creacion'],
          'fecha_creacion': maternidad['fecha_creacion'],
          'usuario_modificacion': maternidad['usuario_modificacion'],
          'fecha_modificacion': maternidad['fecha_modificacion'],
          'activo': maternidad['activo'],
        };
      }).toList();
    } else {
      throw Exception('Error al listar las opciones de maternidad');
    }
  }

  // Método para obtener una opción de maternidad por ID
  Future<Map<String, dynamic>> obtenerMaternidadPorId(int id) async {
    String url = '$BASE_URL/v1/catalogo/captacion/maternidad/$id';

    final response = await httpService.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener la opción de maternidad');
    }
  }

  // Método para agregar una nueva opción de maternidad
  Future<Map<String, dynamic>> agregarMaternidad(Map<String, dynamic> nuevaMaternidad) async {
    String url = '$BASE_URL/v1/catalogo/captacion/create-maternidad';

    final response = await httpService.post(url, nuevaMaternidad);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al agregar la opción de maternidad');
    }
  }

  // Método para actualizar una opción de maternidad existente
  Future<Map<String, dynamic>> actualizarMaternidad(int idMaternidad, Map<String, dynamic> maternidadActualizada) async {
    String url = '$BASE_URL/v1/catalogo/captacion/update-maternidad/$idMaternidad';

    final response = await httpService.put(url, maternidadActualizada);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar la opción de maternidad');
    }
  }

  // Método para eliminar una opción de maternidad
  Future<void> eliminarMaternidad(int idMaternidad) async {
    String url = '$BASE_URL/v1/catalogo/captacion/delete-maternidad/$idMaternidad';

    final response = await httpService.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la opción de maternidad');
    }
  }
}
