import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

// Importaciones de tus servicios y widgets personalizados
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/TextField.dart';

import 'package:siven_app/widgets/seleccion_red_servicio_trabajador_widget.dart'; // Importa el widget

class Captacion extends StatefulWidget {
  const Captacion({Key? key}) : super(key: key);

  @override
  _CaptacionState createState() => _CaptacionState();
}

// Definir la clase RangeTextInputFormatter si aún no lo has hecho
class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Permitir que el campo esté vacío
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Intentar parsear el valor a entero
    final int? value = int.tryParse(newValue.text);
    if (value == null) {
      // Si no es un número válido, no permitir el cambio
      return oldValue;
    }

    // Verificar si el valor está dentro del rango
    if (value > max || value < min) {
      // Si está fuera del rango, no permitir el cambio
      return oldValue;
    }

    // Si está dentro del rango, permitir el cambio
    return newValue;
  }
}

class _CaptacionState extends State<Captacion> {
  int _currentCardIndex = 0; // Índice de la tarjeta actual
  String? _selectedEventoName;
  String? nombreCompleto;

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late EventoSaludService eventoSaludService;
  late MaternidadService maternidadService;

  // Lista para almacenar los nombres de eventos de salud
  List<String> eventosSalud = [];
  bool isLoadingEventosSalud = true;
  String? errorEventosSalud;

  List<String> maternidadOptions = [];
  bool isLoadingMaternidad = true;
  String? errorMaternidad;

  bool _hasComorbilidades = false;

  bool _isTrabajadorSalud = false;

  // Controladores para la primera tarjeta
  final TextEditingController eventoSaludController = TextEditingController();
  final TextEditingController personaController = TextEditingController();
  final TextEditingController maternidadController = TextEditingController();
  final TextEditingController semanasGestacionController =
      TextEditingController();
  final TextEditingController esTrabajadorSaludController =
      TextEditingController();
  final TextEditingController silaisTrabajadorController =
      TextEditingController();
  final TextEditingController establecimientoTrabajadorController =
      TextEditingController();
  final TextEditingController tieneComorbilidadesController =
      TextEditingController();
  final TextEditingController comorbilidadesController =
      TextEditingController();
  final TextEditingController nombreJefeFamiliaController =
      TextEditingController();
  final TextEditingController telefonoReferenciaController =
      TextEditingController();

  // Controladores para la segunda tarjeta
  final TextEditingController lugarCaptacionController =
      TextEditingController();
  final TextEditingController condicionPersonaController =
      TextEditingController();
  final TextEditingController fechaCaptacionController =
      TextEditingController();
  final TextEditingController semanaEpidemiologicaController =
      TextEditingController();
  final TextEditingController silaisCaptacionController =
      TextEditingController();
  final TextEditingController establecimientoCaptacionController =
      TextEditingController();
  final TextEditingController personaCaptadaController =
      TextEditingController();
  final TextEditingController sitioExposicionController =
      TextEditingController();
  final TextEditingController latitudOcurrenciaController =
      TextEditingController();
  final TextEditingController longitudOcurrenciaController =
      TextEditingController();
  final TextEditingController presentaSintomasController =
      TextEditingController();
  final TextEditingController fechaInicioSintomasController =
      TextEditingController();
  final TextEditingController sintomasController = TextEditingController();
  final TextEditingController fueReferidoController = TextEditingController();
  final TextEditingController silaisTrasladoController =
      TextEditingController();
  final TextEditingController establecimientoTrasladoController =
      TextEditingController();
  final TextEditingController esViajeroController = TextEditingController();
  final TextEditingController fechaIngresoPaisController =
      TextEditingController();
  final TextEditingController lugarIngresoPaisController =
      TextEditingController();
  final TextEditingController observacionesCaptacionController =
      TextEditingController();

  // Controladores para la tercera tarjeta
  final TextEditingController puestoNotificacionController =
      TextEditingController();
  final TextEditingController claveNotificacionController =
      TextEditingController();
  final TextEditingController numeroLaminaController = TextEditingController();
  final TextEditingController tomaMuestraController = TextEditingController();
  final TextEditingController tipoBusquedaController = TextEditingController();

  // Controladores para la cuarta tarjeta
  final TextEditingController diagnosticoController = TextEditingController();
  final TextEditingController fechaTomaMuestraController =
      TextEditingController();
  final TextEditingController fechaRecepcionLabController =
      TextEditingController();
  final TextEditingController fechaDiagnosticoController =
      TextEditingController();
  final TextEditingController resultadoDiagnosticoController =
      TextEditingController();
  final TextEditingController densidadVivaxEASController =
      TextEditingController();
  final TextEditingController densidadVivaxESSController =
      TextEditingController();
  final TextEditingController densidadFalciparumEASController =
      TextEditingController();
  final TextEditingController densidadFalciparumESSController =
      TextEditingController();
  final TextEditingController silaisDiagnosticoController =
      TextEditingController();
  final TextEditingController establecimientoDiagnosticoController =
      TextEditingController();

  // Controladores adicionales para los dropdowns
  final TextEditingController tipoMuestraController = TextEditingController();
  final TextEditingController metodoAnalisisController =
      TextEditingController();
  final TextEditingController resultadoPruebaController =
      TextEditingController();

  // Variables para la animación de guardar
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Inicialización de servicios
    initializeServices();

    // Obtener los eventos de salud al iniciar
    fetchEventosSalud();

    fetchMaternidadOptions();

    tieneComorbilidadesController.addListener(_updateHasComorbilidades);

    esTrabajadorSaludController.addListener(_updateIsTrabajadorSalud);
  }

  // Método para actualizar la variable de estado
  void _updateHasComorbilidades() {
    setState(() {
      _hasComorbilidades = tieneComorbilidadesController.text == 'Sí';
    });
  }

  // Método para actualizar la variable de estado para Trabajador de la Salud
  void _updateIsTrabajadorSalud() {
    setState(() {
      _isTrabajadorSalud = esTrabajadorSaludController.text == 'Sí';
      if (!_isTrabajadorSalud) {
        silaisTrabajadorController.clear();
        establecimientoTrabajadorController.clear();
      }
    });
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
    eventoSaludService = EventoSaludService(httpService: httpService);
    maternidadService = MaternidadService(httpService: httpService);
  }

  Future<void> fetchEventosSalud() async {
    try {
      List<Map<String, dynamic>> eventos =
          await eventoSaludService.listarEventosSalud();
      setState(() {
        eventosSalud =
            eventos.map((evento) => evento['nombre'] as String).toList();
        isLoadingEventosSalud = false;
      });
    } catch (e) {
      setState(() {
        errorEventosSalud = e.toString();
        isLoadingEventosSalud = false;
      });
    }
  }

  Future<void> _openSeleccionRedServicioTrabajadorDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SeleccionRedServicioTrabajadorWidget(
            catalogService: catalogService,
            selectionStorageService: selectionStorageService,
          ),
        );
      },
    );

    // Asigna los resultados del diálogo a los controladores, si el resultado no es nulo.
    if (result != null) {
      setState(() {
        silaisTrabajadorController.text =
            result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoTrabajadorController.text =
            result['establecimiento'] ?? 'Establecimiento no seleccionado';
      });
    }
  }

  Future<void> fetchMaternidadOptions() async {
    try {
      List<Map<String, dynamic>> maternidades =
          await maternidadService.listarMaternidad();
      setState(() {
        maternidadOptions =
            maternidades.map((m) => m['nombre'] as String).toList();
        isLoadingMaternidad = false;
      });
    } catch (e) {
      setState(() {
        errorMaternidad = e.toString();
        isLoadingMaternidad = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose de los controladores de la primera tarjeta
    eventoSaludController.dispose();
    personaController.dispose();
    maternidadController.dispose();

    semanasGestacionController.dispose();
    esTrabajadorSaludController.removeListener(_updateIsTrabajadorSalud);
    silaisTrabajadorController.dispose();
    establecimientoTrabajadorController.dispose();
    tieneComorbilidadesController.removeListener(_updateHasComorbilidades);
    comorbilidadesController.dispose();
    nombreJefeFamiliaController.dispose();
    telefonoReferenciaController.dispose();

    // Dispose de los controladores de la segunda tarjeta
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
    presentaSintomasController.dispose();
    fechaInicioSintomasController.dispose();
    sintomasController.dispose();
    fueReferidoController.dispose();
    silaisTrasladoController.dispose();
    establecimientoTrasladoController.dispose();
    esViajeroController.dispose();
    fechaIngresoPaisController.dispose();
    lugarIngresoPaisController.dispose();
    observacionesCaptacionController.dispose();

    // Dispose de los controladores de la tercera tarjeta
    puestoNotificacionController.dispose();
    claveNotificacionController.dispose();
    numeroLaminaController.dispose();
    tomaMuestraController.dispose();
    tipoBusquedaController.dispose();

    // Dispose de los controladores de la cuarta tarjeta
    diagnosticoController.dispose();
    fechaTomaMuestraController.dispose();
    fechaRecepcionLabController.dispose();
    fechaDiagnosticoController.dispose();
    resultadoDiagnosticoController.dispose();
    densidadVivaxEASController.dispose();
    densidadVivaxESSController.dispose();
    densidadFalciparumEASController.dispose();
    densidadFalciparumESSController.dispose();
    silaisDiagnosticoController.dispose();
    establecimientoDiagnosticoController.dispose();
    tipoMuestraController.dispose();
    metodoAnalisisController.dispose();
    resultadoPruebaController.dispose();

    super.dispose();
  }

  // Métodos de navegación
  void _nextCard() {
    if (_currentCardIndex < 3) {
      // Ahora hay cuatro tarjetas: índice 0, 1, 2 y 3
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
      // Limpiar controladores de la primera tarjeta
      eventoSaludController.clear();
      personaController.clear();
      maternidadController.clear();
      semanasGestacionController.clear();
      esTrabajadorSaludController.clear();
      silaisTrabajadorController.clear();
      establecimientoTrabajadorController.clear();
      tieneComorbilidadesController.clear();
      comorbilidadesController.clear();
      nombreJefeFamiliaController.clear();
      telefonoReferenciaController.clear();

      // Limpiar controladores de la segunda tarjeta
      lugarCaptacionController.clear();
      condicionPersonaController.clear();
      fechaCaptacionController.clear();
      semanaEpidemiologicaController.clear();
      silaisCaptacionController.clear();
      establecimientoCaptacionController.clear();
      personaCaptadaController.clear();
      sitioExposicionController.clear();
      latitudOcurrenciaController.clear();
      longitudOcurrenciaController.clear();
      presentaSintomasController.clear();
      fechaInicioSintomasController.clear();
      sintomasController.clear();
      fueReferidoController.clear();
      silaisTrasladoController.clear();
      establecimientoTrasladoController.clear();
      esViajeroController.clear();
      fechaIngresoPaisController.clear();
      lugarIngresoPaisController.clear();
      observacionesCaptacionController.clear();

      // Limpiar controladores de la tercera tarjeta
      puestoNotificacionController.clear();
      claveNotificacionController.clear();
      numeroLaminaController.clear();
      tomaMuestraController.clear();
      tipoBusquedaController.clear();

      // Limpiar controladores de la cuarta tarjeta
      diagnosticoController.clear();
      fechaTomaMuestraController.clear();
      fechaRecepcionLabController.clear();
      fechaDiagnosticoController.clear();
      resultadoDiagnosticoController.clear();
      densidadVivaxEASController.clear();
      densidadVivaxESSController.clear();
      densidadFalciparumEASController.clear();
      densidadFalciparumESSController.clear();
      silaisDiagnosticoController.clear();
      establecimientoDiagnosticoController.clear();
      tipoMuestraController.clear();
      metodoAnalisisController.clear();
      resultadoPruebaController.clear();
    });
  }

  // Método para guardar datos en la cuarta tarjeta
  Future<void> _guardarDatos() async {
    setState(() {
      _isSaving = true;
    });

    // Aquí deberías implementar la lógica para guardar los datos, por ejemplo, una llamada a una API
    // Por ahora, simularemos una operación de guardado con un retardo
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSaving = false;
    });

    // Mostrar mensaje de éxito
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se guardó exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Método para renderizar el contenido de la tarjeta basado en el índice actual
  Widget _buildCardContent() {
    switch (_currentCardIndex) {
      case 0:
        return _buildFirstCard();
      case 1:
        return _buildSecondCard();
      case 2:
        return _buildThirdCard();
      case 3:
        return _buildFourthCard();
      default:
        return _buildFirstCard(); // Valor por defecto
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener los argumentos pasados desde la pantalla anterior
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _selectedEventoName = args['eventoSeleccionado'];
        nombreCompleto = args['nombreCompleto'];
      });
    }
  }

  // Método para construir la primera tarjeta
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
            // Título de la Tarjeta
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
                  'Datos del Paciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto en color celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 1: Evento de Salud (Mostrar el valor sin posibilidad de edición)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evento de Salud *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  initialValue: _selectedEventoName ?? 'Evento no seleccionado',
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Evento no seleccionado',
                    prefixIcon: const Icon(Icons.local_hospital,
                        color: Color(0xFF00C1D4)), // Ícono actualizado
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 2: Persona (Mostrar el valor sin posibilidad de edición)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Persona *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  initialValue: nombreCompleto ?? 'Sin nombre',
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Sin nombre',
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
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 3: Maternidad (Opción)
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
                isLoadingMaternidad
                    ? const Center(child: CircularProgressIndicator())
                    : errorMaternidad != null
                        ? Text(
                            'Error: $errorMaternidad',
                            style: const TextStyle(color: Colors.red),
                          )
                        : CustomTextFieldDropdown(
                            hintText: 'Selecciona una maternidad',
                            controller: maternidadController,
                            options: maternidadOptions,
                            borderColor: const Color(0xFF00C1D4),
                            borderRadius: 8.0,
                            width: double.infinity,
                            height: 55.0,
                          ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 4: Semanas de Gestación (Número)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Semanas de Gestación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: semanasGestacionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingresa las semanas de gestación',
                    prefixIcon: const Icon(Icons.pregnant_woman,
                        color: Color(0xFF00C1D4)),
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
                    RangeTextInputFormatter(min: 1, max: 42),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa las semanas de gestación';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null) {
                      return 'Ingresa un número válido';
                    }
                    if (intValue < 1 || intValue > 42) {
                      return 'Ingresa un número entre 1 y 42';
                    }
                    return null; // El valor es válido
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 5: ¿Es Trabajador de la Salud? (Opción)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Es Trabajador de la Salud? *',
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
                  onChanged: (value) {
                    setState(() {
                      _isTrabajadorSalud = value == 'Sí';
                      if (!_isTrabajadorSalud) {
                        silaisTrabajadorController.clear();
                        establecimientoTrabajadorController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

// Campo 6: SILAIS del Trabajador (Opción) - Condicional
            if (_isTrabajadorSalud) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SILAIS del Trabajador *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height:
                        55.0, // Asegura que la altura coincida con otros campos
                    child: Stack(
                      children: [
                        TextField(
                          controller: silaisTrabajadorController,
                          readOnly:
                              true, // Hace el campo de texto no editable para forzar el uso del botón de búsqueda.
                          decoration: InputDecoration(
                            hintText: 'Selecciona un SILAIS',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C1D4),
                                width:
                                    2.0, // Ajusta el grosor según sea necesario
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C1D4),
                                width:
                                    2.0, // Ajusta el grosor según sea necesario
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF00C1D4),
                                width:
                                    2.0, // Ajusta el grosor según sea necesario
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            icon: const Icon(Icons.search,
                                color: Color(0xFF00C1D4)),
                            onPressed:
                                _openSeleccionRedServicioTrabajadorDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 7: Establecimiento del Trabajador (Opción) - Condicional
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Establecimiento del Trabajador *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height:
                        55.0, // Asegura que la altura coincida con otros campos
                    child: TextField(
                      controller: establecimientoTrabajadorController,
                      readOnly: true, // Hace que el campo no sea editable
                      decoration: InputDecoration(
                        hintText: 'Selecciona un establecimiento',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF00C1D4),
                            width: 2.0, // Ajusta el grosor según sea necesario
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF00C1D4),
                            width: 2.0, // Ajusta el grosor según sea necesario
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF00C1D4),
                            width: 2.0, // Ajusta el grosor según sea necesario
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Campo 8: ¿Tiene Comorbilidades? (Opción)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Tiene Comorbilidades? *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: tieneComorbilidadesController,
                  options: ['Sí', 'No'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 9: Comorbilidades (Opción) - Condicional
            if (_hasComorbilidades) ...[
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
                    hintText: 'Selecciona una comorbilidad',
                    controller: comorbilidadesController,
                    options: [
                      'Diabetes',
                      'Hipertensión',
                      'Enfermedad Pulmonar',
                      'Otra'
                    ],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Campo 10: Nombre del Jefe de Familia (Texto)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombre del Jefe de Familia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: nombreJefeFamiliaController,
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

            // Campo 11: Teléfono de Referencia (Teléfono)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teléfono de Referencia *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: telefonoReferenciaController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el teléfono de referencia',
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

            // Campo 1: Lugar de Captación (Opción)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lugar de Captación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un lugar de captación',
                  controller: lugarCaptacionController,
                  options: [
                    'Hospital',
                    'Centro de Salud',
                    'Campaña Móvil',
                    'Otro'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 2: Condición de la Persona (Opción)
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
                  options: [
                    'Susceptible',
                    'Infectado',
                    'Recuperado',
                    'Fallecido'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 3: Fecha de Captación
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
                  readOnly: true, // Para mostrar un selector de fecha
                  decoration: InputDecoration(
                    hintText: 'Selecciona la fecha de captación',
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Color(0xFF00C1D4)),
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
                        fechaCaptacionController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 4: Semana Epidemiológica
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
                    prefixIcon: const Icon(Icons.calendar_view_week,
                        color: Color(0xFF00C1D4)),
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

            // Campo 5: SILAIS de Captación (Opción)
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
                  options: [
                    'SILAIS - ESTELÍ',
                    'SILAIS - LEÓN',
                    'SILAIS - MANAGUA'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 6: Establecimiento de Captación (Opción)
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
                  options: [
                    'Hospital Nacional de Niños',
                    'Centro de Salud Masaya',
                    'Hospital Regional de León'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 7: Persona Captada
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Persona Captada *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: personaCaptadaController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la persona captada',
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

            // Campo 8: Sitio de Exposición (Opción)
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
                  options: [
                    'Bosque',
                    'Mercado',
                    'Transporte Público',
                    'Otro'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 9: Latitud de Ocurrencia
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

            // Campo 10: Longitud de Ocurrencia
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

            // Campo 11: ¿Presenta Síntomas? (Opción)
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

            // Campo 12: Fecha de Inicio de Síntomas
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
                  readOnly: true, // Para mostrar un selector de fecha
                  decoration: InputDecoration(
                    hintText: 'Selecciona la fecha de inicio de síntomas',
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Color(0xFF00C1D4)),
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
                        fechaInicioSintomasController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 13: Síntomas (Opción)
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
                  options: [
                    'Fiebre',
                    'Dolor de Cabeza',
                    'Dolor Muscular',
                    'Fatiga',
                    'Otro'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 14: ¿Fue Referido? (Opción)
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

            // Campo 15: SILAIS de Traslado (Opción)
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
                  options: [
                    'SILAIS - ESTELÍ',
                    'SILAIS - LEÓN',
                    'SILAIS - MANAGUA'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 16: Establecimiento de Traslado (Opción)
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
                  options: [
                    'Hospital Regional de Masaya',
                    'Centro de Salud Jinotega',
                    'Hospital Nacional San Juan de Dios'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 17: ¿Es Viajero? (Opción)
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

            // Campo 18: Fecha de Ingreso al País
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
                  readOnly: true, // Para mostrar un selector de fecha
                  decoration: InputDecoration(
                    hintText: 'Selecciona la fecha de ingreso al país',
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Color(0xFF00C1D4)),
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
                        fechaIngresoPaisController.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 19: Lugar de Ingreso al País (Opción)
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
                  options: [
                    'Aeropuerto Internacional Augusto C. Sandino',
                    'Puerto de Managua',
                    'Puesto Fronterizo El Tamarugal',
                    'Otro'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 20: Observaciones de Captación
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
                    prefixIcon:
                        const Icon(Icons.notes, color: Color(0xFF00C1D4)),
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
                  maxLines: 3, // Para permitir múltiples líneas
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
                  'Datos de Notificación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto en color celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 1: Puesto de Notificación (Opción)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Puesto de Notificación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un puesto de notificación',
                  controller: puestoNotificacionController,
                  options: [
                    'Centro de Salud Masaya',
                    'Hospital Regional de León',
                    'Laboratorio Central',
                    'Otro'
                  ], // Personaliza estas opciones según tus necesidades
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 2: Clave de Notificación
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clave de Notificación *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: claveNotificacionController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la clave de notificación',
                    prefixIcon:
                        const Icon(Icons.vpn_key, color: Color(0xFF00C1D4)),
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

            // Campo 3: Número de Lámina
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Número de Lámina *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: numeroLaminaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el número de lámina',
                    prefixIcon:
                        const Icon(Icons.numbers, color: Color(0xFF00C1D4)),
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

            // Campo 4: Toma de Muestra (Opción)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Toma de Muestra *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: tomaMuestraController,
                  options: ['Sangre', 'Orina', 'Espesamento de Sangre', 'Otra'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo 5: Tipo de Búsqueda (Opción)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de Búsqueda *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona el tipo de búsqueda',
                  controller: tipoBusquedaController,
                  options: ['Aleatoria', 'Intencionada', 'Exhaustiva', 'Otra'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                  const SizedBox(
                      width: 8), // Espacio entre el número y el texto
                  const Text(
                    'Datos de Diagnóstico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C1D4), // Texto en color celeste
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 1: Diagnóstico (Opción)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diagnóstico *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona un diagnóstico',
                    controller: diagnosticoController,
                    options: [
                      'Malaria Vivax',
                      'Malaria Falciparum',
                      'Co-infección',
                      'Otro'
                    ],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 2: Fecha de Toma de Muestra
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de Toma de Muestra *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: fechaTomaMuestraController,
                    readOnly: true, // Para mostrar un selector de fecha
                    decoration: InputDecoration(
                      hintText: 'Selecciona la fecha de toma de muestra',
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Color(0xFF00C1D4)),
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
                          fechaTomaMuestraController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 3: Fecha de Recepción en Laboratorio
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de Recepción en Laboratorio *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: fechaRecepcionLabController,
                    readOnly: true, // Para mostrar un selector de fecha
                    decoration: InputDecoration(
                      hintText:
                          'Selecciona la fecha de recepción en laboratorio',
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Color(0xFF00C1D4)),
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
                          fechaRecepcionLabController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 4: Fecha de Diagnóstico
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de Diagnóstico *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: fechaDiagnosticoController,
                    readOnly: true, // Para mostrar un selector de fecha
                    decoration: InputDecoration(
                      hintText: 'Selecciona la fecha de diagnóstico',
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Color(0xFF00C1D4)),
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
                          fechaDiagnosticoController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 5: Resultado del Diagnóstico (Opción)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultado del Diagnóstico *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona el resultado del diagnóstico',
                    controller: resultadoDiagnosticoController,
                    options: ['Positivo', 'Negativo', 'Indeterminado'],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 6: Densidad Parasitaria Vivax EAS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Densidad Parasitaria Vivax EAS *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: densidadVivaxEASController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ingresa la densidad parasitaria Vivax EAS',
                      prefixIcon:
                          const Icon(Icons.numbers, color: Color(0xFF00C1D4)),
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

              // Campo 7: Densidad Parasitaria Vivax ESS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Densidad Parasitaria Vivax ESS *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: densidadVivaxESSController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ingresa la densidad parasitaria Vivax ESS',
                      prefixIcon:
                          const Icon(Icons.numbers, color: Color(0xFF00C1D4)),
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

              // Campo 8: Densidad Parasitaria Falciparum EAS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Densidad Parasitaria Falciparum EAS *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: densidadFalciparumEASController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText:
                          'Ingresa la densidad parasitaria Falciparum EAS',
                      prefixIcon:
                          const Icon(Icons.numbers, color: Color(0xFF00C1D4)),
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

              // Campo 9: Densidad Parasitaria Falciparum ESS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Densidad Parasitaria Falciparum ESS *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: densidadFalciparumESSController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText:
                          'Ingresa la densidad parasitaria Falciparum ESS',
                      prefixIcon:
                          const Icon(Icons.numbers, color: Color(0xFF00C1D4)),
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

              // Campo 10: SILAIS Diagnóstico (Opción)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SILAIS Diagnóstico *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona un SILAIS',
                    controller: silaisDiagnosticoController,
                    options: [
                      'SILAIS - ESTELÍ',
                      'SILAIS - LEÓN',
                      'SILAIS - MANAGUA'
                    ], // Personaliza estas opciones según tus necesidades
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo 11: Establecimiento Diagnóstico (Opción)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Establecimiento Diagnóstico *',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomTextFieldDropdown(
                    hintText: 'Selecciona un establecimiento',
                    controller: establecimientoDiagnosticoController,
                    options: [
                      'Laboratorio Central',
                      'Hospital Regional de León',
                      'Centro de Salud Masaya',
                      'Otro'
                    ], // Personaliza estas opciones según tus necesidades
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
        ));
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

                  // Encabezado Azul Dinámico
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: const Color(0xFF00C1D4), // Color celeste
                    child: Center(
                      child: Text(
                        'Evento de salud - ${_selectedEventoName ?? 'Evento no seleccionado'}',
                        style: const TextStyle(
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
                    children: [
                      Icon(Icons.person, color: Color(0xFF00C1D4)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ver detalle del paciente - ${nombreCompleto ?? 'Sin nombre'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Esto mostrará '...' si el texto es muy largo
                        ),
                      ),
                    ],
                  ),

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
