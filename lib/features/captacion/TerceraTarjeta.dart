import 'package:flutter/material.dart';
import 'package:siven_app/widgets/TextField.dart';

class TerceraTarjeta extends StatefulWidget {
  const TerceraTarjeta({Key? key}) : super(key: key);

  @override
  _TerceraTarjetaState createState() => _TerceraTarjetaState();
}

class _TerceraTarjetaState extends State<TerceraTarjeta> {
  final TextEditingController puestoNotificacionController = TextEditingController();
  final TextEditingController claveNotificacionController = TextEditingController();
  final TextEditingController numeroLaminaController = TextEditingController();
  final TextEditingController tomaMuestraController = TextEditingController();
  final TextEditingController tipoBusquedaController = TextEditingController();

  @override
  void dispose() {
    // Dispose de los controladores
    puestoNotificacionController.dispose();
    claveNotificacionController.dispose();
    numeroLaminaController.dispose();
    tomaMuestraController.dispose();
    tipoBusquedaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Aquí va todo el contenido de la tercera tarjeta, utilizando los controladores locales y manteniendo el mismo diseño
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
                    '3',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco
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
                    color: Color(0xFF00C1D4), // Texto celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Puesto de Notificación
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
                  options: ['Centro de Salud Masaya', 'Hospital Regional de León', 'Laboratorio Central', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Clave de Notificación
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
                    prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFF00C1D4)),
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

            // Campo: Número de Lámina
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
                    prefixIcon: const Icon(Icons.numbers, color: Color(0xFF00C1D4)),
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

            // Campo: Toma de Muestra
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
                  options: ['Sangre', 'Orina', 'Esputo', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Tipo de Búsqueda
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
                  options: ['Activa', 'Pasiva', 'Centinela', 'Otra'],
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
}
