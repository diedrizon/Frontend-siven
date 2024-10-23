import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/storage_service.dart';

class HttpService {
  final http.Client httpClient;

  HttpService({required this.httpClient});

  // Método genérico GET con autenticación
  Future<http.Response> get(String url) async {
    final token = await StorageService().getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await httpClient.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Verificar si el token es inválido y limpiar el token almacenado
    if (response.statusCode == 401 || response.body.contains('JWT signature does not match')) {
      await StorageService().deleteToken(); // Eliminar token no válido
      throw Exception('Token inválido. Reautenticar.');
    }

    return response;
  }

  // Método genérico POST con autenticación
  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final token = await StorageService().getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await httpClient.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',  // Se agrega el token a la solicitud
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error en la solicitud POST: ${response.statusCode}');
    }

    return response;
  }

  // Método genérico PUT con autenticación
  Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final token = await StorageService().getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await httpClient.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',  // Se agrega el token a la solicitud
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en la solicitud PUT: ${response.statusCode}');
    }

    return response;
  }

  // Método genérico DELETE con autenticación
  Future<http.Response> delete(String url) async {
    final token = await StorageService().getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await httpClient.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',  // Se agrega el token a la solicitud
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error en la solicitud DELETE: ${response.statusCode}');
    }

    return response;
  }
}
