import 'package:flutter/material.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/card_persona.dart'; // Importa el widget reutilizable para las cards
import 'package:siven_app/widgets/filtro_persona.dart';
import 'package:siven_app/core/services/captacion_service.dart'; // Asegúrate de importar correctamente el servicio
import 'package:siven_app/core/services/http_service.dart'; // Importa HttpService
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart'; // Importa CatalogServiceRedServicio
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/selection_storage_service.dart';

class ResultadosBusquedaScreen extends StatefulWidget {
  final String silais;
  final String unidadSalud;
  final String evento;
  final String fechaInicio;
  final String fechaFin;

  const ResultadosBusquedaScreen({
    required this.silais,
    required this.unidadSalud,
    required this.evento,
    required this.fechaInicio,
    required this.fechaFin,
    Key? key,
  }) : super(key: key);

  @override
  _ResultadosBusquedaScreenState createState() => _ResultadosBusquedaScreenState();
}

class _ResultadosBusquedaScreenState extends State<ResultadosBusquedaScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;

  // Declaración de servicios
  late CaptacionService captacionService;
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  bool _servicesInitialized = false; // Variable de control para saber si los servicios están listos
  List<Map<String, dynamic>> personasFiltradas = [];

  @override
  void initState() {
    super.initState();
    initializeServices().then((_) {
      _fetchResultadosFiltrados(); // Cargar datos una vez que los servicios están listos
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 0) {
        if (!_showHeader) {
          setState(() {
            _showHeader = true; // Mostrar encabezado
          });
        }
      } else if (_scrollController.position.pixels > 100) {
        if (_showHeader) {
          setState(() {
            _showHeader = false; // Ocultar encabezado
          });
        }
      }
    });
  }

  // Método asincrónico para inicializar los servicios
  Future<void> initializeServices() async {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    captacionService = CaptacionService(httpService: httpService);
    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();

    setState(() {
      _servicesInitialized = true; // Indicar que los servicios han sido inicializados
    });
  }

  // Método para obtener los resultados filtrados desde el servicio CaptacionService
  Future<void> _fetchResultadosFiltrados() async {
    if (!_servicesInitialized) {
      // Asegurarse de que los servicios están inicializados antes de usarlos
      return;
    }

    try {
      final resultados = await captacionService.buscarCaptaciones(
        fechaInicio: widget.fechaInicio.isNotEmpty ? DateTime.parse(widget.fechaInicio) : null,
        fechaFin: widget.fechaFin.isNotEmpty ? DateTime.parse(widget.fechaFin) : null,
        idSilais: int.tryParse(widget.silais),
        idEventoSalud: int.tryParse(widget.evento),
        idEstablecimiento: int.tryParse(widget.unidadSalud),
      );

      setState(() {
        personasFiltradas = resultados;
      });
    } catch (error) {
      print('Error al buscar captaciones: $error');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color azulBrillante = Color(0xFF1877F2);
    const Color grisOscuro = Color(0xFF4A4A4A);
    const Color naranja = Color(0xFFF7941D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 90), // Espacio para el encabezado fijo (AppBar)

                      // Botón Centro de Salud y Perfil de Usuario
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BotonCentroSalud(
                            catalogService: catalogService, // Pasa el servicio aquí
                            selectionStorageService: selectionStorageService, // Pasa el servicio aquí
                          ),
                          const IconoPerfil(),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Texto Red de Servicio
                      RedDeServicio(
                        catalogService: catalogService, // Pasa el servicio aquí
                        selectionStorageService: selectionStorageService, // Pasa el servicio aquí
                      ),
                      const SizedBox(height: 30),

                      // Texto e Ícono "Resultado de búsqueda"
                      Row(
                        children: const [
                          Icon(Icons.search, color: naranja, size: 26),
                          SizedBox(width: 8),
                          Text(
                            'Resultado de búsqueda',
                            style: TextStyle(
                              fontSize: 18,
                              color: naranja,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Llamada al Widget Reutilizable FiltroPersonaWidget
                      Row(
                        children: [
                          Expanded(
                            child: FiltroPersonaWidget(
                              hintText: 'Filtro por datos de la persona',
                              colorBorde: naranja,
                              colorIcono: grisOscuro,
                              colorTexto: grisOscuro,
                              onChanged: (valor) {
                                _filtrarPorDatosPersona(valor);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Botones "Generar Reporte de Esta Lista" y "Generar Análisis de Esta Lista"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Acción para generar reporte
                              },
                              icon: const Icon(Icons.article, color: naranja, size: 40),
                              label: const Text(
                                'Generar Reporte de Esta Lista',
                                style: TextStyle(color: naranja),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: naranja),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(150, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navegación a la pantalla de análisis
                                Navigator.pushNamed(context, '/analisis');
                              },
                              icon: const Icon(Icons.analytics, color: naranja, size: 40),
                              label: const Text(
                                'Generar Análisis de Esta Lista',
                                style: TextStyle(color: naranja),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: naranja),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(150, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Listado de resultados (cards reutilizables)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: personasFiltradas.length,
                        itemBuilder: (context, index) {
                          final persona = personasFiltradas[index];
                          return CardPersonaWidget(
                            identificacion: persona['cedula'] ?? 'Sin cédula',
                            expediente: persona['codigoExpediente'] ?? 'Sin expediente',
                            nombre: persona['nombreCompleto'] ?? 'Sin nombre',
                            ubicacion: '${persona['municipio'] ?? 'Sin municipio'}/${persona['departamento'] ?? 'Sin departamento'}',
                            colorBorde: naranja,
                            colorBoton: naranja,
                            textoBoton: 'Generar Reporte', // Puedes cambiarlo si lo necesitas
                            onBotonPressed: () {
                              // Acción al presionar el botón
                              print('Generando reporte para ${persona['nombreCompleto']}');
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const VersionWidget(),
            ],
          ),
          if (_showHeader)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 13.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: azulBrillante, size: 32),
                          onPressed: () {
                            Navigator.pushNamed(context, '/FiltrarReporte');
                          },
                        ),
                      ),
                      title: const EncabezadoBienvenida(),
                      centerTitle: true,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Método para filtrar por datos de la persona (como nombre o cedula)
  Future<void> _filtrarPorDatosPersona(String filtro) async {
    try {
      final resultados = await captacionService.filtrarPorDatosPersona(filtro);

      setState(() {
        personasFiltradas = resultados;
      });
    } catch (error) {
      print('Error al filtrar por persona: $error');
    }
  }
}
