import 'package:flutter/material.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/TextField.dart'; // Importamos el widget reutilizable
import 'package:siven_app/widgets/custom_date_field.dart'; // Importamos el nuevo widget de fecha
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
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
  List<Map<String, dynamic>> eventoOptions = []; // Opciones dinámicas para eventos de salud

  // IDs seleccionados
  int? idSilaisSeleccionado;
  int? idUnidadSaludSeleccionado;
  int? idEventoSeleccionado; // Nueva variable para el ID del evento seleccionado

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late EventoSaludService eventoSaludService;

  @override
  void initState() {
    super.initState();

    // Inicialización de servicios
    initializeServices();

    // Carga inicial de los datos
    loadCatalogData();
    loadEventosSalud(); // Cargar eventos de salud

    // Agregar listeners a los controladores de fecha si es necesario
    _startDateController.addListener(_onDateChanged);
    _endDateController.addListener(_onDateChanged);
  }

  @override
  void dispose() {
    // Limpiar los controladores
    _startDateController.dispose();
    _endDateController.dispose();
    _silaisController.dispose();
    _unidadSaludController.dispose();
    _eventoController.dispose();
    super.dispose();
  }

  // Inicialización de los servicios
  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
    eventoSaludService = EventoSaludService(httpService: httpService); // Instancia de EventoSaludService
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
      // Mostrar un diálogo de error en la interfaz
      _showErrorDialog('Error al cargar los datos del catálogo.');
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
      // Mostrar un diálogo de error en la interfaz
      _showErrorDialog('Error al cargar establecimientos de salud.');
    }
  }

  // Método para cargar eventos de salud
  Future<void> loadEventosSalud() async {
    try {
      eventoOptions = await eventoSaludService.listarEventosSalud();

      // Actualizar el estado para reflejar los eventos de salud
      setState(() {});
    } catch (error) {
      print('Error al cargar eventos de salud: $error');
      // Mostrar un diálogo de error en la interfaz
      _showErrorDialog('Error al cargar eventos de salud.');
    }
  }

  // Método llamado cuando cambia una fecha
  void _onDateChanged() {
    setState(() {
      // Aquí puedes agregar lógica adicional si deseas deshabilitar el botón de búsqueda
      // Basado en las condiciones de fecha
    });
  }

  // Función de validación personalizada
  bool _validateForm() {
    // Lista para acumular mensajes de error
    List<String> errors = [];

    // Verifica que al menos uno de los campos esté lleno
    bool isStartDateFilled = _startDateController.text.isNotEmpty;
    bool isEndDateFilled = _endDateController.text.isNotEmpty;
    bool isSilaisFilled = _silaisController.text.isNotEmpty;
    bool isUnidadSaludFilled = _unidadSaludController.text.isNotEmpty;
    bool isEventoFilled = _eventoController.text.isNotEmpty;

    if (!(isStartDateFilled ||
        isEndDateFilled ||
        isSilaisFilled ||
        isUnidadSaludFilled ||
        isEventoFilled)) {
      errors.add('Debe completar al menos uno de los campos para realizar la búsqueda.');
    }

    // Validaciones de Fecha
    if (isStartDateFilled && !isEndDateFilled) {
      errors.add('Debe seleccionar una Fecha de Fin si selecciona una Fecha de Inicio.');
    }

    if (isEndDateFilled && !isStartDateFilled) {
      errors.add('Debe seleccionar una Fecha de Inicio si selecciona una Fecha de Fin.');
    }

    if (isStartDateFilled && isEndDateFilled) {
      DateTime? startDate = _parseDate(_startDateController.text);
      DateTime? endDate = _parseDate(_endDateController.text);

      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        errors.add('La Fecha de Fin no puede ser anterior a la Fecha de Inicio.');
      }
    }

    // Si hay errores, mostrar el diálogo
    if (errors.isNotEmpty) {
      _showErrorDialog(errors.join('\n'));
      return false;
    }

    // Si todo está bien, retornar true
    return true;
  }

  // Método para parsear fechas en formato 'yyyy-MM-dd' o similar, según cómo se almacenen
  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Error al parsear la fecha: $e');
      return null;
    }
  }

  // Método para mostrar un diálogo de error con diseño mejorado en naranja
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.orange[50], // Fondo suave naranja
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.orange, size: 24),
              SizedBox(width: 10),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.orange[700]),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      },
    );
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
                          'Informe de Evento de Salud',
                          style: TextStyle(
                            fontSize: 18,
                            color: salmonColor,
                            fontWeight: FontWeight.w500,
                          ),
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
                      hintText: 'SILAIS de la Captación',
                      controller: _silaisController,
                      options: silaisOptions.map((silais) => silais['nombre'].toString()).toList(),
                      borderColor: salmonColor,
                      borderWidth: 2.0,
                      borderRadius: 5.0,
                      onChanged: (String? selectedValue) {
                        if (selectedValue != null && selectedValue.isNotEmpty) {
                          final selectedSilais = silaisOptions.firstWhere(
                            (silais) => silais['nombre'] == selectedValue,
                            orElse: () => {},
                          );

                          if (selectedSilais.isNotEmpty && selectedSilais.containsKey('id_silais')) {
                            idSilaisSeleccionado = selectedSilais['id_silais'];
                            loadEstablecimientosBySilais(idSilaisSeleccionado!);
                          } else {
                            // Manejo en caso de no encontrar SILAIS
                            setState(() {
                              unidadSaludOptions = [];
                              _unidadSaludController.clear();
                              idUnidadSaludSeleccionado = null;
                            });
                          }
                        } else {
                          // Si no se selecciona ningún SILAIS, limpiar las opciones de Unidad de Salud
                          setState(() {
                            unidadSaludOptions = [];
                            _unidadSaludController.clear();
                            idUnidadSaludSeleccionado = null;
                          });
                        }
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
                        if (selectedValue != null && selectedValue.isNotEmpty) {
                          final selectedUnidad = unidadSaludOptions.firstWhere(
                            (unidad) => unidad['nombre'] == selectedValue,
                            orElse: () => {},
                          );

                          if (selectedUnidad.isNotEmpty && selectedUnidad.containsKey('id_establecimiento')) {
                            idUnidadSaludSeleccionado = selectedUnidad['id_establecimiento'];
                          } else {
                            // Manejo en caso de no encontrar Unidad de Salud
                            idUnidadSaludSeleccionado = null;
                          }
                        } else {
                          idUnidadSaludSeleccionado = null;
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Autocomplete Evento de Salud con captura del ID
                    CustomTextFieldDropdown(
                      hintText: 'Evento de Salud',
                      controller: _eventoController,
                      options: eventoOptions.map((evento) => evento['nombre'].toString()).toList(),
                      borderColor: salmonColor,
                      borderWidth: 2.0,
                      borderRadius: 5.0,
                      onChanged: (String? selectedValue) {
                        if (selectedValue != null && selectedValue.isNotEmpty) {
                          final selectedEvento = eventoOptions.firstWhere(
                            (evento) => evento['nombre'] == selectedValue,
                            orElse: () => {},
                          );

                          if (selectedEvento.isNotEmpty && selectedEvento.containsKey('id_evento_salud')) {
                            idEventoSeleccionado = selectedEvento['id_evento_salud'];
                          } else {
                            // Manejo en caso de no encontrar Evento de Salud
                            idEventoSeleccionado = null;
                          }
                        } else {
                          idEventoSeleccionado = null;
                        }
                      },
                    ),
                    const SizedBox(height: 30),

                    // Botón Buscar
                    ElevatedButton(
                      onPressed: () {
                        if (_validateForm()) {
                          Navigator.pushNamed(
                            context,
                            '/resultados_busqueda',
                            arguments: {
                              'silais': idSilaisSeleccionado?.toString() ?? '',
                              'unidadSalud': idUnidadSaludSeleccionado?.toString() ?? '',
                              'evento': idEventoSeleccionado?.toString() ?? '',
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Buscar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
                        setState(() {
                          // Reiniciar IDs seleccionados
                          idSilaisSeleccionado = null;
                          idUnidadSaludSeleccionado = null;
                          idEventoSeleccionado = null;
                          // Reiniciar las opciones de Unidad de Salud
                          unidadSaludOptions = [];
                        });
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
