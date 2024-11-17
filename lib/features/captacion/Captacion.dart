import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importaciones de servicios personalizados
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart';

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

  // Instancias de las tarjetas
  late PrimeraTarjeta _primeraTarjeta;
  late SegundaTarjeta _segundaTarjeta;
  late TerceraTarjeta _terceraTarjeta;
  late CuartaTarjeta _cuartaTarjeta;

  // Flag para inicializar las tarjetas una sola vez
  bool _cardsInitialized = false;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _selectedEventoName = args['eventoSeleccionado'];
        nombreCompleto = args['nombreCompleto'];
      });
    }

    // Inicializar las tarjetas una sola vez después de obtener los argumentos
    if (!_cardsInitialized) {
      _primeraTarjeta = PrimeraTarjeta(
        nombreEventoSeleccionado: _selectedEventoName,
        nombreCompleto: nombreCompleto,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        maternidadService: maternidadService,
      );

      _segundaTarjeta = SegundaTarjeta(
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        lugarCaptacionService: lugarCaptacionService,
      );

      _terceraTarjeta = const TerceraTarjeta();
      _cuartaTarjeta = const CuartaTarjeta();

      _cardsInitialized = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  Widget _buildHeader() {
    return Column(
      children: [
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
        RedDeServicio(
          catalogService: catalogService,
          selectionStorageService: selectionStorageService,
        ),
        const SizedBox(height: 30),
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
          content,
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
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF1877F2), size: 32),
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
              onPageChanged: (index) {
                setState(() {
                  _currentCardIndex = index;
                });
              },
              children: [
                _buildCard(_primeraTarjeta),
                _buildCard(_segundaTarjeta),
                _buildCard(_terceraTarjeta),
                _buildCard(_cuartaTarjeta),
              ],
            ),
          ),
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
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
                  onPressed: _currentCardIndex < 3
                      ? () => _goToPage(_currentCardIndex + 1)
                      : null,
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
