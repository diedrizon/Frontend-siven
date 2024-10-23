import 'package:flutter/material.dart';

class VersionWidget extends StatelessWidget {
  final String versionText;

  const VersionWidget({
    Key? key,
    this.versionText = 'SIVEN 1.0', // Texto de la versión, por defecto "SIVEN 1.0"
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color grisOscuro = Color(0xFF4A4A4A); // Color del texto

    return Container(
      color: Colors.white, // Fondo blanco
      padding: const EdgeInsets.all(8.0), // Padding alrededor del texto
      child: Center(
        child: Text(
          versionText,
          style: const TextStyle(color: grisOscuro), // Estilo del texto
        ),
      ),
    );
  }
}
