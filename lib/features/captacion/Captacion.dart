import 'package:flutter/material.dart';
import 'package:siven_app/widgets/version.dart'; // Widget reutilizado
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; // Widget reutilizado
import 'package:siven_app/widgets/TextField.dart'; // Asegúrate de usar el nombre correcto
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;

class Captacion extends StatefulWidget {
  const Captacion({Key? key}) : super(key: key);

  @override
  _CaptacionState createState() => _CaptacionState();
}

class _CaptacionState extends State<Captacion> {
  int _currentCardIndex = 0; // Índice de la card actual

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;

  // Controladores para la primera card
  final TextEditingController maternidadController = TextEditingController();
  final TextEditingController esTrabajadorSaludController = TextEditingController();
  final TextEditingController silaisController = TextEditingController();
  final TextEditingController unidadController = TextEditingController();
  final TextEditingController comorbilidades1Controller = TextEditingController();
  final TextEditingController comorbilidades2Controller = TextEditingController();
  final TextEditingController jefeFamiliaController = TextEditingController();
  final TextEditingController telefono1Controller = TextEditingController();
  final TextEditingController telefono2Controller = TextEditingController();

  // Controladores para la segunda card
  final TextEditingController datoCaptacionSelectorController = TextEditingController();
  final TextEditingController datoCaptacionInputController = TextEditingController();
  final TextEditingController busquedaNombreController = TextEditingController();
  final TextEditingController telefonoJefeFamiliaCaptacionController = TextEditingController();

  // Controladores para la tercera card
  final TextEditingController datoNotificacion1Controller = TextEditingController();
  final TextEditingController datoNotificacion2Controller = TextEditingController();
  final TextEditingController datoNotificacion3Controller = TextEditingController();
  final TextEditingController datoNotificacion4Controller = TextEditingController();
  final TextEditingController datoNotificacion5Controller = TextEditingController();
  final TextEditingController busquedaNombreNotificacion1Controller = TextEditingController();
  final TextEditingController telefonoJefeFamiliaNotificacionController = TextEditingController();
  final TextEditingController busquedaNombreNotificacion2Controller = TextEditingController();

  // Controladores para la cuarta card
  final TextEditingController datoLaboratorio1Controller = TextEditingController();
  final TextEditingController datoLaboratorio2Controller = TextEditingController();
  final TextEditingController datoLaboratorio3Controller = TextEditingController();
  final TextEditingController datoLaboratorio4Controller = TextEditingController();
  final TextEditingController datoLaboratorioSelectorController = TextEditingController();
  final TextEditingController busquedaNombreLaboratorio1Controller = TextEditingController();
  final TextEditingController telefonoJefeFamiliaLaboratorioController = TextEditingController();
  final TextEditingController busquedaNombreLaboratorio2Controller = TextEditingController();

  // Variables para la animación de guardar
  bool _isSaving = false;

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
  void dispose() {
    // Dispose de los controladores de la primera card
    maternidadController.dispose();
    esTrabajadorSaludController.dispose();
    silaisController.dispose();
    unidadController.dispose();
    comorbilidades1Controller.dispose();
    comorbilidades2Controller.dispose();
    jefeFamiliaController.dispose();
    telefono1Controller.dispose();
    telefono2Controller.dispose();

    // Dispose de los controladores de la segunda card
    datoCaptacionSelectorController.dispose();
    datoCaptacionInputController.dispose();
    busquedaNombreController.dispose();
    telefonoJefeFamiliaCaptacionController.dispose();

    // Dispose de los controladores de la tercera card
    datoNotificacion1Controller.dispose();
    datoNotificacion2Controller.dispose();
    datoNotificacion3Controller.dispose();
    datoNotificacion4Controller.dispose();
    datoNotificacion5Controller.dispose();
    busquedaNombreNotificacion1Controller.dispose();
    telefonoJefeFamiliaNotificacionController.dispose();
    busquedaNombreNotificacion2Controller.dispose();

    // Dispose de los controladores de la cuarta card
    datoLaboratorio1Controller.dispose();
    datoLaboratorio2Controller.dispose();
    datoLaboratorio3Controller.dispose();
    datoLaboratorio4Controller.dispose();
    datoLaboratorioSelectorController.dispose(); // Controlador agregado
    busquedaNombreLaboratorio1Controller.dispose();
    telefonoJefeFamiliaLaboratorioController.dispose();
    busquedaNombreLaboratorio2Controller.dispose();

    super.dispose();
  }

  // Métodos de navegación
  void _nextCard() {
    if (_currentCardIndex < 3) {
      // Ahora hay cuatro cards: índice 0, 1, 2 y 3
      setState(() {
        _currentCardIndex++;
      });
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
      });
    }
  }

  // Método para limpiar todos los campos
  void _limpiarCampos() {
    setState(() {
      // Limpiar controladores de la primera card
      maternidadController.clear();
      esTrabajadorSaludController.clear();
      silaisController.clear();
      unidadController.clear();
      comorbilidades1Controller.clear();
      comorbilidades2Controller.clear();
      jefeFamiliaController.clear();
      telefono1Controller.clear();
      telefono2Controller.clear();

      // Limpiar controladores de la segunda card
      datoCaptacionSelectorController.clear();
      datoCaptacionInputController.clear();
      busquedaNombreController.clear();
      telefonoJefeFamiliaCaptacionController.clear();

      // Limpiar controladores de la tercera card
      datoNotificacion1Controller.clear();
      datoNotificacion2Controller.clear();
      datoNotificacion3Controller.clear();
      datoNotificacion4Controller.clear();
      datoNotificacion5Controller.clear();
      busquedaNombreNotificacion1Controller.clear();
      telefonoJefeFamiliaNotificacionController.clear();
      busquedaNombreNotificacion2Controller.clear();

      // Limpiar controladores de la cuarta card
      datoLaboratorio1Controller.clear();
      datoLaboratorio2Controller.clear();
      datoLaboratorio3Controller.clear();
      datoLaboratorio4Controller.clear();
      busquedaNombreLaboratorio1Controller.clear();
      telefonoJefeFamiliaLaboratorioController.clear();
      busquedaNombreLaboratorio2Controller.clear();
    });
  }

  // Método para guardar datos en la cuarta card
  Future<void> _guardarDatos() async {
    setState(() {
      _isSaving = true;
    });

    // Simular una operación de guardado (por ejemplo, llamada a una API)
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isSaving = false;
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Se guardó exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Método para renderizar el contenido de la card basado en el índice actual
  Widget _buildCardContent() {
    if (_currentCardIndex == 0) {
      return _buildFirstCard();
    } else if (_currentCardIndex == 1) {
      return _buildSecondCard();
    } else if (_currentCardIndex == 2) {
      return _buildThirdCard();
    } else if (_currentCardIndex == 3) {
      return _buildFourthCard();
    } else {
      return _buildFirstCard(); // Valor por defecto
    }
  }

  // Método para construir la primera card
  Widget _buildFirstCard() {
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
            // Título de la Card Modificado
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C1D4), // Fondo celeste
                    borderRadius: BorderRadius.circular(
                        4), // Bordes ligeramente redondeados
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco dentro del cuadrado
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Espacio entre el número y el texto
                const Text(
                  'Datos del paciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto en color celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 1: Maternidad
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Maternidad *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: maternidadController,
                  options: [
                    'Hospital Nacional de Niños',
                    'Centro de Salud Masaya',
                    'Hospital Regional de León'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 2: ¿Es trabajador de la salud?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Es trabajador de la salud? *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: esTrabajadorSaludController,
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 3: SILAIS del trabajador
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SILAIS del trabajador *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: silaisController,
                  options: [
                    'SILAIS - ESTELÍ',
                    'SILAIS - LEÓN',
                    'SILAIS - MANAGUA'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 4: Unidad de salud del trabajador
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unidad de salud del trabajador *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: unidadController,
                  options: [
                    'Consultorio Médico Roger Montoya',
                    'CAPS - León',
                    'Hospital Nacional San Juan de Dios'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 5: ¿Presenta comorbilidades?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Presenta comorbilidades? *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: comorbilidades1Controller,
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 6: Comorbilidades
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comorbilidades *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: comorbilidades2Controller,
                  options: ['Diabetes', 'Hipertensión', 'Enfermedad Pulmonar'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 7: Nombre completo del jefe de familia
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombre completo del jefe de familia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: jefeFamiliaController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el nombre completo',
                    prefixIcon:
                        const Icon(Icons.person, color: Color(0xFF00C1D4)),
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

            // Fila 8: Teléfono del jefe de familia
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teléfono del jefe de familia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: telefono1Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el teléfono',
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF00C1D4)),
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

            // Fila 9: Teléfono del jefe de familia (repetido)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teléfono del jefe de familia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: telefono2Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el teléfono',
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF00C1D4)),
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

            // Fila 10: Presenta comorbilidades y Comorbilidades (repetida)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Presenta comorbilidades? *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller:
                      comorbilidades1Controller, // Puedes usar otro controlador si es necesario
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Comorbilidades *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller:
                      comorbilidades2Controller, // Puedes usar otro controlador si es necesario
                  options: ['Diabetes', 'Hipertensión', 'Enfermedad Pulmonar'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir la segunda card
  Widget _buildSecondCard() {
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
            // Título de la Card Modificado para la Segunda Card
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C1D4), // Fondo celeste
                    borderRadius: BorderRadius.circular(
                        4), // Bordes ligeramente redondeados
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco dentro del cuadrado
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Espacio entre el número y el texto
                const Text(
                  'Datos de Captación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto en color celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 1: Dato de captación (selector)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fuente de Captación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: datoCaptacionSelectorController,
                  options: [
                    'Hospital Nacional de Niños',
                    'Centro de Salud Masaya',
                    'Hospital Regional de León'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 2: Dato de captación (Ingrese datos de la captacion)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalle de Captación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: datoCaptacionInputController,
                  decoration: InputDecoration(
                    hintText: 'Ingrese detalles de la captación',
                    prefixIcon:
                        const Icon(Icons.text_fields, color: Color(0xFF00C1D4)),
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

            // Fila 3: Dato de captación (selector)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de Captación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: datoCaptacionSelectorController,
                  options: [
                    'Referido por Hospital',
                    'Campaña de Salud',
                    'Visita Domiciliaria'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 4: Dato de captación (campo de búsqueda: "Realizar búsqueda por nombre")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar paciente por nombre *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: busquedaNombreController,
                  decoration: InputDecoration(
                    hintText: 'Realizar búsqueda por nombre',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF00C1D4)),
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

            // Fila 5: Dato de captación (campo de texto: "Ingresa el teléfono del jefe de familia")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teléfono del jefe de familia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: telefonoJefeFamiliaCaptacionController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el teléfono del jefe de familia',
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF00C1D4)),
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

            // Fila 6: Dato de captación (selector)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Canal de Captación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: datoCaptacionSelectorController,
                  options: [
                    'Referido por Médico',
                    'Campaña de Vacunación',
                    'Consulta Externa'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 7: Dato de captación (campo de búsqueda: "Realizar búsqueda por nombre")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar paciente por nombre *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: busquedaNombreController,
                  decoration: InputDecoration(
                    hintText: 'Realizar búsqueda por nombre',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF00C1D4)),
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
          ],
        ),
      ),
    );
  }

  // Método para construir la tercera card
  Widget _buildThirdCard() {
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
            // Título de la Card Modificado para la Tercera Card
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C1D4), // Fondo celeste
                    borderRadius: BorderRadius.circular(
                        4), // Bordes ligeramente redondeados
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco dentro del cuadrado
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Espacio entre el número y el texto
                const Text(
                  'Datos Notificación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto en color celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 1: Dato de notificación (selector) y Dato de notificación (selector)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Notificación *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoNotificacion1Controller,
                        options: [
                          'Laboratorio',
                          'Hospital',
                          'Centro de Salud'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Origen de Notificación *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoNotificacion2Controller,
                        options: [
                          'Sistema Nacional de Salud',
                          'Organización No Gubernamental',
                          'Campaña de Salud Pública'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 2: Dato de notificación (selector)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de la Notificación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: datoNotificacion3Controller,
                  options: [
                    'Pendiente',
                    'En Proceso',
                    'Finalizado'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 3: Dato de notificación (campo de texto: "Ingrese dato de notificación")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripción de la Notificación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: datoNotificacion4Controller,
                  decoration: InputDecoration(
                    hintText: 'Ingrese descripción de la notificación',
                    prefixIcon:
                        const Icon(Icons.text_fields, color: Color(0xFF00C1D4)),
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

            // Fila 4: Dato de notificación (selector) y Dato de notificación (selector)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prioridad de Notificación *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoNotificacion5Controller,
                        options: [
                          'Alta',
                          'Media',
                          'Baja'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Responsable de Notificación *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoNotificacion2Controller,
                        options: [
                          'Médico',
                          'Enfermera',
                          'Personal Administrativo'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 5: Dato de notificación (campo de búsqueda: "Realizar búsqueda por nombre")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar responsable por nombre *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: busquedaNombreNotificacion2Controller,
                  decoration: InputDecoration(
                    hintText: 'Realizar búsqueda por nombre',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF00C1D4)),
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
          ],
        ),
      ),
    );
  }

  // Método para construir la cuarta card
  Widget _buildFourthCard() {
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
            // Título de la Card
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C1D4), // Fondo celeste
                    borderRadius: BorderRadius.circular(
                        4), // Bordes ligeramente redondeados
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco dentro del cuadrado
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Espacio entre el número y el texto
                const Text(
                  'Datos de Laboratorio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto en color celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 1: Dato de laboratorio (selector) y Dato de laboratorio (selector)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Laboratorio *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoLaboratorio1Controller,
                        options: [
                          'Laboratorio Central',
                          'Laboratorio Regional Masaya',
                          'Laboratorio Comunitario Jinotega'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado del Laboratorio *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoLaboratorio2Controller,
                        options: [
                          'Operativo',
                          'En Mantenimiento',
                          'Fuera de Servicio'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 2: Dato de laboratorio (selector)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Área de Laboratorio *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: datoLaboratorio3Controller,
                  options: [
                    'Microbiología',
                    'Hematoanálisis',
                    'Química Clínica'
                  ], // Datos reales de Nicaragua
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 3: Dato de laboratorio (campo de texto: "Ingrese dato de laboratorio")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descripción del Laboratorio *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: datoLaboratorio4Controller,
                  decoration: InputDecoration(
                    hintText: 'Ingrese descripción del laboratorio',
                    prefixIcon:
                        const Icon(Icons.text_fields, color: Color(0xFF00C1D4)),
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

            // Fila 4: Dato de laboratorio (selector) y Dato de laboratorio (selector)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Muestra *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoLaboratorioSelectorController,
                        options: [
                          'Sangre',
                          'Orina',
                          'Espesamento de Sangre'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Método de Análisis *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoLaboratorio2Controller,
                        options: [
                          'Espectrofotometría',
                          'Cromatografía',
                          'PCR (Reacción en Cadena de la Polimerasa)'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 5: Dato de laboratorio (campo de búsqueda: "Realizar búsqueda por nombre")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar laboratorio por nombre *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: busquedaNombreLaboratorio1Controller,
                  decoration: InputDecoration(
                    hintText: 'Realizar búsqueda por nombre',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF00C1D4)),
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

            // Fila 6: Dato de laboratorio (campo de texto: "Ingresa el teléfono del jefe de familia")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teléfono del jefe de familia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: telefonoJefeFamiliaLaboratorioController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el teléfono del jefe de familia',
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF00C1D4)),
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

            // Fila 7: Dato de laboratorio (selector) y Dato de laboratorio (selector)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Análisis *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoLaboratorio1Controller,
                        options: [
                          'Bioquímico',
                          'Hematológico',
                          'Serológico'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Método de Prueba *',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextFieldDropdown(
                        hintText: 'Selecciona una opción',
                        controller: datoLaboratorio2Controller,
                        options: [
                          'ELISA',
                          'Western Blot',
                          'PCR'
                        ], // Datos reales de Nicaragua
                        borderColor: const Color(0xFF00C1D4),
                        borderRadius: 8.0,
                        width: double.infinity,
                        height: 55.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fila 8: Dato de laboratorio (campo de búsqueda: "Realizar búsqueda por nombre")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar laboratorio por nombre *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: busquedaNombreLaboratorio2Controller,
                  decoration: InputDecoration(
                    hintText: 'Realizar búsqueda por nombre',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF00C1D4)),
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

            // Botón Guardar con animación de carga
            Center(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardarDatos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C1D4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Guardando...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        backgroundColor: Colors.white, // Fondo blanco en el AppBar
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF1877F2), size: 32),
            onPressed: () {
              Navigator.pushNamed(context, '/captacion_inf_paciente');
            },
          ),
        ),
        title: const EncabezadoBienvenida(), // No se toca
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

                  // Red de servicio (otro widget adicional)
                  RedDeServicio(
                    catalogService: catalogService,
                    selectionStorageService: selectionStorageService,
                  ),
                  const SizedBox(height: 30),

                  // Encabezado Azul
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: const Color(0xFF00C1D4), // Color celeste
                    child: const Center(
                      child: Text(
                        'Evento de salud - Captación Malaria',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fila con icono de usuario y texto
                  Row(
                    children: const [
                      Icon(Icons.person, color: Color(0xFF00C1D4)),
                      SizedBox(width: 10),
                      Text(
                        'Ver detalle del paciente - Alvaro Hernández',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mostrar el contenido de la card según la página
                  _buildCardContent(),
                ],
              ),
            ),
          ),

          // Footer con botones de navegación
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón "ANTERIOR"
                ElevatedButton(
                  onPressed: _previousCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ANTERIOR',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                // Indicadores de página
                Row(
                  children: [
                    for (int i = 0; i < 4; i++) // Ahora cuatro cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: _currentCardIndex == i
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                  ],
                ),

                // Botón "SIGUIENTE"
                ElevatedButton(
                  onPressed: _currentCardIndex < 3
                      ? _nextCard
                      : null, // Deshabilitar en la última card
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C1D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIGUIENTE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                // **Botón "LIMPIAR" eliminado**
              ],
            ),
          ),

          const VersionWidget(), // No se toca
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Captacion(),
  ));
}
