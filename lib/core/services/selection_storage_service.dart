import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelectionStorageService {
  final _secureStorage = const FlutterSecureStorage();

  // Guarda el ID del SILAIS seleccionado
  Future<void> saveSelectedSilais(String silaisId) async {
    await _secureStorage.write(key: 'selected_silais', value: silaisId);
  }

  // Recupera el ID del SILAIS seleccionado
  Future<String?> getSelectedSilais() async {
    return await _secureStorage.read(key: 'selected_silais');
  }

  // Guarda el ID de la Unidad de Salud seleccionada
  Future<void> saveSelectedUnidadSalud(String unidadId) async {
    await _secureStorage.write(key: 'selected_unidad_salud', value: unidadId);
  }

  // Recupera el ID de la Unidad de Salud seleccionada
  Future<String?> getSelectedUnidadSalud() async {
    return await _secureStorage.read(key: 'selected_unidad_salud');
  }

  // Limpiar las selecciones (tanto SILAIS como Unidad de Salud)
  Future<void> clearSelections() async {
    await _secureStorage.delete(key: 'selected_silais');
    await _secureStorage.delete(key: 'selected_unidad_salud');
  }

  // Almacena en caché la lista de SILAIS
  Future<void> saveSilaisListCache(List<Map<String, dynamic>> silaisList) async {
    final encodedData = jsonEncode(silaisList);
    await _secureStorage.write(key: 'silais_list_cache', value: encodedData);
  }

  // Recupera la lista de SILAIS del caché
  Future<List<Map<String, dynamic>>?> getSilaisListCache() async {
    final cachedData = await _secureStorage.read(key: 'silais_list_cache');
    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
    }
    return null; // Retorna null si no hay caché
  }

  // Almacena en caché los establecimientos para un SILAIS específico
  Future<void> saveEstablecimientosCache(
      int silaisId, List<Map<String, dynamic>> establecimientosList) async {
    final encodedData = jsonEncode(establecimientosList);
    await _secureStorage.write(
      key: 'establecimientos_cache_$silaisId',
      value: encodedData,
    );
  }

  // Recupera los establecimientos del caché para un SILAIS específico
  Future<List<Map<String, dynamic>>?> getEstablecimientosCache(int silaisId) async {
    final cachedData = await _secureStorage.read(key: 'establecimientos_cache_$silaisId');
    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
    }
    return null; // Retorna null si no hay caché
  }
}
