import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Color borderColor;
  final Color iconColor;
  final double borderWidth;
  final double borderRadius;
  final double width;
  final double height;

  const CustomDateField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.borderColor = Colors.orange,
    this.iconColor = Colors.grey,
    this.borderWidth = 2.0,
    this.borderRadius = 5.0,
    this.width = double.infinity,
    this.height = 50.0,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () {
          _selectDate(context);
        },
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: Icon(Icons.calendar_today, size: 20, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
        ),
      ),
    );
  }
}
