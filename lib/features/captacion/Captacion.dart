import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importaciones de servicios personalizados
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart';
import 'package:siven_app/core/services/CondicionPersonaService.dart';
import 'package:siven_app/core/services/SitioExposicionService.dart';
import 'package:siven_app/core/services/LugarIngresoPaisService.dart';
import 'package:siven_app/core/services/SintomasService.dart';
import 'package:siven_app/core/services/PuestoNotificacionService.dart';
import 'package:siven_app/core/services/DiagnosticoService.dart';
import 'package:siven_app/core/services/ResultadoDiagnosticoService.dart';
import 'package:siven_app/core/services/ComorbilidadesService.dart';

// Importaciones de widgets personalizados
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'PrimeraTarjeta.dart';
import 'SegundaTarjeta.dart';
import 'TerceraTarjeta.dart';
import 'CuartaTarjeta.dart';

class Captacion extends StatefulWidget {
  const Captacion({Key? key}) : super(key: key);

  @override
  _CaptacionState createState() => _CaptacionState();
}

class _CaptacionState extends State<Captacion> {
  final PageController _pageController = PageController(); // Controlador para PageView
  int _currentCardIndex = 0; // Índice de la tarjeta actual
  String? _selectedEventoName;
  String? nombreCompleto;

  // Evita el cambio rápido entre páginas
  bool _isNavigating = false;

  // Servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late EventoSaludService eventoSaludService;
  late MaternidadService maternidadService;
  late LugarCaptacionService lugarCaptacionService;
  late CondicionPersonaService condicionPersonaService;
  late SitioExposicionService sitioExposicionService;
  late LugarIngresoPaisService lugarIngresoPaisService;
  late SintomasService sintomasService;
  late PuestoNotificacionService puestoNotificacionService;
  late DiagnosticoService diagnosticoService;
  late ResultadoDiagnosticoService resultadoDiagnosticoService;
  late ComorbilidadesService comorbilidadesService;

  // Instancias de las tarjetas con GlobalKey
  late GlobalKey<PrimeraTarjetaState> _primeraTarjetaKey;
  late PrimeraTarjeta _primeraTarjeta;

  late GlobalKey<SegundaTarjetaState> _segundaTarjetaKey;
  late SegundaTarjeta _segundaTarjeta;

  late GlobalKey<TerceraTarjetaState> _terceraTarjetaKey;
  late TerceraTarjeta _terceraTarjeta;

  late GlobalKey<CuartaTarjetaState> _cuartaTarjetaKey;
  late CuartaTarjeta _cuartaTarjeta;

  // Flag para inicializar las tarjetas una sola vez
  bool _cardsInitialized = false;

  // Variable para almacenar los datos
  Map<String, dynamic> collectedData = {};

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
    eventoSaludService = EventoSaludService(httpService: httpService);
    maternidadService = MaternidadService(httpService: httpService);
    lugarCaptacionService = LugarCaptacionService(httpService: httpService);
    condicionPersonaService = CondicionPersonaService(httpService: httpService);
    sitioExposicionService = SitioExposicionService(httpService: httpService);
    lugarIngresoPaisService = LugarIngresoPaisService(httpService: httpService);
    sintomasService = SintomasService(httpService: httpService);
    puestoNotificacionService = PuestoNotificacionService(httpService: httpService);
    diagnosticoService = DiagnosticoService(httpService: httpService);
    resultadoDiagnosticoService = ResultadoDiagnosticoService(httpService: httpService);
    comorbilidadesService = ComorbilidadesService(httpService: httpService);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _selectedEventoName = args['eventoSeleccionado'];
        nombreCompleto = args['nombreCompleto'];
      });
    }

    // Inicializar las tarjetas una sola vez después de obtener los argumentos
    if (!_cardsInitialized) {
      final int? idPersona = args != null && args is Map<String, dynamic> ? args['id_persona'] as int? : null;
      final int? idEventoSalud = args != null && args is Map<String, dynamic> ? args['id_evento_salud'] as int? : null;

      _primeraTarjetaKey = GlobalKey<PrimeraTarjetaState>();

      _primeraTarjeta = PrimeraTarjeta(
        key: _primeraTarjetaKey,
        nombreEventoSeleccionado: _selectedEventoName,
        nombreCompleto: nombreCompleto,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        maternidadService: maternidadService,
        idEventoSalud: idEventoSalud?.toString(),
        idPersona: idPersona,
        comorbilidadesService: comorbilidadesService,
      );

      _segundaTarjetaKey = GlobalKey<SegundaTarjetaState>();

      _segundaTarjeta = SegundaTarjeta(
        key: _segundaTarjetaKey,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        lugarCaptacionService: lugarCaptacionService,
        condicionPersonaService: condicionPersonaService,
        sitioExposicionService: sitioExposicionService,
        lugarIngresoPaisService: lugarIngresoPaisService,
        sintomasService: sintomasService,
      );

      _terceraTarjetaKey = GlobalKey<TerceraTarjetaState>();

      _terceraTarjeta = TerceraTarjeta(
        key: _terceraTarjetaKey,
        puestoNotificacionService: puestoNotificacionService,
      );

      _cuartaTarjetaKey = GlobalKey<CuartaTarjetaState>();

      _cuartaTarjeta = CuartaTarjeta(
        key: _cuartaTarjetaKey,
        diagnosticoService: diagnosticoService,
        resultadoDiagnosticoService: resultadoDiagnosticoService,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
      );

      _cardsInitialized = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Asegúrate de cerrar todos los servicios si es necesario
    lugarCaptacionService.close();
    condicionPersonaService.close();
    sitioExposicionService.close();
    lugarIngresoPaisService.close();
    sintomasService.close();
    puestoNotificacionService.close();
    diagnosticoService.close();
    resultadoDiagnosticoService.close();
    super.dispose();
  }

  void _goToPage(int index) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    if (index >= 0 && index < 4) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentCardIndex = index;
          });
        }
        _isNavigating = false;
      });
    } else {
      _isNavigating = false;
    }
  }

  void _onNextPressed() {
    if (_currentCardIndex < 3) {
      if (_currentCardIndex == 0) {
        collectedData = _primeraTarjetaKey.currentState?.getData() ?? {};
        print('Datos de PrimeraTarjeta: $collectedData');
      } else if (_currentCardIndex == 1) {
        final segundaData = _segundaTarjetaKey.currentState?.getData() ?? {};
        collectedData.addAll(segundaData);
        print('Datos de SegundaTarjeta: $segundaData');
        print('Datos recopilados hasta ahora: $collectedData');
      } else if (_currentCardIndex == 2) {
        final terceraData = _terceraTarjetaKey.currentState?.getData() ?? {};
        collectedData.addAll(terceraData);
        print('Datos de TerceraTarjeta: $terceraData');
        print('Datos recopilados hasta ahora: $collectedData');
      }
      _goToPage(_currentCardIndex + 1);
    } else if (_currentCardIndex == 3) {
      // Recopilar datos de la cuarta tarjeta
      final cuartaData = _cuartaTarjetaKey.currentState?.getData() ?? {};
      collectedData.addAll(cuartaData);
      print('Datos de CuartaTarjeta: $cuartaData');
      print('Datos recopilados hasta ahora: $collectedData');

      // Aquí puedes implementar la lógica para enviar los datos al servidor o base de datos
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Fila con el botón de Centro de Salud y el ícono de perfil
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BotonCentroSalud(
              catalogService: catalogService,
              selectionStorageService: selectionStorageService,
            ),
            const IconoPerfil(),
          ],
        ),
        const SizedBox(height: 20),
        // Widget de Red de Servicio
        RedDeServicio(
          catalogService: catalogService,
          selectionStorageService: selectionStorageService,
        ),
        const SizedBox(height: 30),
        // Contenedor con el nombre del evento de salud
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFF00C1D4),
          child: Center(
            child: Text(
              'Evento de salud - ${_selectedEventoName ?? 'Evento no seleccionado'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Fila con el ícono de persona y el nombre completo
        Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF00C1D4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ver detalle del paciente - ${nombreCompleto ?? 'Sin nombre'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCard(Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(),
          KeepAlivePage(child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1877F2), size: 32),
            onPressed: () {
              Navigator.pushNamed(context, '/captacion_inf_paciente');
            },
          ),
        ),
        title: const EncabezadoBienvenida(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCard(_primeraTarjeta),
                _buildCard(_segundaTarjeta),
                _buildCard(_terceraTarjeta),
                _buildCard(_cuartaTarjeta),
              ],
            ),
          ),
          // Botones de navegación y puntos indicadores
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentCardIndex > 0
                      ? () => _goToPage(_currentCardIndex - 1)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ANTERIOR',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: _currentCardIndex == i
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C1D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIGUIENTE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const VersionWidget(),
        ],
      ),
    );
  }
}

/// Widget auxiliar para mantener el estado
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para el mixin
    return widget.child;
  }
}
