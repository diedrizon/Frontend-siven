import 'package:siven_app/core/network/api_client.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    try {
      final response = await apiClient.login(usuario, contrasena);
      return response;
    } catch (e) {
      throw Exception('Error al autenticar');
    }
  }
}
