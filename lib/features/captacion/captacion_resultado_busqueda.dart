// lib/screens/CaptacionResultadoBusqueda.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para codificar y decodificar JSON
import 'package:siven_app/widgets/version.dart'; 
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; 
import 'package:siven_app/widgets/card_persona.dart'; 
import 'package:siven_app/widgets/filtro_persona.dart'; 
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
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  List<Map<String, dynamic>> resultadosBusqueda = [];
  List<Map<String, dynamic>> resultadosFiltrados = []; // Lista para almacenar los resultados filtrados

  // Lista para almacenar los IDs de las personas mostradas
  List<int> personaIds = [];

  @override
  void initState() {
    super.initState();
    initializeServices();
    _loadSavedResults(); // Cargar los resultados guardados
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
  }

  // Guardar los resultados en shared_preferences
  Future<void> _saveResults(List<Map<String, dynamic>> resultados) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonResultados = jsonEncode(resultados); // Convertir la lista de mapas a JSON
    await prefs.setString('resultados_busqueda', jsonResultados); // Guardar el JSON en shared_preferences
    print('Resultados de búsqueda guardados'); // Log para confirmar almacenamiento
  }

  // Cargar los resultados de shared_preferences
  Future<void> _loadSavedResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonResultados = prefs.getString('resultados_busqueda');
    
    if (jsonResultados != null) {
      List<Map<String, dynamic>> resultados = List<Map<String, dynamic>>.from(jsonDecode(jsonResultados));
      List<int> ids = resultados.map<int>((persona) => persona['id_persona'] as int).toList();

      setState(() {
        resultadosBusqueda = resultados;
        resultadosFiltrados = resultadosBusqueda; // Inicialmente mostrar todos los resultados
        personaIds = ids;
      });

      // Imprimir los IDs en la terminal
      print('IDs de las personas mostradas en CaptacionResultadoBusqueda: $personaIds');
    }
  }

  // Método para filtrar resultados según el texto ingresado
  void _filtrarResultados(String query) {
    query = query.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        resultadosFiltrados = List.from(resultadosBusqueda); // Mostrar todos los resultados si no hay filtro
      } else {
        resultadosFiltrados = resultadosBusqueda.where((persona) {
          // Concatenar todos los campos relevantes para hacer la búsqueda en un solo lugar
          String identificacion = (persona['cedula'] ?? '').toLowerCase();
          String expediente = (persona['codigo_expediente'] ?? '').toLowerCase();
          String nombreCompleto = '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
              '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'.toLowerCase().trim();
          String municipio = (persona['municipio'] ?? '').toLowerCase();
          String departamento = (persona['departamento'] ?? '').toLowerCase();

          // Verificar si el query coincide con cualquiera de estos campos
          return identificacion.contains(query) ||
                 expediente.contains(query) ||
                 nombreCompleto.contains(query) ||
                 municipio.contains(query) ||
                 departamento.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados desde la pantalla de búsqueda
    final argumentos = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (argumentos != null) {
      List<Map<String, dynamic>> resultados = List<Map<String, dynamic>>.from(argumentos['resultados'] ?? []);
      List<int> personaIdsRecibidos = List<int>.from(argumentos['personaIds'] ?? []);

      // Imprimir los IDs en la terminal
      print('IDs recibidos en CaptacionResultadoBusqueda: $personaIdsRecibidos');

      // Actualizar el estado si los resultados son nuevos
      if (resultados != resultadosBusqueda) {
        setState(() {
          resultadosBusqueda = resultados;
          resultadosFiltrados = List.from(resultadosBusqueda); // Mostrar también los resultados filtrados
          personaIds = personaIdsRecibidos;
        });

        // Guardar los resultados localmente
        _saveResults(resultadosBusqueda);
      }
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
              Navigator.pushNamed(context, '/captacion_busqueda_por_nombre'); // Volver a la pantalla inicial
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

                  // Filtro por datos de la persona (Manteniendo el diseño y estilo original)
                  FiltroPersonaWidget(
                    hintText: 'Filtrar por datos de la persona',
                    colorBorde: const Color(0xFF00BCD4),
                    colorIcono: const Color(0xFF00BCD4),
                    colorTexto: const Color(0xFF4A4A4A),
                    onChanged: _filtrarResultados, // Filtrar resultados dinámicamente
                  ),
                  const SizedBox(height: 20),

                  // Lista de resultados de búsqueda usando CardPersonaWidget
                  Column(
                    children: resultadosFiltrados.map((persona) {
                      String nombreCompleto = '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
                          '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'.trim();

                      String municipio = persona['municipio'] ?? 'Sin municipio';
                      String departamento = persona['departamento'] ?? 'Sin departamento';
                      String ubicacionCompleta = '$municipio / $departamento';

                      return Column(
                        children: [
                          CardPersonaWidget(
                            identificacion: persona['cedula'] ?? 'Sin cédula', // Mostrar identificación
                            expediente: persona['codigo_expediente'] ?? 'Sin expediente', // Mostrar expediente
                            nombre: nombreCompleto.isNotEmpty ? nombreCompleto : 'Sin nombre',
                            ubicacion: ubicacionCompleta,
                            colorBorde: const Color(0xFF00BCD4),
                            colorBoton: const Color(0xFF00BCD4),
                            textoBoton: 'SELECCIONAR',
                            onBotonPressed: () async {
                              // Extraer el id_persona
                              int idPersona = persona['id_persona'];
                              
                              // Imprimir el id_persona en la terminal
                              print('Persona seleccionada ID: $idPersona');
                              
                              // Almacenar el id_persona para uso interno
                              
                              // Navegar a la siguiente interfaz pasando los datos de la persona
                              Navigator.pushNamed(
                                context,
                                '/captacion_inf_paciente',
                                arguments: persona,  // Pasar todos los datos del paciente
                              );
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
