import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siven_app/widgets/version.dart'; // Widget reutilizado
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; // Widget reutilizado
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/PersonaService.dart'; // Importar el servicio de Persona
import 'package:http/http.dart' as http;

class CaptacionBusquedaPersona extends StatefulWidget {
  const CaptacionBusquedaPersona({Key? key}) : super(key: key);

  @override
  _CaptacionBusquedaPersonaState createState() => _CaptacionBusquedaPersonaState();
}

class _CaptacionBusquedaPersonaState extends State<CaptacionBusquedaPersona> {
  bool habilitarBusquedaPorNombre = false;
  String? seleccion; // Para manejar la selección de botones "Recién Nacido" o "Desconocido"
  late PersonaService personaService;
  List<Map<String, dynamic>> resultados = []; // Almacena los resultados de la búsqueda

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;

  // Controlador para el campo de texto de búsqueda
  TextEditingController busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicialización de servicios
    initializeServices();
    _loadSavedBusqueda(); // Cargar la búsqueda guardada
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
    personaService = PersonaService(httpService: httpService); // Inicializar el servicio de Persona
  }

  // Cargar la búsqueda guardada en shared_preferences
  Future<void> _loadSavedBusqueda() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedBusqueda = prefs.getString('busqueda');
    if (savedBusqueda != null) {
      setState(() {
        busquedaController.text = savedBusqueda; // Asignar el valor cargado al controlador
      });
    }
  }

  // Guardar la búsqueda en shared_preferences
  Future<void> _saveBusqueda() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('busqueda', busquedaController.text); // Guardar la búsqueda actual
  }

  // Método para buscar personas por coincidencia de cédula o expediente
  void buscarPersonas() async {
    try {
      List<Map<String, dynamic>> resultado = await personaService.buscarPersonasPorCedulaOExpediente(busquedaController.text);

      if (resultado.isNotEmpty) {
        setState(() {
          resultados = resultado; // Almacenar los resultados de la búsqueda
        });
        print('Personas encontradas: $resultado');

        // Guardar la búsqueda en SharedPreferences solo al buscar
        await _saveBusqueda();

        // Navegar a la pantalla de resultados pasando los resultados obtenidos
        Navigator.pushNamed(
          context,
          '/captacion_resultado_busqueda',
          arguments: resultados, // Pasar los resultados como lista de mapas
        );
      } else {
        // Manejar si no se encuentran personas
        print('No se encontraron personas con los datos proporcionados');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron resultados.')));
      }
    } catch (e) {
      print('Error al buscar personas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al buscar personas.')));
    }
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
              Navigator.pushNamed(context, '/home');
            },
          ),
        ),
        title: const EncabezadoBienvenida(), // Título reutilizado
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
                  const SizedBox(height: 20),

                  // Título de búsqueda con el ícono de lupa, ajustado hacia la izquierda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.search, color: Color(0xFF00BCD4)), // Ícono de lupa con color #00BCD4
                      SizedBox(width: 10),
                      Text(
                        'Búsqueda de persona',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF00BCD4), // Color del texto
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Botones de selección "Recién Nacido" y "Desconocido", centrados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centrados
                    children: [
                      SizedBox(
                        width: 150, // Fijando el ancho para ambos botones
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              seleccion = 'Recién Nacido';
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: Color(0xFF00BCD4), width: 2),
                            ),
                            color: seleccion == 'Recién Nacido'
                                ? Color(0xFFEAF9FF)
                                : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Column(
                                children: const [
                                  Icon(Icons.child_care,
                                      color: Color(0xFF00BCD4)),
                                  SizedBox(height: 5),
                                  Text(
                                    'Recién Nacido',
                                    style:
                                        TextStyle(color: Color(0xFF00BCD4)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              seleccion = 'Desconocido';
                              // Navegación hacia la pantalla captacion_busqueda_por_nombre
                              Navigator.pushNamed(
                                  context, '/captacion_busqueda_por_nombre');
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: Color(0xFF00BCD4), width: 2),
                            ),
                            color: seleccion == 'Desconocido'
                                ? Color(0xFFEAF9FF)
                                : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Column(
                                children: const [
                                  Icon(Icons.person_outline,
                                      color: Color(0xFF00BCD4)),
                                  SizedBox(height: 5),
                                  Text(
                                    'Desconocido',
                                    style:
                                        TextStyle(color: Color(0xFF00BCD4)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Campo de texto para número de identificación o código de expediente
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Escribe N° de identificación, Cód. de expediente único',
                      hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                      ),
                    ),
                    controller: busquedaController, // Usar el controlador persistente
                  ),
                  const SizedBox(height: 10),

                  // Nota de asterisco
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* La búsqueda por nombre se habilita con un botón.',
                      style: TextStyle(color: Color(0xFFBDC3C7)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón Buscar con color de fondo 00BCD4
                  ElevatedButton(
                    onPressed: buscarPersonas, // Ejecutar búsqueda por cédula o expediente
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      backgroundColor: const Color(0xFF00BCD4), // Fondo del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'BUSCAR',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VersionWidget(), // Widget de la versión reutilizado
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CaptacionBusquedaPersona(),
    debugShowCheckedModeBanner: false,
  ));
}
