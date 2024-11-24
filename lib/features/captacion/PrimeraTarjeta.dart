// PrimeraTarjeta.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/core/services/ComorbilidadesService.dart'; // Asegúrate de importar el servicio
import 'package:siven_app/widgets/seleccion_red_servicio_trabajador_widget.dart';
import 'package:siven_app/widgets/TextField.dart';

/// TextInputFormatter para permitir solo letras y espacios.
class LettersOnlyTextInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_regExp.hasMatch(newValue.text) || newValue.text.isEmpty) {
      return newValue;
    }
    return oldValue;
  }
}

/// TextInputFormatter para el teléfono de referencia.
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Remover todos los caracteres excepto dígitos y '+'
    text = '+' + text.replaceAll(RegExp(r'[^\d]'), '');

    // Asegurarse de que empiece con '+'
    if (!text.startsWith('+')) {
      text = '+' + text;
    }

    // Insertar espacio después del código de país (3 dígitos)
    if (text.length > 4 && text[4] != ' ') {
      text = text.substring(0, 4) + ' ' + text.substring(4);
    }

    // Insertar guion después de los siguientes 4 dígitos
    if (text.length > 9 && text[9] != '-') {
      text = text.substring(0, 9) + '-' + text.substring(9);
    }

    // Limitar a 14 caracteres: +XXX XXXX-XXXX
    if (text.length > 14) {
      text = text.substring(0, 14);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formateador para limitar la entrada numérica a un rango específico.
class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < min || value > max) {
      return oldValue;
    }

    return newValue;
  }
}

/// Clase genérica para representar opciones de Dropdown con ID y Nombre.
class DropdownOption<T> {
  final T id;
  final String name;

  DropdownOption({required this.id, required this.name});
}

class PrimeraTarjeta extends StatefulWidget {
  final String? nombreEventoSeleccionado;
  final String? nombreCompleto;
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final MaternidadService maternidadService;
  final ComorbilidadesService comorbilidadesService; // Añade el servicio
  final String? idEventoSalud; // ID del evento de salud
  final int? idPersona; // ID de la persona

  const PrimeraTarjeta({
    Key? key,
    required this.nombreEventoSeleccionado,
    required this.nombreCompleto,
    required this.catalogService,
    required this.selectionStorageService,
    required this.maternidadService,
    required this.comorbilidadesService, // Inicializa el servicio
    this.idEventoSalud,
    this.idPersona,
  }) : super(key: key);

  @override
  PrimeraTarjetaState createState() => PrimeraTarjetaState();
}

// Cambiado el nombre de la clase de estado para que sea pública
class PrimeraTarjetaState extends State<PrimeraTarjeta> {
  // Controladores de texto
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

  // Estados de carga y errores
  bool isLoadingMaternidad = true;
  String? errorMaternidad;
  List<DropdownOption<String>> opcionesMaternidad = [];

  // Estados booleanos para condicionales
  bool _tieneComorbilidades = false;
  bool _esTrabajadorSalud = false;

  // IDs seleccionados
  String? selectedMaternidadId;
  bool? selectedEsTrabajadorSaludId;
  String? selectedSILAISId;
  String? selectedEstablecimientoId;
  String? selectedComorbilidadId;
  bool? selectedTieneComorbilidadesId;

  // Opciones estáticas de Dropdown con valores booleanos
  final List<DropdownOption<bool>> opcionesTrabajadorSalud = [
    DropdownOption(id: true, name: 'Sí'),
    DropdownOption(id: false, name: 'No'),
  ];

  final List<DropdownOption<bool>> opcionesTieneComorbilidades = [
    DropdownOption(id: true, name: 'Sí'),
    DropdownOption(id: false, name: 'No'),
  ];

  // Opciones dinámicas de comorbilidades
  List<DropdownOption<String>> opcionesComorbilidad = [];
  bool isLoadingComorbilidades = true;
  String? errorComorbilidades;

  @override
  void initState() {
    super.initState();
    print(
        'PrimeraTarjeta - ID de persona: ${widget.idPersona}, ID de evento de salud: ${widget.idEventoSalud}');
    fetchOpcionesMaternidad();
    fetchOpcionesComorbilidades(); // Cargar comorbilidades dinámicamente

    // No es necesario usar listeners para Dropdowns con valores booleanos
  }

  @override
  void dispose() {
    // Dispose de los controladores
    maternidadController.dispose();
    semanasGestacionController.dispose();
    esTrabajadorSaludController.dispose();
    silaisTrabajadorController.dispose();
    establecimientoTrabajadorController.dispose();
    tieneComorbilidadesController.dispose();
    comorbilidadesController.dispose();
    nombreJefeFamiliaController.dispose();
    telefonoReferenciaController.dispose();
    super.dispose();
  }

  /// Fetch y asigna las opciones de maternidad.
  Future<void> fetchOpcionesMaternidad() async {
    try {
      List<Map<String, dynamic>> maternidades =
          await widget.maternidadService.listarMaternidad();
      List<DropdownOption<String>> opciones = maternidades.map((m) {
        return DropdownOption<String>(
          id: m['id_maternidad'].toString(),
          name: m['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        opcionesMaternidad = opciones;
        isLoadingMaternidad = false;
      });

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

      print('Error al cargar Maternidades: $errorMaternidad');
    }
  }

  /// Fetch y asigna las opciones de comorbilidades dinámicamente.
  Future<void> fetchOpcionesComorbilidades() async {
    try {
      List<Map<String, dynamic>> comorbilidades =
          await widget.comorbilidadesService.listarComorbilidades();
      List<DropdownOption<String>> opciones = comorbilidades.map((c) {
        return DropdownOption<String>(
          id: c['id_comorbilidades'].toString(),
          name: c['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        opcionesComorbilidad = opciones;
        isLoadingComorbilidades = false;
      });

      print('Opciones de Comorbilidades cargadas:');
      opcionesComorbilidad.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorComorbilidades = e.toString();
        isLoadingComorbilidades = false;
      });

      print('Error al cargar Comorbilidades: $errorComorbilidades');
    }
  }

  /// Abre el diálogo para seleccionar la red de servicio del trabajador.
  Future<void> _abrirDialogoSeleccionRedServicioTrabajador() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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

      print('ID seleccionado SILAIS: $selectedSILAISId');
      print('ID seleccionado Establecimiento: $selectedEstablecimientoId');
    }
  }

  /// Método de ayuda para construir campos desplegables con etiquetas usando CustomTextFieldDropdown.
  Widget _buildCustomDropdownField<T>({
    required String label,
    required List<DropdownOption<T>> options,
    required T? selectedId,
    required TextEditingController controller,
    required Function(T?) onChanged,
    required IconData icon,
    String hintText = 'Selecciona una opción',
  }) {
    // Extraer solo los nombres para el dropdown
    List<String> opciones = options.map((option) => option.name).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextFieldDropdown(
          hintText: hintText,
          controller: controller,
          options: opciones,
          borderColor: const Color(0xFF00C1D4),
          borderWidth: 1.0,
          borderRadius: 8.0,
          onChanged: (selectedOption) {
            // Encontrar el ID correspondiente al nombre seleccionado
            final selectedOptionObj = options.firstWhere(
              (option) => option.name == selectedOption,
              orElse: () => DropdownOption<T>(id: null as T, name: ''),
            );

            onChanged(selectedOptionObj.id);

            print('Opción seleccionada para $label: ${selectedOptionObj.id}');
          },
        ),
      ],
    );
  }

  /// Construye un campo de texto con etiqueta.
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF00C1D4)),
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
    );
  }

  /// Método para obtener los datos ingresados.
  Map<String, dynamic> getData() {
    return {
      'idEventoSalud': widget.idEventoSalud,
      'idPersona': widget.idPersona,
      'selectedMaternidadId': selectedMaternidadId,
      'semanasGestacion': semanasGestacionController.text,
      'esTrabajadorSalud': selectedEsTrabajadorSaludId,
      'selectedSILAISId': selectedSILAISId,
      'selectedEstablecimientoId': selectedEstablecimientoId,
      'tieneComorbilidades': selectedTieneComorbilidadesId,
      'selectedComorbilidadId': selectedComorbilidadId,
      'nombreJefeFamilia': nombreJefeFamiliaController.text,
      'telefonoReferencia': telefonoReferenciaController.text,
    };
  }

  /// Valida los campos y devuelve una lista de mensajes de error si hay alguno.
  List<String> validate() {
    List<String> errors = [];

    // Validar campos requeridos
    if (selectedMaternidadId == null || selectedMaternidadId!.isEmpty) {
      errors.add('Maternidad');
    }

    if (semanasGestacionController.text.isEmpty) {
      errors.add('Semanas de Gestación');
    }

    if (selectedEsTrabajadorSaludId == null) {
      errors.add('¿Es Trabajador de la Salud?');
    } else if (selectedEsTrabajadorSaludId == true) {
      if (selectedSILAISId == null || selectedSILAISId!.isEmpty) {
        errors.add('SILAIS del Trabajador');
      }
      if (selectedEstablecimientoId == null ||
          selectedEstablecimientoId!.isEmpty) {
        errors.add('Establecimiento del Trabajador');
      }
    }

    if (selectedTieneComorbilidadesId == null) {
      errors.add('¿Tiene Comorbilidades?');
    } else if (selectedTieneComorbilidadesId == true) {
      if (selectedComorbilidadId == null || selectedComorbilidadId!.isEmpty) {
        errors.add('Comorbilidades');
      }
    }

    if (nombreJefeFamiliaController.text.isEmpty) {
      errors.add('Nombre del Jefe de Familia');
    } else {
      // Validar que solo contiene letras
      final nombre = nombreJefeFamiliaController.text;
      final nombreRegExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
      if (!nombreRegExp.hasMatch(nombre)) {
        errors.add('Nombre del Jefe de Familia solo debe contener letras');
      }
    }

    if (telefonoReferenciaController.text.isEmpty) {
      errors.add('Teléfono de Referencia');
    } else {
      // Validar patrón de teléfono
      final telefono = telefonoReferenciaController.text;
      final telefonoRegExp = RegExp(r'^\+\d{3} \d{4}-\d{4}$');
      if (!telefonoRegExp.hasMatch(telefono)) {
        errors.add(
            'Teléfono de Referencia debe seguir el formato +XXX XXXX-XXXX');
      }
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Establecer color de fondo blanco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF00C1D4), width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardTitle(),
              const SizedBox(height: 20),
              _buildEventoSaludField(),
              const SizedBox(height: 20),
              _buildPersonaField(),
              const SizedBox(height: 20),
              isLoadingMaternidad
                  ? const CircularProgressIndicator()
                  : errorMaternidad != null
                      ? Text(
                          'Error al cargar maternidad: $errorMaternidad',
                          style: const TextStyle(color: Colors.red),
                        )
                      : _buildCustomDropdownField<String>(
                          label: 'Maternidad *',
                          options: opcionesMaternidad,
                          selectedId: selectedMaternidadId,
                          controller: maternidadController,
                          icon: Icons.home,
                          hintText: 'Selecciona una maternidad',
                          onChanged: (selectedId) {
                            final selectedOption =
                                opcionesMaternidad.firstWhere(
                              (option) => option.id == selectedId,
                              orElse: () =>
                                  DropdownOption<String>(id: '', name: ''),
                            );
                            setState(() {
                              selectedMaternidadId = selectedOption.id.isNotEmpty
                                  ? selectedOption.id
                                  : null;
                              maternidadController.text =
                                  selectedOption.name.isNotEmpty
                                      ? selectedOption.name
                                      : '';
                            });

                            print(
                                'ID seleccionado Maternidad: $selectedMaternidadId');
                          },
                        ),
              const SizedBox(height: 20),
              _buildSemanasGestacionField(),
              const SizedBox(height: 20),
              _buildCustomDropdownField<bool>(
                label: '¿Es Trabajador de la Salud? *',
                options: opcionesTrabajadorSalud,
                selectedId: selectedEsTrabajadorSaludId,
                controller: esTrabajadorSaludController,
                icon: Icons.health_and_safety,
                hintText: 'Selecciona una opción',
                onChanged: (selectedId) {
                  final selectedOption = opcionesTrabajadorSalud.firstWhere(
                    (option) => option.id == selectedId,
                    orElse: () =>
                        DropdownOption<bool>(id: false, name: 'No'),
                  );
                  setState(() {
                    selectedEsTrabajadorSaludId = selectedOption.id;
                    esTrabajadorSaludController.text = selectedOption.name;
                    _esTrabajadorSalud = selectedOption.id;
                    if (!_esTrabajadorSalud) {
                      silaisTrabajadorController.clear();
                      establecimientoTrabajadorController.clear();
                      selectedSILAISId = null;
                      selectedEstablecimientoId = null;
                    }
                  });

                  print(
                      '¿Es Trabajador de la Salud?: $selectedEsTrabajadorSaludId');
                },
              ),
              const SizedBox(height: 20),
              if (_esTrabajadorSalud) ...[
                _buildSILAISField(),
                const SizedBox(height: 20),
                _buildEstablecimientoField(),
                const SizedBox(height: 20),
              ],
              _buildCustomDropdownField<bool>(
                label: '¿Tiene Comorbilidades? *',
                options: opcionesTieneComorbilidades,
                selectedId: selectedTieneComorbilidadesId,
                controller: tieneComorbilidadesController,
                icon: Icons.health_and_safety_outlined,
                hintText: 'Selecciona una opción',
                onChanged: (selectedId) {
                  final selectedOption =
                      opcionesTieneComorbilidades.firstWhere(
                    (option) => option.id == selectedId,
                    orElse: () =>
                        DropdownOption<bool>(id: false, name: 'No'),
                  );
                  setState(() {
                    tieneComorbilidadesController.text =
                        selectedOption.name;
                    _tieneComorbilidades = selectedOption.id;
                    selectedTieneComorbilidadesId = selectedOption.id;
                    if (!_tieneComorbilidades) {
                      comorbilidadesController.clear();
                      selectedComorbilidadId = null;
                    }
                  });

                  print('¿Tiene Comorbilidades?: $selectedTieneComorbilidadesId');
                },
              ),
              const SizedBox(height: 20),
              if (_tieneComorbilidades) ...[
                isLoadingComorbilidades
                    ? const CircularProgressIndicator()
                    : errorComorbilidades != null
                        ? Text(
                            'Error al cargar comorbilidades: $errorComorbilidades',
                            style: const TextStyle(color: Colors.red),
                          )
                        : _buildCustomDropdownField<String>(
                            label: 'Comorbilidades *',
                            options: opcionesComorbilidad,
                            selectedId: selectedComorbilidadId,
                            controller: comorbilidadesController,
                            icon: Icons.medical_services,
                            hintText: 'Selecciona una comorbilidad',
                            onChanged: (selectedId) {
                              if (selectedId == null || selectedId.isEmpty)
                                return;
                              final opcionComorbilidad =
                                  opcionesComorbilidad.firstWhere(
                                (option) => option.id == selectedId,
                                orElse: () =>
                                    DropdownOption<String>(id: '', name: ''),
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

                              print(
                                  'ID seleccionado Comorbilidad: $selectedComorbilidadId');
                            },
                          ),
                const SizedBox(height: 20),
              ],
              _buildNombreJefeFamiliaField(),
              const SizedBox(height: 20),
              _buildTelefonoReferenciaField(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el título de la tarjeta.
  Widget _buildCardTitle() {
    return Row(
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
            '1',
            style: TextStyle(
              color: Colors.white,
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
            color: Color(0xFF00C1D4),
          ),
        ),
      ],
    );
  }

  /// Campo: Evento de Salud
  Widget _buildEventoSaludField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evento de Salud *',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          initialValue:
              widget.nombreEventoSeleccionado ?? 'Evento no seleccionado',
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Evento no seleccionado',
            prefixIcon:
                const Icon(Icons.local_hospital, color: Color(0xFF00C1D4)),
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
    );
  }

  /// Campo: Persona
  Widget _buildPersonaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Persona *',
          style: TextStyle(fontSize: 16, color: Colors.black),
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
    );
  }

  /// Campo: Semanas de Gestación
  Widget _buildSemanasGestacionField() {
    return _buildTextField(
      label: 'Semanas de Gestación *',
      controller: semanasGestacionController,
      hintText: 'Ingresa las semanas de gestación',
      icon: Icons.pregnant_woman,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        RangeTextInputFormatter(min: 1, max: 42),
      ],
    );
  }

  /// Campo: Nombre del Jefe de Familia
  Widget _buildNombreJefeFamiliaField() {
    return _buildTextField(
      label: 'Nombre del Jefe de Familia *',
      controller: nombreJefeFamiliaController,
      hintText: 'Ingresa el nombre completo',
      icon: Icons.person,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
        LettersOnlyTextInputFormatter(),
      ],
    );
  }

  /// Campo: Teléfono de Referencia
  Widget _buildTelefonoReferenciaField() {
    return _buildTextField(
      label: 'Teléfono de Referencia *',
      controller: telefonoReferenciaController,
      hintText: '+505 0000-0000',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[+\d\s-]')),
        PhoneNumberFormatter(),
      ],
    );
  }

  /// Campo: SILAIS del Trabajador (Condicional)
  Widget _buildSILAISField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SILAIS del Trabajador *',
          style: TextStyle(fontSize: 16, color: Colors.black),
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
                  icon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
                  onPressed: _abrirDialogoSeleccionRedServicioTrabajador,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Campo: Establecimiento del Trabajador (Condicional)
  Widget _buildEstablecimientoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Establecimiento del Trabajador *',
          style: TextStyle(fontSize: 16, color: Colors.black),
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
    );
  }
}
