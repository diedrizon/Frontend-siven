import 'package:flutter/material.dart';

// Widget Reutilizable para las Cards de Persona
class CardPersonaWidget extends StatelessWidget {
  final String identificacion;
  final String expediente;
  final String nombre;
  final String ubicacion;
  final Color colorBorde;
  final Color colorBoton;
  final String textoBoton;
  final VoidCallback onBotonPressed;

  const CardPersonaWidget({
    Key? key,
    required this.identificacion,
    required this.expediente,
    required this.nombre,
    required this.ubicacion,
    this.colorBorde = Colors.orange,
    this.colorBoton = Colors.orange,
    this.textoBoton = 'Generar Reporte', // Texto por defecto
    required this.onBotonPressed, // Acción al presionar el botón
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: colorBorde, // Borde personalizable
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identificación: $identificacion',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Código expediente: $expediente',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Nombre completo: $nombre',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Municipio/Departamento: $ubicacion',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            // Botón personalizable
            Center(
              child: ElevatedButton(
                onPressed: onBotonPressed, // Acción personalizada
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorBoton, // Color del botón
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(300, 40), // Tamaño del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  textoBoton, // Texto del botón personalizable
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
