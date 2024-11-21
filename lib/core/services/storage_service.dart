// storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bcrypt/bcrypt.dart';

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

  // Guarda el nombre de usuario
  Future<void> saveUser(String username) async {
    try {
      await _secureStorage.write(key: 'username', value: username);
    } catch (e) {
      throw Exception('Error al guardar el usuario: $e');
    }
  }

  // Recupera el nombre de usuario
  Future<String?> getUser() async {
    try {
      return await _secureStorage.read(key: 'username');
    } catch (e) {
      throw Exception('Error al recuperar el usuario: $e');
    }
  }

  // Guarda el hash de la contraseña utilizando bcrypt
  Future<void> savePasswordHash(String password) async {
    try {
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      await _secureStorage.write(key: 'password_hash', value: hashedPassword);
    } catch (e) {
      throw Exception('Error al guardar el hash de la contraseña: $e');
    }
  }

  // Recupera el hash de la contraseña
  Future<String?> getPasswordHash() async {
    try {
      return await _secureStorage.read(key: 'password_hash');
    } catch (e) {
      throw Exception('Error al recuperar el hash de la contraseña: $e');
    }
  }
}
