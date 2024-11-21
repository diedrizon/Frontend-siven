// CuartaTarjeta.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Agregado para formateo de fechas
import 'package:siven_app/core/services/DiagnosticoService.dart';
import 'package:siven_app/core/services/ResultadoDiagnosticoService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/widgets/seleccion_red_servicio_trabajador_widget.dart';
import 'package:siven_app/widgets/TextField.dart'; // Asegúrate de que este path sea correcto
import 'dart:async'; // Añadido

/// Clase para representar opciones de Dropdown con ID y Nombre.
class DropdownOption {
  final int id;
  final String name;

  DropdownOption({required this.id, required this.name});
}

/// Cuarta Tarjeta: Datos de Diagnóstico
class CuartaTarjeta extends StatefulWidget {
  final DiagnosticoService diagnosticoService;
  final ResultadoDiagnosticoService resultadoDiagnosticoService;
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final Future<void> Function() onGuardarPressed; // Cambiado

  const CuartaTarjeta({
    Key? key,
    required this.diagnosticoService,
    required this.resultadoDiagnosticoService,
    required this.catalogService,
    required this.selectionStorageService,
    required this.onGuardarPressed, // Añadido
  }) : super(key: key);

  @override
  CuartaTarjetaState createState() => CuartaTarjetaState();
}

class CuartaTarjetaState extends State<CuartaTarjeta> {
  // Controladores de texto para cada campo
  final TextEditingController diagnosticoController = TextEditingController();
  final TextEditingController resultadoDiagnosticoController = TextEditingController();
  final TextEditingController fechaTomaMuestraController = TextEditingController();
  final TextEditingController fechaRecepcionLabController = TextEditingController();
  final TextEditingController fechaDiagnosticoController = TextEditingController();
  final TextEditingController densidadVivaxEASController = TextEditingController();
  final TextEditingController densidadVivaxESSController = TextEditingController();
  final TextEditingController densidadFalciparumEASController = TextEditingController();
  final TextEditingController densidadFalciparumESSController = TextEditingController();
  final TextEditingController silaisDiagnosticoController = TextEditingController();
  final TextEditingController establecimientoDiagnosticoController = TextEditingController();

  bool _isSaving = false; // Estado para el botón de guardar

  // Listas para los Dropdowns
  List<DropdownOption> _diagnosticos = [];
  List<DropdownOption> _resultadosDiagnostico = [];

  // Variables para almacenar los IDs seleccionados
  int? _selectedDiagnosticoId;
  int? _selectedResultadoDiagnosticoId;
  int? _selectedSILAISDiagnosticoId;
  int? _selectedEstablecimientoDiagnosticoId;

  bool _isLoadingDiagnosticos = true;
  String? _errorDiagnosticos;

  bool _isLoadingResultados = true;
  String? _errorResultados;

  @override
  void initState() {
    super.initState();
    _cargarDiagnosticos();
    _cargarResultadosDiagnostico();
  }

  @override
  void dispose() {
    // Dispose de todos los controladores
    diagnosticoController.dispose();
    resultadoDiagnosticoController.dispose();
    fechaTomaMuestraController.dispose();
    fechaRecepcionLabController.dispose();
    fechaDiagnosticoController.dispose();
    densidadVivaxEASController.dispose();
    densidadVivaxESSController.dispose();
    densidadFalciparumEASController.dispose();
    densidadFalciparumESSController.dispose();
    silaisDiagnosticoController.dispose();
    establecimientoDiagnosticoController.dispose();
    super.dispose();
  }

  /// Método para obtener los datos ingresados.
  Map<String, dynamic> getData() {
    return {
      'selectedDiagnosticoId': _selectedDiagnosticoId,
      'fechaTomaMuestra': fechaTomaMuestraController.text,
      'fechaRecepcionLab': fechaRecepcionLabController.text,
      'fechaDiagnostico': fechaDiagnosticoController.text,
      'selectedResultadoDiagnosticoId': _selectedResultadoDiagnosticoId,
      'densidadVivaxEAS': densidadVivaxEASController.text,
      'densidadVivaxESS': densidadVivaxESSController.text,
      'densidadFalciparumEAS': densidadFalciparumEASController.text,
      'densidadFalciparumESS': densidadFalciparumESSController.text,
      'selectedSILAISDiagnosticoId': _selectedSILAISDiagnosticoId,
      'selectedEstablecimientoDiagnosticoId': _selectedEstablecimientoDiagnosticoId,
    };
  }

  /// Método para actualizar el estado de guardado desde el widget padre
  void setSavingState(bool isSaving) {
    setState(() {
      _isSaving = isSaving;
    });
  }

  /// Función para cargar diagnósticos desde el servicio
  Future<void> _cargarDiagnosticos() async {
    try {
      List<Map<String, dynamic>> diagnosticos = await widget.diagnosticoService.listarDiagnosticos();
      List<DropdownOption> opciones = diagnosticos.map((e) {
        return DropdownOption(
          id: e['id_diagnostico'] as int,
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _diagnosticos = opciones;
        _isLoadingDiagnosticos = false;
      });

      print('Opciones de Diagnósticos cargadas:');
      _diagnosticos.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorDiagnosticos = 'Error al cargar diagnósticos: $e';
        _isLoadingDiagnosticos = false;
      });

      print('Error al cargar Diagnósticos: $_errorDiagnosticos');
    }
  }

  /// Función para cargar resultados de diagnóstico desde el servicio
  Future<void> _cargarResultadosDiagnostico() async {
    try {
      List<Map<String, dynamic>> resultados = await widget.resultadoDiagnosticoService.listarResultadosDiagnostico();
      List<DropdownOption> opciones = resultados.map((e) {
        return DropdownOption(
          id: e['id_resultado_diagnostico'] as int,
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _resultadosDiagnostico = opciones;
        _isLoadingResultados = false;
      });

      print('Opciones de Resultados de Diagnóstico cargadas:');
      _resultadosDiagnostico.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorResultados = 'Error al cargar resultados de diagnóstico: $e';
        _isLoadingResultados = false;
      });

      print('Error al cargar Resultados de Diagnóstico: $_errorResultados');
    }
  }

  /// Función para guardar los datos
  Future<void> _guardarDatos() async {
    setState(() {
      _isSaving = true;
    });

    // Llamar a la función pasada desde el widget padre
    await widget.onGuardarPressed();

    setState(() {
      _isSaving = false;
    });
  }

  /// Método auxiliar para construir campos desplegables usando CustomTextFieldDropdown
  Widget _buildCustomDropdownField({
    required String label,
    required bool isLoading,
    String? errorText,
    required List<DropdownOption> options,
    required int? selectedId,
    required TextEditingController controller,
    required Function(int?) onChanged,
    required IconData icon,
    required String hintText,
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
                : CustomTextFieldDropdown(
                    hintText: hintText,
                    controller: controller,
                    options: options.map((option) => option.name).toList(),
                    borderColor: const Color(0xFF00C1D4),
                    borderWidth: 1.0,
                    borderRadius: 8.0,
                    onChanged: (selectedOption) {
                      // Encontrar el ID correspondiente al nombre seleccionado
                      final selectedOptionObj = options.firstWhere(
                        (option) => option.name == selectedOption,
                        orElse: () => DropdownOption(id: -1, name: ''),
                      );

                      if (selectedOptionObj.id != -1) {
                        onChanged(selectedOptionObj.id);
                        controller.text = selectedOptionObj.name;
                        print('Opción seleccionada para $label: ID=${selectedOptionObj.id}, Nombre=${selectedOptionObj.name}');
                      } else {
                        onChanged(null);
                        controller.text = '';
                      }
                    },
                  ),
      ],
    );
  }

  /// Widget para construir campos de texto con un formato estándar
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF00C1D4))
                : null,
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

  /// Método auxiliar para construir campos de selección de fecha
  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? icon,
  }) {
    return _buildTextField(
      label: label,
      controller: controller,
      hintText: hintText ?? '',
      icon: icon,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          // Removido el locale para evitar posibles errores
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          // Usar DateFormat para formatear la fecha de manera consistente
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          setState(() {
            controller.text = formattedDate;
          });
        }
      },
    );
  }

  /// Método auxiliar para construir campos de texto con ícono de búsqueda.
  Widget buildSearchableTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required VoidCallback onSearch,
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
          readOnly: true, // Evita modificaciones manuales
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF00C1D4)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
              onPressed: onSearch,
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
          onTap: () {
            // Opcional: Puedes implementar alguna acción al tocar el campo
          },
        ),
      ],
    );
  }

  /// Función para abrir el diálogo de selección para Diagnóstico
  Future<void> _abrirDialogoSeleccionRedServicioDiagnostico() async {
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
        silaisDiagnosticoController.text =
            result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoDiagnosticoController.text =
            result['establecimiento'] ?? 'Establecimiento no seleccionado';
        _selectedSILAISDiagnosticoId = int.tryParse(result['silaisId'] ?? '');
        _selectedEstablecimientoDiagnosticoId =
            int.tryParse(result['establecimientoId'] ?? '');
      });

      // Imprimir los IDs seleccionados
      print('ID seleccionado SILAIS Diagnóstico: $_selectedSILAISDiagnosticoId');
      print('ID seleccionado Establecimiento Diagnóstico: $_selectedEstablecimientoDiagnosticoId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Fondo blanco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF00C1D4), width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Para evitar desbordamiento
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la tarjeta
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
                      '4',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Datos de Diagnóstico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C1D4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Diagnóstico
              _buildCustomDropdownField(
                label: 'Diagnóstico *',
                isLoading: _isLoadingDiagnosticos,
                errorText: _errorDiagnosticos,
                options: _diagnosticos,
                selectedId: _selectedDiagnosticoId,
                controller: diagnosticoController,
                onChanged: (selectedId) {
                  setState(() {
                    _selectedDiagnosticoId = selectedId;
                  });
                  print('Diagnóstico seleccionado ID: $_selectedDiagnosticoId');
                },
                icon: Icons.medical_services,
                hintText: 'Selecciona un diagnóstico',
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Toma de Muestra
              _buildDatePickerField(
                label: 'Fecha de Toma de Muestra *',
                controller: fechaTomaMuestraController,
                hintText: 'Selecciona la fecha de toma de muestra',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Recepción en Laboratorio
              _buildDatePickerField(
                label: 'Fecha de Recepción en Laboratorio *',
                controller: fechaRecepcionLabController,
                hintText: 'Selecciona la fecha de recepción en laboratorio',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Diagnóstico
              _buildDatePickerField(
                label: 'Fecha de Diagnóstico *',
                controller: fechaDiagnosticoController,
                hintText: 'Selecciona la fecha de diagnóstico',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              // Campo: Resultado del Diagnóstico
              _buildCustomDropdownField(
                label: 'Resultado del Diagnóstico *',
                isLoading: _isLoadingResultados,
                errorText: _errorResultados,
                options: _resultadosDiagnostico,
                selectedId: _selectedResultadoDiagnosticoId,
                controller: resultadoDiagnosticoController,
                onChanged: (selectedId) {
                  setState(() {
                    _selectedResultadoDiagnosticoId = selectedId;
                  });
                  print('Resultado Diagnóstico seleccionado ID: $_selectedResultadoDiagnosticoId');
                },
                icon: Icons.assignment_turned_in,
                hintText: 'Selecciona el resultado del diagnóstico',
              ),
              const SizedBox(height: 20),

              // Campo: Densidad Parasitaria Vivax EAS
              _buildTextField(
                label: 'Densidad Parasitaria Vivax EAS *',
                controller: densidadVivaxEASController,
                hintText: 'Ingresa la densidad parasitaria Vivax EAS',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              // Campo: Densidad Parasitaria Vivax ESS
              _buildTextField(
                label: 'Densidad Parasitaria Vivax ESS *',
                controller: densidadVivaxESSController,
                hintText: 'Ingresa la densidad parasitaria Vivax ESS',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              // Campo: Densidad Parasitaria Falciparum EAS
              _buildTextField(
                label: 'Densidad Parasitaria Falciparum EAS *',
                controller: densidadFalciparumEASController,
                hintText: 'Ingresa la densidad parasitaria Falciparum EAS',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              // Campo: Densidad Parasitaria Falciparum ESS
              _buildTextField(
                label: 'Densidad Parasitaria Falciparum ESS *',
                controller: densidadFalciparumESSController,
                hintText: 'Ingresa la densidad parasitaria Falciparum ESS',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              // Campo: SILAIS Diagnóstico con Icono de Búsqueda
              buildSearchableTextField(
                label: 'SILAIS Diagnóstico *',
                controller: silaisDiagnosticoController,
                hintText: 'Selecciona un SILAIS',
                prefixIcon: Icons.location_city,
                onSearch: _abrirDialogoSeleccionRedServicioDiagnostico,
              ),
              const SizedBox(height: 20),

              // Campo: Establecimiento Diagnóstico con Icono de Búsqueda
              buildSearchableTextField(
                label: 'Establecimiento Diagnóstico *',
                controller: establecimientoDiagnosticoController,
                hintText: 'Selecciona un establecimiento',
                prefixIcon: Icons.local_hospital,
                onSearch: _abrirDialogoSeleccionRedServicioDiagnostico,
              ),
              const SizedBox(height: 20),

              // Botón Guardar con animación de carga
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarDatos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C1D4),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      ),
    );
  }
}
