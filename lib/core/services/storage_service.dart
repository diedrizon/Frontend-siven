import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Guarda el token de autenticación
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
    } catch (e) {
      throw Exception('Error al guardar el token: $e');
    }
  }

  // Recupera el token almacenado
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      throw Exception('Error al recuperar el token: $e');
    }
  }

  // Elimina el token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      throw Exception('Error al eliminar el token: $e');
    }
  }

  // Guarda los roles del usuario
  Future<void> saveRoles(List<String> roles) async {
    try {
      await _secureStorage.write(key: 'user_roles', value: roles.join(','));
    } catch (e) {
      throw Exception('Error al guardar los roles: $e');
    }
  }

  // Recupera los roles almacenados
  Future<List<String>?> getRoles() async {
    try {
      final rolesString = await _secureStorage.read(key: 'user_roles');
      if (rolesString != null) {
        return rolesString.split(','); // Convierte la cadena en una lista
      }
      return null;
    } catch (e) {
      throw Exception('Error al recuperar los roles: $e');
    }
  }

  // Elimina los roles
  Future<void> deleteRoles() async {
    try {
      await _secureStorage.delete(key: 'user_roles');
    } catch (e) {
      throw Exception('Error al eliminar los roles: $e');
    }
  }
}
