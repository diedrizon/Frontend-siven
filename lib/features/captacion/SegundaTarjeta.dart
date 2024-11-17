// lib/widgets/segunda_tarjeta.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart';
import 'package:siven_app/core/services/CondicionPersonaService.dart';
import 'package:siven_app/core/services/SitioExposicionService.dart';
import 'package:siven_app/core/services/LugarIngresoPaisService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';

class SegundaTarjeta extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final LugarCaptacionService lugarCaptacionService;
  final CondicionPersonaService condicionPersonaService;
  final SitioExposicionService sitioExposicionService;
  final LugarIngresoPaisService lugarIngresoPaisService;

  const SegundaTarjeta({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
    required this.lugarCaptacionService,
    required this.condicionPersonaService,
    required this.sitioExposicionService,
    required this.lugarIngresoPaisService,
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
  final TextEditingController personaCaptadaController = TextEditingController();
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

  bool _presentaSintomas = false;
  bool _fueReferido = false;
  bool _esViajero = false;

  @override
  void initState() {
    super.initState();
    // Cargar todas las listas de Dropdown
    fetchLugaresCaptacion();
    fetchCondicionesPersona();
    fetchSitiosExposicion();
    fetchLugarIngresoPais();

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
    personaCaptadaController.dispose();
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
                      color: const Color(0xFF00C1D4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
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
                      color: Color(0xFF00C1D4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Lugar de Captación
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lugar de Captación *',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  isLoadingLugares
                      ? const Center(child: CircularProgressIndicator())
                      : errorLugares != null
                          ? Text(
                              errorLugares!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedLugarCaptacionId,
                              decoration: InputDecoration(
                                hintText: 'Selecciona un lugar de captación',
                                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00C1D4)),
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
                            ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Condición de la Persona
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Condición de la Persona *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  isLoadingCondiciones
                      ? const Center(child: CircularProgressIndicator())
                      : errorCondiciones != null
                          ? Text(
                              errorCondiciones!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedCondicionPersonaId,
                              decoration: InputDecoration(
                                hintText: 'Selecciona una condición',
                                prefixIcon: const Icon(Icons.health_and_safety, color: Color(0xFF00C1D4)),
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
                            ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Captación
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de Captación *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: fechaCaptacionController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Selecciona la fecha de captación',
                      prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C1D4)),
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
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          fechaCaptacionController.text = "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Semana Epidemiológica
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Semana Epidemiológica *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: semanaEpidemiologicaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ingresa la semana epidemiológica',
                      prefixIcon: const Icon(Icons.calendar_view_week, color: Color(0xFF00C1D4)),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // Puedes agregar un RangeTextInputFormatter si es necesario
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: SILAIS de Captación
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
                  DropdownButtonFormField<String>(
                    value: silaisCaptacionController.text.isNotEmpty
                        ? silaisCaptacionController.text
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Selecciona un SILAIS',
                      prefixIcon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
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
                    items: ['SILAIS - ESTELÍ', 'SILAIS - LEÓN', 'SILAIS - MANAGUA'].map((String silais) {
                      return DropdownMenuItem<String>(
                        value: silais,
                        child: Text(silais),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      setState(() {
                        silaisCaptacionController.text = selected ?? '';
                      });
                      print('SILAIS de Captación seleccionado: ${silaisCaptacionController.text}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Establecimiento de Captación
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Establecimiento de Captación *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: establecimientoCaptacionController.text.isNotEmpty
                        ? establecimientoCaptacionController.text
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Selecciona un establecimiento',
                      prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF00C1D4)),
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
                    items: [
                      'Hospital Nacional de Niños',
                      'Centro de Salud Masaya',
                      'Hospital Regional de León'
                    ].map((String establecimiento) {
                      return DropdownMenuItem<String>(
                        value: establecimiento,
                        child: Text(establecimiento),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      setState(() {
                        establecimientoCaptacionController.text = selected ?? '';
                      });
                      print('Establecimiento de Captación seleccionado: ${establecimientoCaptacionController.text}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Persona que Captó
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Persona que Captó *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: personaCaptadaController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa el nombre de la persona que captó',
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF00C1D4)),
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Sitio de Exposición
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sitio de Exposición *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  isLoadingSitios
                      ? const Center(child: CircularProgressIndicator())
                      : errorSitios != null
                          ? Text(
                              errorSitios!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedSitioExposicionId,
                              decoration: InputDecoration(
                                hintText: 'Selecciona un sitio de exposición',
                                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00C1D4)),
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
                            ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Latitud de Ocurrencia
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latitud de Ocurrencia *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: latitudOcurrenciaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Ingresa la latitud',
                      prefixIcon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Longitud de Ocurrencia
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Longitud de Ocurrencia *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: longitudOcurrenciaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Ingresa la longitud',
                      prefixIcon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: ¿Presenta Síntomas?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Presenta Síntomas? *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: presentaSintomasController.text.isNotEmpty
                        ? presentaSintomasController.text
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Selecciona una opción',
                      prefixIcon: const Icon(Icons.medical_services, color: Color(0xFF00C1D4)),
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
                        }
                      });
                      print('¿Presenta Síntomas? seleccionado: ${presentaSintomasController.text}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Inicio de Síntomas (Condicional)
              if (_presentaSintomas) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de Inicio de Síntomas *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: fechaInicioSintomasController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Selecciona la fecha de inicio de síntomas',
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C1D4)),
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
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            fechaInicioSintomasController.text = "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo: Síntomas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Síntomas *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: sintomasController.text.isNotEmpty
                          ? sintomasController.text
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Selecciona los síntomas',
                        prefixIcon: const Icon(Icons.emoji_people, color: Color(0xFF00C1D4)),
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
                      items: ['Fiebre', 'Tos', 'Dolor de Cabeza', 'Otro'].map((String sintoma) {
                        return DropdownMenuItem<String>(
                          value: sintoma,
                          child: Text(sintoma),
                        );
                      }).toList(),
                      onChanged: (selected) {
                        setState(() {
                          sintomasController.text = selected ?? '';
                        });
                        print('Síntoma seleccionado: ${sintomasController.text}');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Campo: ¿Fue Referido?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Fue Referido? *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: fueReferidoController.text.isNotEmpty
                        ? fueReferidoController.text
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Selecciona una opción',
                      prefixIcon: const Icon(Icons.assignment_return, color: Color(0xFF00C1D4)),
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
                        }
                      });
                      print('¿Fue Referido? seleccionado: ${fueReferidoController.text}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: SILAIS de Traslado (Condicional)
              if (_fueReferido) ...[
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
                    DropdownButtonFormField<String>(
                      value: silaisTrasladoController.text.isNotEmpty
                          ? silaisTrasladoController.text
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Selecciona un SILAIS',
                        prefixIcon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
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
                      items: ['SILAIS - ESTELÍ', 'SILAIS - LEÓN', 'SILAIS - MANAGUA'].map((String silais) {
                        return DropdownMenuItem<String>(
                          value: silais,
                          child: Text(silais),
                        );
                      }).toList(),
                      onChanged: (selected) {
                        setState(() {
                          silaisTrasladoController.text = selected ?? '';
                        });
                        print('SILAIS de Traslado seleccionado: ${silaisTrasladoController.text}');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo: Establecimiento de Traslado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Establecimiento de Traslado *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: establecimientoTrasladoController.text.isNotEmpty
                          ? establecimientoTrasladoController.text
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Selecciona un establecimiento',
                        prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF00C1D4)),
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
                      items: [
                        'Hospital Regional de Masaya',
                        'Centro de Salud Jinotega',
                        'Hospital Nacional San Juan de Dios'
                      ].map((String establecimiento) {
                        return DropdownMenuItem<String>(
                          value: establecimiento,
                          child: Text(establecimiento),
                        );
                      }).toList(),
                      onChanged: (selected) {
                        setState(() {
                          establecimientoTrasladoController.text = selected ?? '';
                        });
                        print('Establecimiento de Traslado seleccionado: ${establecimientoTrasladoController.text}');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Campo: ¿Es Viajero?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Es Viajero? *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: esViajeroController.text.isNotEmpty
                        ? esViajeroController.text
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Selecciona una opción',
                      prefixIcon: const Icon(Icons.airplanemode_active, color: Color(0xFF00C1D4)),
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Ingreso al País (Condicional)
              if (_esViajero) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de Ingreso al País *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: fechaIngresoPaisController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Selecciona la fecha de ingreso al país',
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C1D4)),
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
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            fechaIngresoPaisController.text = "${pickedDate.toLocal()}".split(' ')[0];
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo: Lugar de Ingreso al País
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lugar de Ingreso al País *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    isLoadingIngresoPais
                        ? const Center(child: CircularProgressIndicator())
                        : errorIngresoPais != null
                            ? Text(
                                errorIngresoPais!,
                                style: const TextStyle(color: Colors.red),
                              )
                            : DropdownButtonFormField<String>(
                                value: selectedLugarIngresoPaisId,
                                decoration: InputDecoration(
                                  hintText: 'Selecciona un lugar de ingreso al país',
                                  prefixIcon: const Icon(Icons.flag, color: Color(0xFF00C1D4)),
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
                              ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Campo: Observaciones de Captación
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observaciones de Captación',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: observacionesCaptacionController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa cualquier observación',
                      prefixIcon: const Icon(Icons.notes, color: Color(0xFF00C1D4)),
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
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
