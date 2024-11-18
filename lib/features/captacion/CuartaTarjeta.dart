// Importaciones necesarias
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para inputFormatters
import 'package:siven_app/widgets/TextField.dart'; // Asegúrate de que este path sea correcto

/// Cuarta Tarjeta: Datos de Diagnóstico
class CuartaTarjeta extends StatefulWidget {
  const CuartaTarjeta({Key? key}) : super(key: key);

  @override
  _CuartaTarjetaState createState() => _CuartaTarjetaState();
}

class _CuartaTarjetaState extends State<CuartaTarjeta> {
  // Controladores de texto para cada campo
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
  final TextEditingController tipoMuestraController = TextEditingController();
  final TextEditingController metodoAnalisisController =
      TextEditingController();
  final TextEditingController resultadoPruebaController =
      TextEditingController();

  bool _isSaving = false; // Estado para el botón de guardar

  @override
  void dispose() {
    // Dispose de todos los controladores
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

  /// Función para guardar los datos (simulación)
  Future<void> _guardarDatos() async {
    setState(() {
      _isSaving = true;
    });

    // Simular un proceso de guardado
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

  /// Widget para construir campos desplegables con etiquetas
  Widget _buildDropdownField({
    required String label,
    required CustomTextFieldDropdown dropdown,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        dropdown,
      ],
    );
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
              _buildDropdownField(
                label: 'Diagnóstico *',
                dropdown: CustomTextFieldDropdown(
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
                  onChanged: (selectedOption) {
                    // Manejar el cambio si es necesario
                    print('Diagnóstico seleccionado: $selectedOption');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Toma de Muestra
              _buildTextField(
                label: 'Fecha de Toma de Muestra *',
                controller: fechaTomaMuestraController,
                hintText: 'Selecciona la fecha de toma de muestra',
                icon: Icons.calendar_today,
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
                      fechaTomaMuestraController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Recepción en Laboratorio
              _buildTextField(
                label: 'Fecha de Recepción en Laboratorio *',
                controller: fechaRecepcionLabController,
                hintText: 'Selecciona la fecha de recepción en laboratorio',
                icon: Icons.calendar_today,
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
                      fechaRecepcionLabController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Diagnóstico
              _buildTextField(
                label: 'Fecha de Diagnóstico *',
                controller: fechaDiagnosticoController,
                hintText: 'Selecciona la fecha de diagnóstico',
                icon: Icons.calendar_today,
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
                      fechaDiagnosticoController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Campo: Resultado del Diagnóstico
              _buildDropdownField(
                label: 'Resultado del Diagnóstico *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona el resultado del diagnóstico',
                  controller: resultadoDiagnosticoController,
                  options: ['Positivo', 'Negativo', 'Indeterminado'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                  onChanged: (selectedOption) {
                    print(
                        'Resultado del Diagnóstico seleccionado: $selectedOption');
                  },
                ),
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

              // Campo: SILAIS Diagnóstico
              _buildDropdownField(
                label: 'SILAIS Diagnóstico *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona un SILAIS',
                  controller: silaisDiagnosticoController,
                  options: [
                    'SILAIS - ESTELÍ',
                    'SILAIS - LEÓN',
                    'SILAIS - MANAGUA'
                  ],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                  onChanged: (selectedOption) {
                    print('SILAIS Diagnóstico seleccionado: $selectedOption');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Establecimiento Diagnóstico
              _buildDropdownField(
                label: 'Establecimiento Diagnóstico *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona un establecimiento',
                  controller: establecimientoDiagnosticoController,
                  options: [
                    'Laboratorio Central',
                    'Hospital Regional de León',
                    'Centro de Salud Masaya',
                    'Otro'
                  ],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                  onChanged: (selectedOption) {
                    print(
                        'Establecimiento Diagnóstico seleccionado: $selectedOption');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Tipo de Muestra
              _buildDropdownField(
                label: 'Tipo de Muestra *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona el tipo de muestra',
                  controller: tipoMuestraController,
                  options: ['Sangre', 'Orina', 'Esputo', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                  onChanged: (selectedOption) {
                    print('Tipo de Muestra seleccionado: $selectedOption');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Método de Análisis
              _buildDropdownField(
                label: 'Método de Análisis *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona el método de análisis',
                  controller: metodoAnalisisController,
                  options: ['Microscopía', 'PCR', 'Elisa', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                  onChanged: (selectedOption) {
                    print('Método de Análisis seleccionado: $selectedOption');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Resultado de la Prueba
              _buildDropdownField(
                label: 'Resultado de la Prueba *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona el resultado de la prueba',
                  controller: resultadoPruebaController,
                  options: ['Positivo', 'Negativo', 'Indeterminado'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                  onChanged: (selectedOption) {
                    print(
                        'Resultado de la Prueba seleccionado: $selectedOption');
                  },
                ),
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
        ),
      ),
    );
  }
}
