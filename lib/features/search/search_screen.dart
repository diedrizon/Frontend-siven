import 'package:flutter/material.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/TextField.dart'; // Importamos el widget reutilizable
import 'package:siven_app/widgets/custom_date_field.dart'; // Importamos el nuevo widget de fecha
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para las fechas
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Controladores para Autocomplete
  final TextEditingController _silaisController = TextEditingController();
  final TextEditingController _unidadSaludController = TextEditingController();
  final TextEditingController _eventoController = TextEditingController();

  // Listas dinámicas para las opciones de los campos de búsqueda (con IDs y nombres)
  List<Map<String, dynamic>> silaisOptions = [];
  List<Map<String, dynamic>> unidadSaludOptions = [];
  List<String> eventoOptions = ['COVID-19', 'Dengue']; // Ejemplo estático

  // IDs seleccionados
  int? idSilaisSeleccionado;
  int? idUnidadSaludSeleccionado;

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;

  @override
  void initState() {
    super.initState();

    // Inicialización de servicios
    initializeServices();

    // Carga inicial de los datos
    loadCatalogData();
  }

  // Inicialización de los servicios
  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
  }

  // Método para cargar los datos de los catálogos
  Future<void> loadCatalogData() async {
    try {
      // Cargar los SILAIS desde el servicio
      silaisOptions = await catalogService.getAllSilais();

      // Inicialmente los establecimientos de salud estarán vacíos
      unidadSaludOptions = [];

      // Actualizamos el estado de la pantalla para reflejar los nuevos datos
      setState(() {});
    } catch (error) {
      print('Error al cargar los datos del catálogo: $error');
    }
  }

  // Método para cargar los establecimientos con base en el SILAIS seleccionado
  Future<void> loadEstablecimientosBySilais(int idSilais) async {
    try {
      unidadSaludOptions = await catalogService.getEstablecimientosBySilais(idSilais);

      // Actualizamos el estado de la pantalla para reflejar los nuevos datos
      setState(() {});
    } catch (error) {
      print('Error al cargar establecimientos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color salmonColor = Color(0xFFF7941D);

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
        title: const EncabezadoBienvenida(),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Uso de los widgets pasando los servicios
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
                    const SizedBox(height: 20),

                    // Texto e ícono de búsqueda
                    Row(
                      children: [
                        Icon(Icons.search, color: salmonColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Informe de evento de Salud',
                          style: TextStyle(fontSize: 18, color: salmonColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Campos de Fecha de inicio y Fecha de fin con el widget reutilizable CustomDateField
                    Row(
                      children: [
                        Expanded(
                          child: CustomDateField(
                            hintText: 'Fecha de Inicio',
                            controller: _startDateController,
                            borderColor: salmonColor,
                            iconColor: Colors.grey,
                            borderWidth: 2.0,
                            borderRadius: 5.0,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomDateField(
                            hintText: 'Fecha de Fin',
                            controller: _endDateController,
                            borderColor: salmonColor,
                            iconColor: Colors.grey,
                            borderWidth: 2.0,
                            borderRadius: 5.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Autocomplete SILAIS reutilizando el widget CustomTextFieldDropdown con datos dinámicos
                    CustomTextFieldDropdown(
                      hintText: 'SILAIS de la captación',
                      controller: _silaisController,
                      options: silaisOptions.map((silais) => silais['nombre'].toString()).toList(),
                      borderColor: salmonColor,
                      borderWidth: 2.0,
                      borderRadius: 5.0,
                      onChanged: (String? selectedValue) {
                        // Mapea el nombre seleccionado al ID correspondiente
                        final selectedSilais = silaisOptions.firstWhere(
                          (silais) => silais['nombre'] == selectedValue,
                        );

                        // Carga los establecimientos basados en el SILAIS seleccionado
                        idSilaisSeleccionado = selectedSilais['id_silais'];
                        loadEstablecimientosBySilais(idSilaisSeleccionado!);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Autocomplete Unidad de Salud reutilizando el widget CustomTextFieldDropdown con datos dinámicos
                    CustomTextFieldDropdown(
                      hintText: 'Unidad de Salud',
                      controller: _unidadSaludController,
                      options: unidadSaludOptions.map((unidad) => unidad['nombre'].toString()).toList(),
                      borderColor: salmonColor,
                      borderWidth: 2.0,
                      borderRadius: 5.0,
                      onChanged: (String? selectedValue) {
                        // Mapea el nombre seleccionado al ID correspondiente
                        final selectedUnidad = unidadSaludOptions.firstWhere(
                          (unidad) => unidad['nombre'] == selectedValue,
                        );
                        idUnidadSaludSeleccionado = selectedUnidad['id_establecimiento'];
                      },
                    ),
                    const SizedBox(height: 20),

                    // Autocomplete Evento de Salud reutilizando el widget CustomTextFieldDropdown con datos estáticos
                    CustomTextFieldDropdown(
                      hintText: 'Evento de salud',
                      controller: _eventoController,
                      options: eventoOptions,
                      borderColor: salmonColor,
                      borderWidth: 2.0,
                      borderRadius: 5.0,
                    ),
                    const SizedBox(height: 30),

                    // Botón Buscar
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Enviar las IDs seleccionadas al backend
                          Navigator.pushNamed(
                            context,
                            '/resultados_busqueda',
                            arguments: {
                              'silais': idSilaisSeleccionado.toString(), // Enviar ID SILAIS
                              'unidadSalud': idUnidadSaludSeleccionado.toString(), // Enviar ID establecimiento
                              'evento': _eventoController.text,
                              'fechaInicio': _startDateController.text,
                              'fechaFin': _endDateController.text,
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: salmonColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(200, 50),
                      ),
                      child: const Text('Buscar', style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 20),

                    // Botón Limpiar
                    TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                        _startDateController.clear();
                        _endDateController.clear();
                        _silaisController.clear();
                        _unidadSaludController.clear();
                        _eventoController.clear();
                      },
                      child: const Text(
                        'LIMPIAR',
                        style: TextStyle(fontSize: 14, color: salmonColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VersionWidget(), // Añadimos el widget de la versión en la parte inferior
        ],
      ),
    );
  }
}
