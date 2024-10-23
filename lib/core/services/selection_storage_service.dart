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
}
