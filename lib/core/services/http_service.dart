import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/storage_service.dart';

class HttpService {
  final http.Client httpClient;

  HttpService({required this.httpClient});

  // Obtener un token válido del StorageService
  Future<String> _getToken() async {
    final token = await StorageService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado. Por favor, inicie sesión.');
    }
    return token;
  }

  // Manejar errores de autorización
  void _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401 || response.body.contains('JWT signature does not match')) {
      await StorageService().deleteToken(); // Eliminar el token inválido
      throw Exception('Token inválido. Por favor, reautentíquese.');
    }
  }

  // Método GET con autenticación
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final token = await _getToken();
    final response = await httpClient.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers, // Combina encabezados adicionales
      },
    );

    _handleUnauthorized(response);
    return response;
  }

  // Método POST con autenticación
  Future<http.Response> post(String url, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final token = await _getToken();
    final response = await httpClient.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    _handleUnauthorized(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error en la solicitud POST: ${response.statusCode}');
    }
    return response;
  }

  // Método PUT con autenticación
  Future<http.Response> put(String url, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final token = await _getToken();
    final response = await httpClient.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    _handleUnauthorized(response);
    if (response.statusCode != 200) {
      throw Exception('Error en la solicitud PUT: ${response.statusCode}');
    }
    return response;
  }

  // Método DELETE con autenticación
  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    final token = await _getToken();
    final response = await httpClient.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      },
    );

    _handleUnauthorized(response);
    if (response.statusCode != 200) {
      throw Exception('Error en la solicitud DELETE: ${response.statusCode}');
    }
    return response;
  }
}
