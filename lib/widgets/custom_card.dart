import 'package:flutter/material.dart';

/// Clase que representa un elemento de tarjeta con texto, ícono y color de fondo.
class CardItem {
  final String text; // Texto que se mostrará en la tarjeta.
  final String iconPath; // Ruta del ícono que se mostrará en la tarjeta.
  final Color backgroundColor; // Color de fondo de la tarjeta.

  /// Constructor de la clase CardItem con parámetros requeridos.
  CardItem({
    required this.text,
    required this.iconPath,
    required this.backgroundColor,
  });
}

/// Widget personalizado para crear una tarjeta con diseño específico.
class CustomCard extends StatelessWidget {
  final CardItem item; // Elemento de tarjeta que se va a mostrar.
  final double
      screenHeight; // Altura de la pantalla para ajustar el tamaño de la tarjeta.
  final VoidCallback?
      onTap; // Añadir esta línea para manejar toques en la tarjeta.

  /// Constructor de CustomCard con parámetros requeridos.
  CustomCard({required this.item, required this.screenHeight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Usa el callback aquí para manejar el toque en la tarjeta.
      child: Container(
        width: double.infinity, // Ancho completo del contenedor.
        height: screenHeight *
            0.22, // Altura adaptada al 22% de la altura de la pantalla.
        decoration: BoxDecoration(
          color: item.backgroundColor, // Color de fondo de la tarjeta.
          borderRadius:
              BorderRadius.circular(10), // Bordes redondeados de la tarjeta.
          boxShadow: [
            BoxShadow(
              color: Colors.black26, // Color de la sombra.
              blurRadius: 4, // Radio de desenfoque de la sombra.
              offset: Offset(2, 2), // Desplazamiento de la sombra.
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
                width:
                    16), // Espaciador horizontal a la izquierda para el padding.
            Expanded(
              child: Align(
                alignment:
                    Alignment.centerLeft, // Alinea el texto a la izquierda.
                child: Text(
                  item.text, // Texto de la tarjeta.
                  style: TextStyle(
                    color: Colors.white, // Color del texto.
                    fontSize: 20, // Tamaño de fuente.
                    fontWeight: FontWeight.bold, // Grosor de la fuente.
                  ),
                  maxLines: 3, // Número máximo de líneas.
                  overflow:
                      TextOverflow.ellipsis, // Indicador de desbordamiento.
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0), // Padding a la derecha del ícono.
              child: Image.asset(
                item.iconPath, // Ruta del ícono.
                width: 100, // Ancho del ícono.
                height: 100, // Altura del ícono.
                color: Colors.white, // Color del ícono.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
