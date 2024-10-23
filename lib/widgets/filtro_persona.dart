import 'package:flutter/material.dart';

// Widget Reutilizable de Filtro por Persona
class FiltroPersonaWidget extends StatelessWidget {
  final String hintText;
  final Color colorBorde;
  final Color colorIcono;
  final Color colorTexto;
  final double iconoTamano;
  final ValueChanged<String>? onChanged;

  const FiltroPersonaWidget({
    Key? key,
    required this.hintText,
    this.colorBorde = Colors.orange,
    this.colorIcono = Colors.grey,
    this.colorTexto = Colors.black,
    this.iconoTamano = 24.0,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.filter_list,
          size: iconoTamano,
          color: colorIcono,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: colorTexto),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colorBorde,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colorBorde,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colorBorde,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
