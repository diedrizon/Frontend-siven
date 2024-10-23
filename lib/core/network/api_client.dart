import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/storage_service.dart';
import 'package:siven_app/core/utils/constants.dart';

class ApiClient {
  final http.Client httpClient;

  ApiClient({required this.httpClient});

  // Método de login que guarda el token automáticamente en el storage seguro
  Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    final url = Uri.parse('$BASE_URL/login');
    final response = await httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuario,  // Asegúrate de que estos campos coincidan con lo que el backend espera
        'contrasena': contrasena, // Revisa que estos nombres sean correctos
      }),
    );

    print('Código de estado: ${response.statusCode}');
    print('Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200) {
      // Parsear la respuesta JSON
      final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      // Guardar el token en el almacenamiento seguro
      final token = responseBody['token'];
      if (token != null) {
        await StorageService().saveToken(token);
      } else {
        throw Exception('Token no presente en la respuesta.');
      }

      return responseBody; // Devuelve el cuerpo de la respuesta por si necesitas más información
    } else {
      throw Exception('Error de autenticación: ${response.statusCode} ${response.body}');
    }
  }

  // Método para hacer una solicitud autenticada usando el token almacenado
  Future<http.Response> authenticatedGet(String endpoint) async {
    final token = await StorageService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No se encontró un token válido.');
    }

    final url = Uri.parse('$BASE_URL/$endpoint');
    final response = await httpClient.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error en la solicitud: ${response.statusCode}');
    }

    return response;
  }
}

