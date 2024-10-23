import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : 'Seleccione una fecha',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime initialDate = selectedDate ?? DateTime.now();
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
    );
  }
}
