import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siven_app/widgets/TextField.dart'; // Para CustomTextFieldDropdown
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart'; // Nuevo servicio para Lugar de Captación

class SegundaTarjeta extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final LugarCaptacionService lugarCaptacionService; 

  const SegundaTarjeta({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
    required this.lugarCaptacionService, // Añadido servicio aquí
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

  // Variables de estado para manejar dinámicamente el lugar de captación
  List<Map<String, dynamic>> lugaresCaptacion = []; // Lista de lugares con ID y nombre
  String? selectedLugarCaptacionId; // ID del lugar seleccionado
  bool isLoadingLugares = true; // Indicador de carga
  String? errorLugares; // Mensaje de error

  bool _presentaSintomas = false;
  bool _fueReferido = false;
  bool _esViajero = false;

  @override
  void initState() {
    super.initState();
    // Llamar a la carga de lugares de captación
    fetchLugaresCaptacion();

    // Listeners para actualizaciones dinámicas
    presentaSintomasController.addListener(_actualizarPresentaSintomas);
    fueReferidoController.addListener(_actualizarFueReferido);
    esViajeroController.addListener(_actualizarEsViajero);
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

  // Función para obtener los lugares de captación desde el servicio
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
                        : CustomTextFieldDropdown(
                            hintText: 'Selecciona un lugar de captación',
                            controller: lugarCaptacionController,
                            options: lugaresCaptacion.map((e) => e['nombre'] as String).toList(),
                            borderColor: const Color(0xFF00C1D4),
                            borderRadius: 8.0,
                            width: double.infinity,
                            height: 55.0,
                            onChanged: (selectedNombre) {
                              setState(() {
                                selectedLugarCaptacionId = lugaresCaptacion
                                    .firstWhere((lugar) => lugar['nombre'] == selectedNombre)['id']
                                    .toString();
                              });
                              print('ID seleccionado: $selectedLugarCaptacionId');
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una condición',
                  controller: condicionPersonaController,
                  options: ['Vivo', 'Fallecido', 'Desconocido'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un SILAIS',
                  controller: silaisCaptacionController,
                  options: ['SILAIS - ESTELÍ', 'SILAIS - LEÓN', 'SILAIS - MANAGUA'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un establecimiento',
                  controller: establecimientoCaptacionController,
                  options: ['Hospital Nacional de Niños', 'Centro de Salud Masaya', 'Hospital Regional de León'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un sitio de exposición',
                  controller: sitioExposicionController,
                  options: ['Bosque', 'Mercado', 'Transporte Público', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: presentaSintomasController,
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona los síntomas',
                    controller: sintomasController,
                    options: ['Fiebre', 'Tos', 'Dolor de Cabeza', 'Otro'],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: fueReferidoController,
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona un SILAIS',
                    controller: silaisTrasladoController,
                    options: ['SILAIS - ESTELÍ', 'SILAIS - LEÓN', 'SILAIS - MANAGUA'],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
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
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona un establecimiento',
                    controller: establecimientoTrasladoController,
                    options: ['Hospital Regional de Masaya', 'Centro de Salud Jinotega', 'Hospital Nacional San Juan de Dios'],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
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
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: esViajeroController,
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
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
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona un lugar de ingreso',
                    controller: lugarIngresoPaisController,
                    options: ['Aeropuerto Internacional', 'Frontera Terrestre', 'Puerto Marítimo', 'Otro'],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
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
    );
  }
}
