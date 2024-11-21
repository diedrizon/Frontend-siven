import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
import 'evento_salud_service_test.mocks.dart';

@GenerateMocks([HttpService])
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late EventoSaludService service;
  late MockHttpService mockHttpService;

  setUp(() async {
    mockHttpService = MockHttpService();
    service = EventoSaludService(httpService: mockHttpService);


    // Configura el mock para evitar MissingStubError en llamadas a la red
    when(mockHttpService.get(any)).thenAnswer((_) async => http.Response(
          '[]',
          200,
        )); 
  });

  tearDown(() async {
    await service.close();
  });

  group('EventoSaludService', () {
    test('Inicializa la base de datos correctamente', () async {
      final db = await service.database;
      expect(db.isOpen, isTrue);
    });

    test('listarEventosSalud obtiene datos locales vacíos inicialmente',
        () async {
      final eventos = await service.listarEventosSalud();
      expect(eventos, isEmpty);
    });
  });
}
