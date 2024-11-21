// TerceraTarjeta.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para inputFormatters
import 'package:siven_app/core/services/PuestoNotificacionService.dart';
import 'package:siven_app/widgets/TextField.dart';

class TerceraTarjeta extends StatefulWidget {
  final PuestoNotificacionService puestoNotificacionService;

  const TerceraTarjeta({
    Key? key,
    required this.puestoNotificacionService,
  }) : super(key: key);

  @override
  TerceraTarjetaState createState() => TerceraTarjetaState();
}

class TerceraTarjetaState extends State<TerceraTarjeta> {
  final TextEditingController puestoNotificacionController =
      TextEditingController();
  final TextEditingController numeroClaveController = TextEditingController();
  final TextEditingController numeroLaminaController = TextEditingController();
  final TextEditingController tomaMuestraController = TextEditingController();
  final TextEditingController tipoBusquedaController = TextEditingController();

  List<Map<String, dynamic>> _puestosNotificacion = [];
  String? _selectedPuestoNotificacionId;

  bool? tipoBusquedaValue;

  // Opciones para el campo Tipo de Búsqueda
  final List<String> opcionesTipoBusqueda = ['Activa', 'Pasiva'];

  @override
  void initState() {
    super.initState();
    _fetchPuestosNotificacion();
  }

  @override
  void dispose() {
    // Dispose de los controladores
    puestoNotificacionController.dispose();
    numeroClaveController.dispose();
    numeroLaminaController.dispose();
    tomaMuestraController.dispose();
    tipoBusquedaController.dispose();
    super.dispose();
  }

  Future<void> _fetchPuestosNotificacion() async {
    try {
      List<Map<String, dynamic>> puestos =
          await widget.puestoNotificacionService.listarPuestosNotificacionLocales();
      setState(() {
        _puestosNotificacion = puestos;
      });
    } catch (e) {
      print('Error al cargar los puestos de notificación: $e');
    }
  }

  /// Método para obtener los datos ingresados.
  Map<String, dynamic> getData() {
    print('TipoBusquedaValue en getData(): $tipoBusquedaValue');
    return {
      'selectedPuestoNotificacionId': _selectedPuestoNotificacionId,
      'numeroClave': numeroClaveController.text,
      'numeroLamina': numeroLaminaController.text,
      'tomaMuestra': tomaMuestraController.text,
      'tipoBusqueda': tipoBusquedaValue, // Ahora booleano
    };
  }

  /// Método de validación que retorna una lista de campos con errores.
  List<String> validate() {
    List<String> errors = [];

    // Validar Puesto de Notificación
    if (_selectedPuestoNotificacionId == null ||
        _selectedPuestoNotificacionId!.isEmpty) {
      errors.add('Puesto de Notificación');
    }

    // Validar Número de Clave
    if (numeroClaveController.text.isEmpty) {
      errors.add('Número de Clave');
    }

    // Validar Número de Lámina
    if (numeroLaminaController.text.isEmpty) {
      errors.add('Número de Lámina');
    } else {
      // Asegurarse de que sea solo dígitos
      if (!RegExp(r'^\d+$').hasMatch(numeroLaminaController.text)) {
        errors.add('Número de Lámina debe contener solo dígitos');
      }
    }

    // Validar Toma de Muestra
    if (tomaMuestraController.text.isEmpty) {
      errors.add('Toma de Muestra');
    } else {
      // Asegurarse de que sea solo dígitos
      if (!RegExp(r'^\d+$').hasMatch(tomaMuestraController.text)) {
        errors.add('Toma de Muestra debe contener solo dígitos');
      }
    }

    // Validar Tipo de Búsqueda
    if (tipoBusquedaValue == null) {
      errors.add('Tipo de Búsqueda');
    }

    return errors;
  }

  // Método para construir campos de texto con un formato estándar
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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

  // Método para construir campos desplegables con etiquetas
  Widget _buildDropdownField({
    required String label,
    required CustomTextFieldDropdown dropdown,
  }) {
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
        dropdown,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convertir _puestosNotificacion a List<String> para el CustomTextFieldDropdown
    List<String> opcionesPuestos = _puestosNotificacion.map((puesto) {
      return puesto['nombre'].toString();
    }).toList();

    return Card(
      color: Colors.white, // Establecer color de fondo blanco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF00C1D4), width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Agregar SingleChildScrollView para evitar superposición de Dropdowns
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la tarjeta
              _buildCardTitle(),
              const SizedBox(height: 20),

              // Campo: Puesto de Notificación
              _buildDropdownField(
                label: 'Puesto de Notificación *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona un puesto de notificación',
                  controller: puestoNotificacionController,
                  options: opcionesPuestos,
                  borderColor: const Color(0xFF00C1D4),
                  borderWidth: 1.0,
                  borderRadius: 8.0,
                  onChanged: (selectedOption) {
                    setState(() {
                      // Buscar el puesto seleccionado para obtener su ID
                      final selectedPuesto = _puestosNotificacion.firstWhere(
                          (puesto) =>
                              puesto['nombre'].toString() == selectedOption,
                          orElse: () => {});
                      _selectedPuestoNotificacionId =
                          selectedPuesto['id_puesto_notificacion']?.toString();
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Número de clave
              _buildTextField(
                label: 'Número de clave *',
                controller: numeroClaveController,
                hintText: 'Ingresa el número de clave',
                icon: Icons.vpn_key,
                // Sin inputFormatters para permitir letras y números
              ),
              const SizedBox(height: 20),

              // Campo: Número de Lámina
              _buildTextField(
                label: 'Número de Lámina *',
                controller: numeroLaminaController,
                hintText: 'Ingresa el número de lámina',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo dígitos
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Toma de Muestra
              _buildTextField(
                label: 'Toma de Muestra *',
                controller: tomaMuestraController,
                hintText: 'Ingresa la toma de muestra',
                icon: Icons.science, // Cambia el icono si lo deseas
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo dígitos
                ],
              ),
              const SizedBox(height: 20),

              // Campo: Tipo de Búsqueda (Activa/Pasiva)
              _buildDropdownField(
                label: 'Tipo de Búsqueda *',
                dropdown: CustomTextFieldDropdown(
                  hintText: 'Selecciona una opción',
                  controller: tipoBusquedaController,
                  options: opcionesTipoBusqueda,
                  borderColor: const Color(0xFF00C1D4),
                  borderWidth: 1.0,
                  borderRadius: 8.0,
                  onChanged: (selectedOption) {
                    setState(() {
                      if (selectedOption == 'Activa') {
                        tipoBusquedaValue = true;
                      } else if (selectedOption == 'Pasiva') {
                        tipoBusquedaValue = false;
                      } else {
                        tipoBusquedaValue = null;
                      }
                      print('TipoBusquedaValue: $tipoBusquedaValue');
                    });
                  },
                ),
              ),
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
            '3',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Datos de Notificación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00C1D4),
          ),
        ),
      ],
    );
  }
}
