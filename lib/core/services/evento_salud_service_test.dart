import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';

/// Clase de mock manual para HttpService que devuelve datos simulados
class MockHttpService implements HttpService {
  @override
  final http.Client httpClient = http.Client(); // Agrega el httpClient aquí

  @override
  Future<http.Response> get(String url) async {
    // Simulamos una respuesta con datos de prueba
    final mockResponse = [
      {
        'id_evento_salud': 1,
        'nombre': 'Evento de Prueba',
        'usuario_creacion': 'UsuarioSimulado',
        'fecha_creacion': '2024-11-11',
        'activo': true,
      }
    ];
    // Devolvemos la respuesta simulada como si fuera una llamada exitosa
    return http.Response(jsonEncode(mockResponse), 200);
  }

  // No implementamos los otros métodos ya que no se necesitan para esta prueba
  @override
  Future<http.Response> post(String url, Map<String, dynamic> body) => throw UnimplementedError();
  @override
  Future<http.Response> put(String url, Map<String, dynamic> body) => throw UnimplementedError();
  @override
  Future<http.Response> delete(String url) => throw UnimplementedError();
}

void main() {
  late MockHttpService mockHttpService;
  late EventoSaludService eventoSaludService;

  setUp(() {
    mockHttpService = MockHttpService();
    eventoSaludService = EventoSaludService(httpService: mockHttpService);
  });

  test('listarEventosSalud devuelve una lista de eventos con datos simulados', () async {
    // Llamada al método listarEventosSalud y verificación de la respuesta
    final eventos = await eventoSaludService.listarEventosSalud();

    // Verificamos que el resultado sea una lista de mapas con los datos esperados
    expect(eventos, isA<List<Map<String, dynamic>>>());
    expect(eventos.length, 1); // Debe contener un solo evento en los datos simulados
    expect(eventos.first['nombre'], 'Evento de Prueba');
    expect(eventos.first['usuario_creacion'], 'UsuarioSimulado');
    expect(eventos.first['fecha_creacion'], '2024-11-11');
    expect(eventos.first['activo'], true);
  });
}
