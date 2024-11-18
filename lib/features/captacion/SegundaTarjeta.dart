// lib/widgets/segunda_tarjeta.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart';
import 'package:siven_app/core/services/CondicionPersonaService.dart';
import 'package:siven_app/core/services/SitioExposicionService.dart';
import 'package:siven_app/core/services/LugarIngresoPaisService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/SintomasService.dart'; // Importar SintomasService
import 'package:siven_app/widgets/MapSelectionScreen.dart'; // Importar MapSelectionScreen
import 'package:siven_app/widgets/seleccion_red_servicio_trabajador_widget.dart';
import 'package:siven_app/widgets/search_persona_widget.dart';

class SegundaTarjeta extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final LugarCaptacionService lugarCaptacionService;
  final CondicionPersonaService condicionPersonaService;
  final SitioExposicionService sitioExposicionService;
  final LugarIngresoPaisService lugarIngresoPaisService;
  final SintomasService sintomasService; // Añadir SintomasService

  const SegundaTarjeta({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
    required this.lugarCaptacionService,
    required this.condicionPersonaService,
    required this.sitioExposicionService,
    required this.lugarIngresoPaisService,
    required this.sintomasService, // Añadir al constructor
  }) : super(key: key);

  @override
  _SegundaTarjetaState createState() => _SegundaTarjetaState();
}

class _SegundaTarjetaState extends State<SegundaTarjeta> {
  // Controladores de texto
  final TextEditingController lugarCaptacionController = TextEditingController();
  final TextEditingController condicionPersonaController = TextEditingController();
  final TextEditingController fechaCaptacionController = TextEditingController();
  final TextEditingController semanaEpidemiologicaController = TextEditingController();
  final TextEditingController silaisCaptacionController = TextEditingController();
  final TextEditingController establecimientoCaptacionController = TextEditingController();
  final TextEditingController sitioExposicionController = TextEditingController();
  final TextEditingController latitudOcurrenciaController = TextEditingController();
  final TextEditingController longitudOcurrenciaController = TextEditingController();
  final TextEditingController presentaSintomasController = TextEditingController();
  final TextEditingController fechaInicioSintomasController = TextEditingController();
  final TextEditingController sintomasController = TextEditingController();
  final TextEditingController fueReferidoController = TextEditingController();
  final TextEditingController silaisTrasladoController = TextEditingController();
  final TextEditingController establecimientoTrasladoController = TextEditingController();
  final TextEditingController esViajeroController = TextEditingController();
  final TextEditingController fechaIngresoPaisController = TextEditingController();
  final TextEditingController lugarIngresoPaisController = TextEditingController();
  final TextEditingController observacionesCaptacionController = TextEditingController();

  // Variables de estado para manejar dinámicamente las selecciones
  List<Map<String, dynamic>> lugaresCaptacion = [];
  String? selectedLugarCaptacionId;
  bool isLoadingLugares = true;
  String? errorLugares;

  List<Map<String, dynamic>> condicionesPersona = [];
  String? selectedCondicionPersonaId;
  bool isLoadingCondiciones = true;
  String? errorCondiciones;

  List<Map<String, dynamic>> sitiosExposicion = [];
  String? selectedSitioExposicionId;
  bool isLoadingSitios = true;
  String? errorSitios;

  List<Map<String, dynamic>> lugaresIngresoPais = [];
  String? selectedLugarIngresoPaisId;
  bool isLoadingIngresoPais = true;
  String? errorIngresoPais;

  // Variables para Síntomas
  List<Map<String, dynamic>> sintomas = [];
  int? selectedSintomaId;
  bool isLoadingSintomas = true;
  String? errorSintomas;

  bool _presentaSintomas = false;
  bool _fueReferido = false;
  bool _esViajero = false;

  // Variables para almacenar los IDs seleccionados para Captación y Traslado
  String? selectedSILAISCaptacionId;
  String? selectedEstablecimientoCaptacionId;

  String? selectedSILAISTrasladoId;
  String? selectedEstablecimientoTrasladoId;

  // Variable para almacenar el ID de la persona que captó
  // Ignoramos la advertencia temporalmente si es necesario
  // ignore: unused_field
  int? _personaCaptadaId;

  @override
  void initState() {
    super.initState();
    // Cargar todas las listas de Dropdown
    fetchLugaresCaptacion();
    fetchCondicionesPersona();
    fetchSitiosExposicion();
    fetchLugarIngresoPais();
    fetchSintomas(); // Obtener síntomas

    // Listeners para actualizaciones dinámicas
    presentaSintomasController.addListener(_actualizarPresentaSintomas);
    fueReferidoController.addListener(_actualizarFueReferido);
    esViajeroController.addListener(_actualizarEsViajero);
  }

  @override
  void dispose() {
    // Dispose de los controladores
    lugarCaptacionController.dispose();
    condicionPersonaController.dispose();
    fechaCaptacionController.dispose();
    semanaEpidemiologicaController.dispose();
    silaisCaptacionController.dispose();
    establecimientoCaptacionController.dispose();
    sitioExposicionController.dispose();
    latitudOcurrenciaController.dispose();
    longitudOcurrenciaController.dispose();
    presentaSintomasController.removeListener(_actualizarPresentaSintomas);
    presentaSintomasController.dispose();
    fechaInicioSintomasController.dispose();
    sintomasController.dispose();
    fueReferidoController.removeListener(_actualizarFueReferido);
    fueReferidoController.dispose();
    silaisTrasladoController.dispose();
    establecimientoTrasladoController.dispose();
    esViajeroController.removeListener(_actualizarEsViajero);
    esViajeroController.dispose();
    fechaIngresoPaisController.dispose();
    lugarIngresoPaisController.dispose();
    observacionesCaptacionController.dispose();
    super.dispose();
  }

  // Función para actualizar el estado según si presenta síntomas
  void _actualizarPresentaSintomas() {
    setState(() {
      _presentaSintomas = presentaSintomasController.text == 'Sí';
    });
  }

  // Función para actualizar el estado según si fue referido
  void _actualizarFueReferido() {
    setState(() {
      _fueReferido = fueReferidoController.text == 'Sí';
    });
  }

  // Función para actualizar el estado según si es viajero
  void _actualizarEsViajero() {
    setState(() {
      _esViajero = esViajeroController.text == 'Sí';
    });
  }

  // Funciones para obtener datos de los servicios
  Future<void> fetchLugaresCaptacion() async {
    try {
      final lugares = await widget.lugarCaptacionService.listarLugaresCaptacion();
      if (mounted) {
        setState(() {
          lugaresCaptacion = lugares
              .map((e) => {'id': e['id_lugar_captacion'], 'nombre': e['nombre']})
              .toList();
          isLoadingLugares = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorLugares = 'Error al cargar lugares de captación: $e';
          isLoadingLugares = false;
        });
      }
    }
  }

  Future<void> fetchCondicionesPersona() async {
    try {
      final condiciones = await widget.condicionPersonaService.listarCondicionesPersona();
      if (mounted) {
        setState(() {
          condicionesPersona = condiciones
              .map((e) => {'id': e['id_condicion_persona'], 'nombre': e['nombre']})
              .toList();
          isLoadingCondiciones = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorCondiciones = 'Error al cargar condiciones de persona: $e';
          isLoadingCondiciones = false;
        });
      }
    }
  }

  Future<void> fetchSitiosExposicion() async {
    try {
      final sitios = await widget.sitioExposicionService.listarSitiosExposicion();
      if (mounted) {
        setState(() {
          sitiosExposicion = sitios
              .map((e) => {'id': e['id_sitio_exposicion'], 'nombre': e['nombre']})
              .toList();
          isLoadingSitios = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorSitios = 'Error al cargar sitios de exposición: $e';
          isLoadingSitios = false;
        });
      }
    }
  }

  Future<void> fetchLugarIngresoPais() async {
    try {
      final lugares = await widget.lugarIngresoPaisService.listarLugarIngresoPais();
      if (mounted) {
        setState(() {
          lugaresIngresoPais = lugares
              .map((e) => {'id': e['id_lugar_ingreso_pais'], 'nombre': e['nombre']})
              .toList();
          isLoadingIngresoPais = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorIngresoPais = 'Error al cargar lugares de ingreso por país: $e';
          isLoadingIngresoPais = false;
        });
      }
    }
  }

  // Función para obtener los síntomas desde el servicio
  Future<void> fetchSintomas() async {
    try {
      final fetchedSintomas = await widget.sintomasService.listarSintomas();
      if (mounted) {
        setState(() {
          sintomas = fetchedSintomas
              .where((sintoma) => sintoma['activo'] == 1)
              .map((e) => {'id': e['id_sintomas'], 'nombre': e['nombre']})
              .toList();
          isLoadingSintomas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorSintomas = 'Error al cargar síntomas: $e';
          isLoadingSintomas = false;
        });
      }
    }
  }

  // Función para abrir el diálogo de selección para Captación
  Future<void> _abrirDialogoSeleccionRedServicioCaptacion() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SeleccionRedServicioTrabajadorWidget(
            catalogService: widget.catalogService,
            selectionStorageService: widget.selectionStorageService,
          ),
        );
      },
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        silaisCaptacionController.text = result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoCaptacionController.text = result['establecimiento'] ?? 'Establecimiento no seleccionado';
        selectedSILAISCaptacionId = result['silaisId'];
        selectedEstablecimientoCaptacionId = result['establecimientoId'];
      });

      // Imprimir los IDs seleccionados
      print('ID seleccionado SILAIS Captación: $selectedSILAISCaptacionId');
      print('ID seleccionado Establecimiento Captación: $selectedEstablecimientoCaptacionId');
    }
  }

  // Función para abrir el diálogo de selección para Traslado
  Future<void> _abrirDialogoSeleccionRedServicioTraslado() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SeleccionRedServicioTrabajadorWidget(
            catalogService: widget.catalogService,
            selectionStorageService: widget.selectionStorageService,
          ),
        );
      },
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        silaisTrasladoController.text = result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoTrasladoController.text = result['establecimiento'] ?? 'Establecimiento no seleccionado';
        selectedSILAISTrasladoId = result['silaisId'];
        selectedEstablecimientoTrasladoId = result['establecimientoId'];
      });

      // Imprimir los IDs seleccionados
      print('ID seleccionado SILAIS Traslado: $selectedSILAISTrasladoId');
      print('ID seleccionado Establecimiento Traslado: $selectedEstablecimientoTrasladoId');
    }
  }

  // Función para abrir la pantalla de selección de ubicación
  Future<void> _abrirSeleccionUbicacion({required bool isLatitude}) async {

   
    await Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => MapSelectionScreen(
      onLocationSelected: (LatLng location) {
        setState(() {
          latitudOcurrenciaController.text = location.latitude.toStringAsFixed(6);
          longitudOcurrenciaController.text = location.longitude.toStringAsFixed(6);
        });
        print(
            'Ubicación seleccionada: Latitud=${location.latitude}, Longitud=${location.longitude}');
      },
    ),
  ),
);


    // Hacer los campos de solo lectura después de la selección
    if (isLatitude) {
      setState(() {
        latitudOcurrenciaController.text = latitudOcurrenciaController.text;
      });
    } else {
      setState(() {
        longitudOcurrenciaController.text = longitudOcurrenciaController.text;
      });
    }
  }

  // Método auxiliar para construir campos de texto con ícono de mapa
  Widget buildTextFieldWithMapIcon({
    required String label,
    required TextEditingController controller,
    required bool isLatitude,
    String? hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true, // Hacer de solo lectura para evitar modificaciones manuales
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF00C1D4)) : null,
            suffixIcon: IconButton(
              icon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
              onPressed: () => _abrirSeleccionUbicacion(isLatitude: isLatitude),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00C1D4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00C1D4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00C1D4)),
            ),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          enabled: enabled,
          maxLines: maxLines,
        ),
      ],
    );
  }

  // Método auxiliar para construir campos de texto
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF00C1D4)) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00C1D4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00C1D4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00C1D4)),
            ),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          enabled: enabled,
          maxLines: maxLines,
        ),
      ],
    );
  }

  // Método auxiliar para construir campos desplegables
  Widget buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>>? items,
    required ValueChanged<String?> onChanged,
    String? hintText,
    IconData? prefixIcon,
    bool isLoading = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorText != null
                ? Text(
                    errorText,
                    style: const TextStyle(color: Colors.red),
                  )
                : DropdownButtonFormField<String>(
                    value: value,
                    decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon:
                          prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF00C1D4)) : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                    ),
                    items: items,
                    onChanged: onChanged,
                  ),
      ],
    );
  }

  // Método auxiliar para construir campos de selección de fecha
  Widget buildDatePickerField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return buildTextField(
      label: label,
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0];
            // Calcular y establecer la semana epidemiológica
            semanaEpidemiologicaController.text = calcularSemanaEpidemiologica(pickedDate).toString();
          });
        }
      },
    );
  }

  // Función para calcular la semana epidemiológica
  int calcularSemanaEpidemiologica(DateTime fecha) {
    // Ajustar la fecha al jueves de la semana
    DateTime jueves = fecha.add(Duration(days: 4 - fecha.weekday));

    // Fecha del primer jueves del año
    DateTime primerJueves = DateTime(fecha.year, 1, 4);
    while (primerJueves.weekday != DateTime.thursday) {
      primerJueves = primerJueves.add(Duration(days: 1));
    }

    // Calcular la diferencia en días y luego en semanas
    int diferenciaDias = jueves.difference(primerJueves).inDays;
    int semana = 1 + (diferenciaDias ~/ 7);

    // Asegurarse de que la semana esté en el rango correcto
    if (semana < 1) {
      // Puede pertenecer a la última semana del año anterior
      // Aquí puedes manejar este caso si es necesario
      semana = 1; // Por simplicidad, asignamos 1
    } else if (semana > 53) {
      semana = 53;
    }

    return semana;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF00C1D4), width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Asegura que el contenido sea scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la Tarjeta
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C1D4), // Fondo celeste
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white, // Texto blanco
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Datos de Captación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C1D4), // Texto celeste
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Lugar de Captación
              buildDropdownField(
                label: 'Lugar de Captación *',
                value: selectedLugarCaptacionId,
                items: lugaresCaptacion.map((e) {
                  return DropdownMenuItem<String>(
                    value: e['id'].toString(),
                    child: Text(e['nombre']),
                  );
                }).toList(),
                onChanged: (selectedId) {
                  setState(() {
                    selectedLugarCaptacionId = selectedId;
                    lugarCaptacionController.text = lugaresCaptacion
                        .firstWhere((lugar) => lugar['id'].toString() == selectedId)['nombre']
                        .toString();
                  });
                  print('ID seleccionado Lugar de Captación: $selectedLugarCaptacionId');
                },
                hintText: 'Selecciona un lugar de captación',
                prefixIcon: Icons.location_on,
                isLoading: isLoadingLugares,
                errorText: errorLugares,
              ),
              const SizedBox(height: 20),

              // Campo: Condición de la Persona
              buildDropdownField(
                label: 'Condición de la Persona *',
                value: selectedCondicionPersonaId,
                items: condicionesPersona.map((e) {
                  return DropdownMenuItem<String>(
                    value: e['id'].toString(),
                    child: Text(e['nombre']),
                  );
                }).toList(),
                onChanged: (selectedId) {
                  setState(() {
                    selectedCondicionPersonaId = selectedId;
                    condicionPersonaController.text = condicionesPersona
                        .firstWhere((condicion) => condicion['id'].toString() == selectedId)['nombre']
                        .toString();
                  });
                  print('ID seleccionado Condición Persona: $selectedCondicionPersonaId');
                },
                hintText: 'Selecciona una condición',
                prefixIcon: Icons.health_and_safety,
                isLoading: isLoadingCondiciones,
                errorText: errorCondiciones,
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Captación
              buildDatePickerField(
                label: 'Fecha de Captación *',
                controller: fechaCaptacionController,
                hintText: 'Selecciona la fecha de captación',
                prefixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              // Campo: Semana Epidemiológica
              buildTextField(
                label: 'Semana Epidemiológica *',
                controller: semanaEpidemiologicaController,
                hintText: 'Semana calculada automáticamente',
                prefixIcon: Icons.calendar_view_week,
                readOnly: true, // Hacerlo de solo lectura
              ),
              const SizedBox(height: 20),

              // Campo: SILAIS de Captación con Icono de Búsqueda
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SILAIS de Captación *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 55.0,
                    child: Stack(
                      children: [
                        TextField(
                          controller: silaisCaptacionController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Selecciona un SILAIS',
                            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                            prefixIcon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C1D4),
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C1D4),
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C1D4),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
                            onPressed: _abrirDialogoSeleccionRedServicioCaptacion,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Establecimiento de Captación
              buildTextField(
                label: 'Establecimiento de Captación *',
                controller: establecimientoCaptacionController,
                hintText: 'Selecciona un establecimiento',
                prefixIcon: Icons.local_hospital,
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // Campo: Persona que Captó (Reemplazado por SearchPersonaWidget)
              SearchPersonaWidget(
                onPersonaSelected: (int idPersona) {
                  setState(() {
                    _personaCaptadaId = idPersona;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Campo: ¿Fue Referido?
              buildDropdownField(
                label: '¿Fue Referido? *',
                value: fueReferidoController.text.isNotEmpty ? fueReferidoController.text : null,
                items: ['Sí', 'No'].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (selected) {
                  setState(() {
                    fueReferidoController.text = selected ?? '';
                    _fueReferido = selected == 'Sí';
                    if (!_fueReferido) {
                      silaisTrasladoController.clear();
                      establecimientoTrasladoController.clear();
                      // También limpiar los campos relacionados con Traslado si es necesario
                    }
                  });
                  print('¿Fue Referido? seleccionado: ${fueReferidoController.text}');
                },
                hintText: 'Selecciona una opción',
                prefixIcon: Icons.assignment_return,
              ),
              const SizedBox(height: 20),

              // Campos de Traslado (Condicional)
              if (_fueReferido) ...[
                // Campo: SILAIS de Traslado con Icono de Búsqueda
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SILAIS de Traslado *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 55.0,
                      child: Stack(
                        children: [
                          TextField(
                            controller: silaisTrasladoController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Selecciona un SILAIS',
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                              prefixIcon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C1D4),
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C1D4),
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C1D4),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
                              onPressed: _abrirDialogoSeleccionRedServicioTraslado,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo: Establecimiento de Traslado
                buildTextField(
                  label: 'Establecimiento de Traslado *',
                  controller: establecimientoTrasladoController,
                  hintText: 'Selecciona un establecimiento',
                  prefixIcon: Icons.local_hospital,
                  readOnly: true,
                ),
                const SizedBox(height: 20),
              ],

              // Campo: Sitio de Exposición
              buildDropdownField(
                label: 'Sitio de Exposición *',
                value: selectedSitioExposicionId,
                items: sitiosExposicion.map((e) {
                  return DropdownMenuItem<String>(
                    value: e['id'].toString(),
                    child: Text(e['nombre']),
                  );
                }).toList(),
                onChanged: (selectedId) {
                  setState(() {
                    selectedSitioExposicionId = selectedId;
                    sitioExposicionController.text = sitiosExposicion
                        .firstWhere((sitio) => sitio['id'].toString() == selectedId)['nombre']
                        .toString();
                  });
                  print('ID seleccionado Sitio de Exposición: $selectedSitioExposicionId');
                },
                hintText: 'Selecciona un sitio de exposición',
                prefixIcon: Icons.location_on,
                isLoading: isLoadingSitios,
                errorText: errorSitios,
              ),
              const SizedBox(height: 20),

              // Campo: Latitud de Ocurrencia con Ícono de Mapa
              buildTextFieldWithMapIcon(
                label: 'Latitud de Ocurrencia *',
                controller: latitudOcurrenciaController,
                isLatitude: true,
                hintText: 'Ingresa la latitud',
                prefixIcon: Icons.map,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Longitud de Ocurrencia con Ícono de Mapa
              buildTextFieldWithMapIcon(
                label: 'Longitud de Ocurrencia *',
                controller: longitudOcurrenciaController,
                isLatitude: false,
                hintText: 'Ingresa la longitud',
                prefixIcon: Icons.map,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: ¿Presenta Síntomas?
              buildDropdownField(
                label: '¿Presenta Síntomas? *',
                value: presentaSintomasController.text.isNotEmpty ? presentaSintomasController.text : null,
                items: ['Sí', 'No'].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (selected) {
                  setState(() {
                    presentaSintomasController.text = selected ?? '';
                    _presentaSintomas = selected == 'Sí';
                    if (!_presentaSintomas) {
                      fechaInicioSintomasController.clear();
                      sintomasController.clear();
                      selectedSintomaId = null; // Limpiar selección de síntoma
                    }
                  });
                  print('¿Presenta Síntomas? seleccionado: ${presentaSintomasController.text}');
                },
                hintText: 'Selecciona una opción',
                prefixIcon: Icons.medical_services,
              ),
              const SizedBox(height: 20),

              // Campos de Síntomas (Condicional)
              if (_presentaSintomas) ...[
                // Campo: Fecha de Inicio de Síntomas
                buildDatePickerField(
                  label: 'Fecha de Inicio de Síntomas *',
                  controller: fechaInicioSintomasController,
                  hintText: 'Selecciona la fecha de inicio de síntomas',
                  prefixIcon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),

                // Campo: Síntomas
                buildDropdownField(
                  label: 'Síntomas *',
                  value: selectedSintomaId != null ? selectedSintomaId.toString() : null,
                  items: sintomas.map((e) {
                    return DropdownMenuItem<String>(
                      value: e['id'].toString(),
                      child: Text(e['nombre']),
                    );
                  }).toList(),
                  onChanged: (selectedIdStr) {
                    setState(() {
                      selectedSintomaId = selectedIdStr != null ? int.parse(selectedIdStr) : null;
                      sintomasController.text = selectedSintomaId != null
                          ? sintomas.firstWhere((s) => s['id'] == selectedSintomaId)['nombre']
                          : '';
                    });
                    print('Síntoma seleccionado ID: $selectedSintomaId');
                  },
                  hintText: 'Selecciona los síntomas',
                  prefixIcon: Icons.emoji_people,
                  isLoading: isLoadingSintomas,
                  errorText: errorSintomas,
                ),
                const SizedBox(height: 20),
              ],

              // Campo: ¿Es Viajero?
              buildDropdownField(
                label: '¿Es Viajero? *',
                value: esViajeroController.text.isNotEmpty ? esViajeroController.text : null,
                items: ['Sí', 'No'].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (selected) {
                  setState(() {
                    esViajeroController.text = selected ?? '';
                    _esViajero = selected == 'Sí';
                    if (!_esViajero) {
                      fechaIngresoPaisController.clear();
                      lugarIngresoPaisController.clear();
                    }
                  });
                  print('¿Es Viajero? seleccionado: ${esViajeroController.text}');
                },
                hintText: 'Selecciona una opción',
                prefixIcon: Icons.airplanemode_active,
              ),
              const SizedBox(height: 20),

              // Campos de Viajero (Condicional)
              if (_esViajero) ...[
                // Campo: Fecha de Ingreso al País
                buildDatePickerField(
                  label: 'Fecha de Ingreso al País *',
                  controller: fechaIngresoPaisController,
                  hintText: 'Selecciona la fecha de ingreso al país',
                  prefixIcon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),

                // Campo: Lugar de Ingreso al País
                buildDropdownField(
                  label: 'Lugar de Ingreso al País *',
                  value: selectedLugarIngresoPaisId,
                  items: lugaresIngresoPais.map((e) {
                    return DropdownMenuItem<String>(
                      value: e['id'].toString(),
                      child: Text(e['nombre']),
                    );
                  }).toList(),
                  onChanged: (selectedId) {
                    setState(() {
                      selectedLugarIngresoPaisId = selectedId;
                      lugarIngresoPaisController.text = lugaresIngresoPais
                          .firstWhere((lugar) => lugar['id'].toString() == selectedId)['nombre']
                          .toString();
                    });
                    print('ID seleccionado Lugar de Ingreso al País: $selectedLugarIngresoPaisId');
                  },
                  hintText: 'Selecciona un lugar de ingreso al país',
                  prefixIcon: Icons.flag,
                  isLoading: isLoadingIngresoPais,
                  errorText: errorIngresoPais,
                ),
                const SizedBox(height: 20),
              ],

              // Campo: Observaciones de Captación
              buildTextField(
                label: 'Observaciones de Captación',
                controller: observacionesCaptacionController,
                hintText: 'Ingresa cualquier observación',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
