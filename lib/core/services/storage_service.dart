import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();

  // Guarda el token de autenticación
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Recupera el token almacenado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Elimina el token

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // Guarda los roles del usuario
  Future<void> saveRoles(List<String> roles) async {
    await _secureStorage.write(key: 'user_roles', value: roles.join(',')); // Guarda los roles como una cadena separada por comas
  }

  // Recupera los roles almacenados
  Future<List<String>?> getRoles() async {
    final rolesString = await _secureStorage.read(key: 'user_roles');
    if (rolesString != null) {
      return rolesString.split(','); // Convierte la cadena de vuelta en una lista
    }
    return null;
  }

  // Elimina los roles
  Future<void> deleteRoles() async {
    await _secureStorage.delete(key: 'user_roles');
  }
}
