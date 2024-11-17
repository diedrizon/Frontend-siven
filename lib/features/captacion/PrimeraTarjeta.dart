// lib/widgets/primera_tarjeta.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
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

// Clase para representar opciones de Dropdown con ID y Nombre
class DropdownOption {
  final String id;
  final String name;

  DropdownOption({required this.id, required this.name});
}

class PrimeraTarjeta extends StatefulWidget {
  final String? nombreEventoSeleccionado;
  final String? nombreCompleto;
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final MaternidadService maternidadService;
  final String? idEventoSalud; // ID del evento de salud
  final int? idPersona; // ID de la persona

  const PrimeraTarjeta({
    Key? key,
    required this.nombreEventoSeleccionado,
    required this.nombreCompleto,
    required this.catalogService,
    required this.selectionStorageService,
    required this.maternidadService,
    this.idEventoSalud,
    this.idPersona,
  }) : super(key: key);

  @override
  _PrimeraTarjetaState createState() => _PrimeraTarjetaState();
}

class _PrimeraTarjetaState extends State<PrimeraTarjeta> {
  // Controladores para la primera tarjeta
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

  bool isLoadingMaternidad = true;
  String? errorMaternidad;
  List<DropdownOption> opcionesMaternidad = [];

  bool _tieneComorbilidades = false;
  bool _esTrabajadorSalud = false;

  // Variables para almacenar los IDs seleccionados
  String? selectedMaternidadId;
  String? selectedEsTrabajadorSaludId;
  String? selectedSILAISId;
  String? selectedEstablecimientoId;
  String? selectedComorbilidadId;

  // Nueva variable para "¿Tiene Comorbilidades?"
  String? selectedTieneComorbilidadesId;

  // Definir las opciones para "¿Es Trabajador de la Salud?" con 1 y 0
  final List<DropdownOption> opcionesTrabajadorSalud = [
    DropdownOption(id: '1', name: 'Sí'),
    DropdownOption(id: '0', name: 'No'),
  ];

  // Definir las opciones para "¿Tiene Comorbilidades?" con 1 y 0
  final List<DropdownOption> opcionesTieneComorbilidades = [
    DropdownOption(id: '1', name: 'Sí'),
    DropdownOption(id: '0', name: 'No'),
  ];

  // Definir las opciones para "Comorbilidades"
  final List<DropdownOption> opcionesComorbilidad = [
    DropdownOption(id: '1', name: 'Diabetes'),
    DropdownOption(id: '2', name: 'Hipertensión'),
    DropdownOption(id: '3', name: 'Enfermedad Pulmonar'),
    DropdownOption(id: '4', name: 'Otra'),
  ];

  // Variables para almacenar los IDs pasados desde la pantalla anterior
  String? idEventoSalud;
  int? idPersona;

  @override
  void initState() {
    super.initState();

    // Asignar los IDs pasados desde la pantalla anterior
    idEventoSalud = widget.idEventoSalud;
    idPersona = widget.idPersona;

    // Imprimir los IDs en la terminal
    print(
        'PrimeraTarjeta - ID de persona: $idPersona, ID de evento de salud: $idEventoSalud');

    // Obtener opciones de maternidad
    fetchOpcionesMaternidad();

    tieneComorbilidadesController.addListener(_actualizarTieneComorbilidades);
    esTrabajadorSaludController
        .addListener(_actualizarEsTrabajadorSalud);
  }

  Future<void> fetchOpcionesMaternidad() async {
    try {
      List<Map<String, dynamic>> maternidades =
          await widget.maternidadService.listarMaternidad();
      // Convertir List<Map<String, dynamic>> a List<DropdownOption>
      List<DropdownOption> opciones = maternidades.map((m) {
        return DropdownOption(
          id: m['id_maternidad']
              .toString(), // Asegúrate de que el campo de ID es correcto
          name: m['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        opcionesMaternidad = opciones;
        isLoadingMaternidad = false;
      });

      // Opcional: Imprimir las opciones cargadas
      print('Opciones de Maternidad cargadas:');
      opcionesMaternidad.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMaternidad = e.toString();
        isLoadingMaternidad = false;
      });

      // Imprimir el error
      print('Error al cargar Maternidades: $errorMaternidad');
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
        selectedSILAISId = null;
        selectedEstablecimientoId = null;
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
      if (!mounted) return;
      setState(() {
        silaisTrabajadorController.text =
            result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoTrabajadorController.text =
            result['establecimiento'] ?? 'Establecimiento no seleccionado';
        selectedSILAISId = result['silaisId'];
        selectedEstablecimientoId = result['establecimientoId'];
      });

      // Imprimir los IDs seleccionados
      print('ID seleccionado SILAIS: $selectedSILAISId');
      print('ID seleccionado Establecimiento: $selectedEstablecimientoId');
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
    tieneComorbilidadesController
        .removeListener(_actualizarTieneComorbilidades);
    tieneComorbilidadesController.dispose();
    comorbilidadesController.dispose();
    nombreJefeFamiliaController.dispose();
    telefonoReferenciaController.dispose();

    super.dispose();
  }

  // Función para obtener el ID de la Comorbilidad
  String _getIdComorbilidad(String name) {
    switch (name) {
      case 'Diabetes':
        return '1';
      case 'Hipertensión':
        return '2';
      case 'Enfermedad Pulmonar':
        return '3';
      case 'Otra':
        return '4';
      default:
        return '';
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
        child: SingleChildScrollView(
          // Para evitar overflow en pantallas pequeñas
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
                    initialValue: widget.nombreEventoSeleccionado ??
                        'Evento no seleccionado',
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Evento no seleccionado',
                      prefixIcon: const Icon(Icons.local_hospital,
                          color: Color(0xFF00C1D4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
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
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF00C1D4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
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
                          : DropdownButtonFormField<String>(
                              value: selectedMaternidadId,
                              decoration: InputDecoration(
                                hintText: 'Selecciona una maternidad',
                                prefixIcon: const Icon(Icons.home,
                                    color: Color(0xFF00C1D4)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF00C1D4)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF00C1D4)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF00C1D4)),
                                ),
                              ),
                              items: opcionesMaternidad.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option.id,
                                  child: Text(option.name),
                                );
                              }).toList(),
                              onChanged: (selectedId) {
                                final selectedOption = opcionesMaternidad
                                    .firstWhere(
                                  (option) => option.id == selectedId,
                                  orElse: () =>
                                      DropdownOption(id: '', name: ''),
                                );
                                setState(() {
                                  selectedMaternidadId =
                                      selectedOption.id.isNotEmpty
                                          ? selectedOption.id
                                          : null;
                                  maternidadController.text =
                                      selectedOption.name.isNotEmpty
                                          ? selectedOption.name
                                          : '';
                                });

                                // Imprimir el ID seleccionado
                                print(
                                    'ID seleccionado Maternidad: $selectedMaternidadId');
                              },
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
                      prefixIcon: const Icon(Icons.pregnant_woman,
                          color: Color(0xFF00C1D4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
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
                  DropdownButtonFormField<String>(
                    value: selectedEsTrabajadorSaludId,
                    decoration: InputDecoration(
                      hintText: 'Selecciona una opción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xFF00C1D4), width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xFF00C1D4), width: 2.0),
                      ),
                    ),
                    items: opcionesTrabajadorSalud.map((option) {
                      return DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.name),
                      );
                    }).toList(),
                    onChanged: (selectedId) {
                      final selectedOption = opcionesTrabajadorSalud
                          .firstWhere(
                        (option) => option.id == selectedId,
                        orElse: () => DropdownOption(id: '0', name: 'No'),
                      );
                      setState(() {
                        selectedEsTrabajadorSaludId = selectedOption.id;
                        esTrabajadorSaludController.text = selectedOption.name;
                        _esTrabajadorSalud =
                            selectedOption.id == '1'; // '1' es Sí
                        if (!_esTrabajadorSalud) {
                          silaisTrabajadorController.clear();
                          establecimientoTrabajadorController.clear();
                          selectedSILAISId = null;
                          selectedEstablecimientoId = null;
                        }
                      });

                      // Imprimir el ID seleccionado
                      print(
                          'ID seleccionado ¿Es Trabajador de la Salud?: $selectedEsTrabajadorSaludId');
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 10.0),
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
                              icon: const Icon(Icons.search,
                                  color: Color(0xFF00C1D4)),
                              onPressed:
                                  _abrirDialogoSeleccionRedServicioTrabajador,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
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
                  DropdownButtonFormField<String>(
                    value: selectedTieneComorbilidadesId,
                    decoration: InputDecoration(
                      hintText: 'Selecciona una opción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xFF00C1D4), width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xFF00C1D4), width: 2.0),
                      ),
                    ),
                    items: opcionesTieneComorbilidades.map((option) {
                      return DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.name),
                      );
                    }).toList(),
                    onChanged: (selectedId) {
                      final selectedOption = opcionesTieneComorbilidades
                          .firstWhere(
                        (option) => option.id == selectedId,
                        orElse: () => DropdownOption(id: '0', name: 'No'),
                      );
                      setState(() {
                        tieneComorbilidadesController.text =
                            selectedOption.name;
                        _tieneComorbilidades =
                            selectedOption.id == '1'; // '1' es Sí
                        selectedTieneComorbilidadesId = selectedOption.id;
                        if (!_tieneComorbilidades) {
                          comorbilidadesController.clear();
                          selectedComorbilidadId = null;
                        }
                      });

                      // Imprimir el ID seleccionado
                      print(
                          'ID seleccionado ¿Tiene Comorbilidades?: $selectedTieneComorbilidadesId');
                    },
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
                    DropdownButtonFormField<String>(
                      value: selectedComorbilidadId,
                      decoration: InputDecoration(
                        hintText: 'Selecciona una comorbilidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF00C1D4)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF00C1D4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF00C1D4)),
                        ),
                      ),
                      items: opcionesComorbilidad.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.id,
                          child: Text(option.name),
                        );
                      }).toList(),
                      onChanged: (selectedId) {
                        if (selectedId == null) return;
                        final opcionComorbilidad = opcionesComorbilidad
                            .firstWhere(
                          (option) => option.id == selectedId,
                          orElse: () => DropdownOption(id: '', name: ''),
                        );
                        setState(() {
                          selectedComorbilidadId =
                              opcionComorbilidad.id.isNotEmpty
                                  ? opcionComorbilidad.id
                                  : null;
                          comorbilidadesController.text =
                              opcionComorbilidad.name.isNotEmpty
                                  ? opcionComorbilidad.name
                                  : '';
                        });

                        // Imprimir el ID seleccionado
                        print(
                            'ID seleccionado Comorbilidad: $selectedComorbilidadId');
                      },
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
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF00C1D4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
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
                      prefixIcon:
                          const Icon(Icons.phone, color: Color(0xFF00C1D4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF00C1D4)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
