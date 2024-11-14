import 'dart:convert';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class EventoSaludService {
  final HttpService httpService;

  EventoSaludService({required this.httpService});

  // Método para listar todos los eventos de salud
  Future<List<Map<String, dynamic>>> listarEventosSalud() async {
    String url = '$BASE_URL/v1/catalogo/captacion/list-evento-salud';

    final response = await httpService.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((evento) {
        return {
          'id_evento_salud': evento['id_evento_salud'],
          'nombre': evento['nombre'],
          'usuario_creacion': evento['usuario_creacion'],
          'fecha_creacion': evento['fecha_creacion'],
          'activo': evento['activo'],
        };
      }).toList();
    } else {
      throw Exception('Error al listar eventos de salud');
    }
  }

  // Método para agregar un nuevo evento de salud
  Future<Map<String, dynamic>> agregarEventoSalud(Map<String, dynamic> nuevoEvento) async {
    String url = '$BASE_URL/v1/catalogo/captacion/create-evento-salud';

    final response = await httpService.post(url, nuevoEvento);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al agregar el evento de salud');
    }
  }

  // Método para actualizar un evento de salud existente
  Future<Map<String, dynamic>> actualizarEventoSalud(int idEventoSalud, Map<String, dynamic> eventoActualizado) async {
    String url = '$BASE_URL/v1/catalogo/captacion/update-evento-salud/$idEventoSalud';

    final response = await httpService.put(url, eventoActualizado);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar el evento de salud');
    }
  }

  // Método para eliminar un evento de salud
  Future<void> eliminarEventoSalud(int idEventoSalud) async {
    String url = '$BASE_URL/v1/catalogo/captacion/delete-evento-salud/$idEventoSalud';

    final response = await httpService.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el evento de salud');
    }
  }

  // Método para obtener un evento de salud por ID
  Future<Map<String, dynamic>> obtenerEventoSaludPorId(int id) async {
    String url = '$BASE_URL/v1/catalogo/captacion/evento-salud/$id';

    final response = await httpService.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener el evento de salud');
    }
  }
}
