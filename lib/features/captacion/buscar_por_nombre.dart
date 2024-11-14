import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/PersonaService.dart';
import 'package:http/http.dart' as http;

class BusquedaPorNombreScreen extends StatefulWidget {
  const BusquedaPorNombreScreen({Key? key}) : super(key: key);

  @override
  _BusquedaPorNombreScreenState createState() => _BusquedaPorNombreScreenState();
}

class _BusquedaPorNombreScreenState extends State<BusquedaPorNombreScreen> {
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late PersonaService personaService;

  // Controladores para campos de texto
  TextEditingController primerNombreController = TextEditingController();
  TextEditingController segundoNombreController = TextEditingController();
  TextEditingController primerApellidoController = TextEditingController();
  TextEditingController segundoApellidoController = TextEditingController();

  List<Map<String, dynamic>> resultados = [];

  @override
  void initState() {
    super.initState();
    initializeServices();
    _loadSavedData();  // Cargar los datos guardados cuando se carga la pantalla
  }

  // Inicializar servicios
  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);
    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
    personaService = PersonaService(httpService: httpService);
  }

  // Cargar los datos de shared_preferences
  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      primerNombreController.text = prefs.getString('primerNombre') ?? '';
      segundoNombreController.text = prefs.getString('segundoNombre') ?? '';
      primerApellidoController.text = prefs.getString('primerApellido') ?? '';
      segundoApellidoController.text = prefs.getString('segundoApellido') ?? '';
    });
  }

  // Guardar los datos en shared_preferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('primerNombre', primerNombreController.text);
    await prefs.setString('segundoNombre', segundoNombreController.text);
    await prefs.setString('primerApellido', primerApellidoController.text);
    await prefs.setString('segundoApellido', segundoApellidoController.text);
  }

  // Método para buscar personas por coincidencia de nombre o apellido
  void buscarPorNombreOApellido() async {
    try {
      String primerNombre = primerNombreController.text.trim().toLowerCase();
      String segundoNombre = segundoNombreController.text.trim().toLowerCase();
      String primerApellido = primerApellidoController.text.trim().toLowerCase();
      String segundoApellido = segundoApellidoController.text.trim().toLowerCase();

      List<String> terminosBusqueda = [];

      if (primerNombre.isNotEmpty) terminosBusqueda.add(primerNombre);
      if (segundoNombre.isNotEmpty) terminosBusqueda.add(segundoNombre);
      if (primerApellido.isNotEmpty) terminosBusqueda.add(primerApellido);
      if (segundoApellido.isNotEmpty) terminosBusqueda.add(segundoApellido);

      if (terminosBusqueda.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe ingresar al menos un campo para realizar la búsqueda.'))
        );
        return;
      }

      List<Map<String, dynamic>> resultado = await personaService.buscarPersonasPorNombreOApellido(terminosBusqueda.join(" "));

      if (resultado.isNotEmpty) {
        setState(() {
          resultados = resultado;
        });

        Navigator.pushNamed(
          context,
          '/captacion_resultado_busqueda',
          arguments: resultados, // Se envía la lista de resultados
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron resultados.'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al buscar personas.'))
      );
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
              Navigator.pushNamed(context, '/captacion_busqeda_persona');
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.search, color: Color(0xFF00BCD4)),
                      SizedBox(width: 10),
                      Text(
                        'Búsqueda por nombre',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: primerNombreController,
                            onChanged: (value) => _saveData(), // Guardar cuando cambia
                            decoration: InputDecoration(
                              labelText: 'Primer nombre*',
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
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: primerApellidoController,
                            onChanged: (value) => _saveData(), // Guardar cuando cambia
                            decoration: InputDecoration(
                              labelText: 'Primer apellido*',
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: segundoNombreController,
                            onChanged: (value) => _saveData(), // Guardar cuando cambia
                            decoration: InputDecoration(
                              labelText: 'Segundo nombre',
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
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: segundoApellidoController,
                            onChanged: (value) => _saveData(), // Guardar cuando cambia
                            decoration: InputDecoration(
                              labelText: 'Segundo apellido',
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Los campos marcados con * son requeridos',
                    style: TextStyle(color: Color(0xFFBDC3C7)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: buscarPorNombreOApellido,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      backgroundColor: const Color(0xFF00BCD4),
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
          const VersionWidget(),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: BusquedaPorNombreScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
