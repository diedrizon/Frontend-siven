import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';

import 'package:siven_app/core/services/LugarCaptacionService.dart';



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
  int _currentCardIndex = 0; // Índice de la tarjeta actual
  String? _selectedEventoName;
  String? nombreCompleto;

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late EventoSaludService eventoSaludService;
  late MaternidadService maternidadService;
  late LugarCaptacionService lugarCaptacionService;


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

  // Métodos de navegación
  void _nextCard() {
    if (_currentCardIndex < 3) {
      setState(() {
        _currentCardIndex++;
      });
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
      });
    }
  }

  // Método para obtener el contenido de la tarjeta actual
  Widget _buildCardContent() {
    switch (_currentCardIndex) {
      case 0:
        return PrimeraTarjeta(
          nombreEventoSeleccionado: _selectedEventoName,
          nombreCompleto: nombreCompleto,
          catalogService: catalogService,
          selectionStorageService: selectionStorageService,
          maternidadService: maternidadService,
        );
      case 1:
        return SegundaTarjeta(
          catalogService: catalogService,
          selectionStorageService: selectionStorageService,
           lugarCaptacionService: lugarCaptacionService,
        );
      case 2:
        return TerceraTarjeta();
      case 3:
        return CuartaTarjeta();
      default:
        return Container();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener los argumentos pasados desde la pantalla anterior
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _selectedEventoName = args['eventoSeleccionado'];
        nombreCompleto = args['nombreCompleto'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        backgroundColor: Colors.white, // Fondo blanco en el AppBar
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: const Color(0xFF00C1D4), // Color celeste
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
                          overflow: TextOverflow
                              .ellipsis, // Esto mostrará '...' si el texto es muy largo
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildCardContent(),
                ],
              ),
            ),
          ),

          // Footer con botones de navegación
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón "ANTERIOR"
                ElevatedButton(
                  onPressed: _previousCard,
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

                // Indicadores de página
                Row(
                  children: [
                    for (int i = 0; i < 4; i++) // Ahora cuatro cards
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

                // Botón "SIGUIENTE"
                ElevatedButton(
                  onPressed: _currentCardIndex < 3
                      ? _nextCard
                      : null, // Deshabilitar en la última card
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
