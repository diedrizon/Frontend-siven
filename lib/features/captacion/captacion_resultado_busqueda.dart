import 'package:flutter/material.dart';
import 'package:siven_app/widgets/version.dart'; // Widget reutilizado
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; // Widget reutilizado
import 'package:siven_app/widgets/card_persona.dart'; // Widget CardPersonaWidget reutilizado
import 'package:siven_app/widgets/filtro_persona.dart'; // Widget FiltroPersonaWidget reutilizado
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;

class CaptacionResultadoBusqueda extends StatefulWidget {
  const CaptacionResultadoBusqueda({Key? key}) : super(key: key);

  @override
  _CaptacionResultadoBusquedaState createState() => _CaptacionResultadoBusquedaState();
}

class _CaptacionResultadoBusquedaState extends State<CaptacionResultadoBusqueda> {
  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  List<Map<String, dynamic>> resultadosBusqueda = []; // Lista para almacenar los resultados

  @override
  void initState() {
    super.initState();
    // Inicialización de servicios
    initializeServices();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados desde la pantalla de búsqueda
    final argumentos = ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>?;

    // Si los argumentos no son nulos, asignar los resultados a la lista
    if (argumentos != null) {
      resultadosBusqueda = argumentos;
    }

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
              Navigator.pushNamed(context, '/captacion_busqueda_por_nombre'); // Navegación a búsqueda por nombre
            },
          ),
        ),
        title: const EncabezadoBienvenida(), // Reutilizando el encabezado
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
                  // Filas con botones adicionales (BotonCentroSalud y IconoPerfil)
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

                  // Red de servicio
                  RedDeServicio(
                    catalogService: catalogService,
                    selectionStorageService: selectionStorageService,
                  ),
                  const SizedBox(height: 30),

                  // Filtro por datos de la persona
                  const FiltroPersonaWidget(
                    hintText: 'Filtrar por datos de la persona',
                    colorBorde: Color(0xFF00BCD4), // Color turquesa personalizado
                    colorIcono: Color(0xFF00BCD4), // Color del icono turquesa
                    colorTexto: Color(0xFF4A4A4A), // Color del texto
                  ),
                  const SizedBox(height: 20),

                  // Lista de resultados de búsqueda usando CardPersonaWidget
                  Column(
                    children: resultadosBusqueda.map((persona) {
                      // Concatenar el nombre completo con los diferentes campos
                      String nombreCompleto = '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
                          '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'.trim();

                      String municipio = persona['municipio'] ?? 'Sin municipio';
                      String departamento = persona['departamento'] ?? 'Sin departamento';
                      String ubicacionCompleta = '$municipio / $departamento';

                      return Column(
                        children: [
                          CardPersonaWidget(
                            identificacion: persona['cedula'] ?? 'Sin cédula',
                            expediente: persona['codigo_expediente'] ?? 'Sin expediente',
                            nombre: nombreCompleto, // Mostrar el nombre completo concatenado
                            ubicacion: ubicacionCompleta, // Mostrar municipio y departamento
                            colorBorde: const Color(0xFF00BCD4), // Color del borde turquesa
                            colorBoton: const Color(0xFF00BCD4), // Botón con fondo turquesa
                            textoBoton: 'SELECCIONAR',
                            onBotonPressed: () {
                              // Navegación a la pantalla de información del paciente
                              Navigator.pushNamed(context, '/captacion_inf_paciente');
                            },
                          ),
                          const SizedBox(height: 10), // Espaciado entre las tarjetas
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const VersionWidget(), // Widget de la versión en la parte inferior
        ],
      ),
    );
  }
}
