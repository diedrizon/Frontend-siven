import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/widgets/TextField.dart';
import 'package:siven_app/widgets/seleccion_red_servicio_trabajador_widget.dart';

// Clase RangeTextInputFormatter para limitar el rango de entrada numérica
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

class PrimeraTarjeta extends StatefulWidget {
  final String? nombreEventoSeleccionado;
  final String? nombreCompleto;
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final MaternidadService maternidadService;

  const PrimeraTarjeta({
    Key? key,
    required this.nombreEventoSeleccionado,
    required this.nombreCompleto,
    required this.catalogService,
    required this.selectionStorageService,
    required this.maternidadService,
  }) : super(key: key);

  @override
  _PrimeraTarjetaState createState() => _PrimeraTarjetaState();
}

class _PrimeraTarjetaState extends State<PrimeraTarjeta> {
  // Controladores para la primera tarjeta
  final TextEditingController maternidadController = TextEditingController();
  final TextEditingController semanasGestacionController = TextEditingController();
  final TextEditingController esTrabajadorSaludController = TextEditingController();
  final TextEditingController silaisTrabajadorController = TextEditingController();
  final TextEditingController establecimientoTrabajadorController = TextEditingController();
  final TextEditingController tieneComorbilidadesController = TextEditingController();
  final TextEditingController comorbilidadesController = TextEditingController();
  final TextEditingController nombreJefeFamiliaController = TextEditingController();
  final TextEditingController telefonoReferenciaController = TextEditingController();

  bool isLoadingMaternidad = true;
  String? errorMaternidad;
  List<String> opcionesMaternidad = [];

  bool _tieneComorbilidades = false;
  bool _esTrabajadorSalud = false;

  @override
  void initState() {
    super.initState();

    // Obtener opciones de maternidad
    fetchOpcionesMaternidad();

    tieneComorbilidadesController.addListener(_actualizarTieneComorbilidades);
    esTrabajadorSaludController.addListener(_actualizarEsTrabajadorSalud);
  }

  Future<void> fetchOpcionesMaternidad() async {
    try {
      List<Map<String, dynamic>> maternidades = await widget.maternidadService.listarMaternidad();
      setState(() {
        opcionesMaternidad = maternidades.map((m) => m['nombre'] as String).toList();
        isLoadingMaternidad = false;
      });
    } catch (e) {
      setState(() {
        errorMaternidad = e.toString();
        isLoadingMaternidad = false;
      });
    }
  }

  void _actualizarTieneComorbilidades() {
    setState(() {
      _tieneComorbilidades = tieneComorbilidadesController.text == 'Sí';
    });
  }

  void _actualizarEsTrabajadorSalud() {
    setState(() {
      _esTrabajadorSalud = esTrabajadorSaludController.text == 'Sí';
      if (!_esTrabajadorSalud) {
        silaisTrabajadorController.clear();
        establecimientoTrabajadorController.clear();
      }
    });
  }

  Future<void> _abrirDialogoSeleccionRedServicioTrabajador() async {
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
      setState(() {
        silaisTrabajadorController.text = result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoTrabajadorController.text = result['establecimiento'] ?? 'Establecimiento no seleccionado';
      });
    }
  }

  @override
  void dispose() {
    // Dispose de los controladores de la primera tarjeta
    maternidadController.dispose();
    semanasGestacionController.dispose();
    esTrabajadorSaludController.removeListener(_actualizarEsTrabajadorSalud);
    esTrabajadorSaludController.dispose();
    silaisTrabajadorController.dispose();
    establecimientoTrabajadorController.dispose();
    tieneComorbilidadesController.removeListener(_actualizarTieneComorbilidades);
    tieneComorbilidadesController.dispose();
    comorbilidadesController.dispose();
    nombreJefeFamiliaController.dispose();
    telefonoReferenciaController.dispose();

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
                    color: const Color(0xFF00C1D4), // Fondo celeste
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Datos del Paciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C1D4), // Texto celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Evento de Salud
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
                  initialValue: widget.nombreEventoSeleccionado ?? 'Evento no seleccionado',
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Evento no seleccionado',
                    prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF00C1D4)),
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

            // Campo: Persona
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
                  initialValue: widget.nombreCompleto ?? 'Sin nombre',
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Sin nombre',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF00C1D4)),
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

            // Campo: Maternidad
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
                            options: opcionesMaternidad,
                            borderColor: const Color(0xFF00C1D4),
                            borderRadius: 8.0,
                            width: double.infinity,
                            height: 55.0,
                          ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Semanas de Gestación
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
                    prefixIcon: const Icon(Icons.pregnant_woman, color: Color(0xFF00C1D4)),
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
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: ¿Es Trabajador de la Salud?
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
                      _esTrabajadorSalud = value == 'Sí';
                      if (!_esTrabajadorSalud) {
                        silaisTrabajadorController.clear();
                        establecimientoTrabajadorController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: SILAIS del Trabajador (Condicional)
            if (_esTrabajadorSalud) ...[
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
                    height: 55.0,
                    child: Stack(
                      children: [
                        TextField(
                          controller: silaisTrabajadorController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Selecciona un SILAIS',
                            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
                            onPressed: _abrirDialogoSeleccionRedServicioTrabajador,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Establecimiento del Trabajador (Condicional)
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
                    height: 55.0,
                    child: TextField(
                      controller: establecimientoTrabajadorController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Selecciona un establecimiento',
                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Campo: ¿Tiene Comorbilidades?
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

            // Campo: Comorbilidades (Condicional)
            if (_tieneComorbilidades) ...[
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
                    options: ['Diabetes', 'Hipertensión', 'Enfermedad Pulmonar', 'Otra'],
                    borderColor: const Color(0xFF00C1D4),
                    borderRadius: 8.0,
                    width: double.infinity,
                    height: 55.0,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Campo: Nombre del Jefe de Familia
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

            // Campo: Teléfono de Referencia
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
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF00C1D4)),
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
}
