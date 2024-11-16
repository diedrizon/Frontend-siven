import 'package:flutter/material.dart';
import 'package:siven_app/widgets/TextField.dart';

class CuartaTarjeta extends StatefulWidget {
  const CuartaTarjeta({Key? key}) : super(key: key);

  @override
  _CuartaTarjetaState createState() => _CuartaTarjetaState();
}

class _CuartaTarjetaState extends State<CuartaTarjeta> {
  final TextEditingController diagnosticoController = TextEditingController();
  final TextEditingController fechaTomaMuestraController = TextEditingController();
  final TextEditingController fechaRecepcionLabController = TextEditingController();
  final TextEditingController fechaDiagnosticoController = TextEditingController();
  final TextEditingController resultadoDiagnosticoController = TextEditingController();
  final TextEditingController densidadVivaxEASController = TextEditingController();
  final TextEditingController densidadVivaxESSController = TextEditingController();
  final TextEditingController densidadFalciparumEASController = TextEditingController();
  final TextEditingController densidadFalciparumESSController = TextEditingController();
  final TextEditingController silaisDiagnosticoController = TextEditingController();
  final TextEditingController establecimientoDiagnosticoController = TextEditingController();
  final TextEditingController tipoMuestraController = TextEditingController();
  final TextEditingController metodoAnalisisController = TextEditingController();
  final TextEditingController resultadoPruebaController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    // Dispose de los controladores
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

  Future<void> _guardarDatos() async {
    setState(() {
      _isSaving = true;
    });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      // Aquí va todo el contenido de la cuarta tarjeta, utilizando los controladores locales y manteniendo el mismo diseño
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
                    '4',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco
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
                    color: Color(0xFF00C1D4), // Texto celeste
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Diagnóstico
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diagnóstico *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un diagnóstico',
                  controller: diagnosticoController,
                  options: ['Malaria Vivax', 'Malaria Falciparum', 'Co-infección', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Fecha de Toma de Muestra
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha de Toma de Muestra *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: fechaTomaMuestraController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Selecciona la fecha de toma de muestra',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C1D4)),
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
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        fechaTomaMuestraController.text = "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Fecha de Recepción en Laboratorio
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha de Recepción en Laboratorio *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: fechaRecepcionLabController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Selecciona la fecha de recepción en laboratorio',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C1D4)),
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
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        fechaRecepcionLabController.text = "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Fecha de Diagnóstico
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha de Diagnóstico *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: fechaDiagnosticoController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Selecciona la fecha de diagnóstico',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C1D4)),
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
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        fechaDiagnosticoController.text = "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Resultado del Diagnóstico
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado del Diagnóstico *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona el resultado del diagnóstico',
                  controller: resultadoDiagnosticoController,
                  options: ['Positivo', 'Negativo', 'Indeterminado'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Densidad Parasitaria Vivax EAS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Densidad Parasitaria Vivax EAS *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: densidadVivaxEASController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la densidad parasitaria Vivax EAS',
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

            // Campo: Densidad Parasitaria Vivax ESS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Densidad Parasitaria Vivax ESS *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: densidadVivaxESSController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la densidad parasitaria Vivax ESS',
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

            // Campo: Densidad Parasitaria Falciparum EAS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Densidad Parasitaria Falciparum EAS *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: densidadFalciparumEASController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la densidad parasitaria Falciparum EAS',
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

            // Campo: Densidad Parasitaria Falciparum ESS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Densidad Parasitaria Falciparum ESS *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: densidadFalciparumESSController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la densidad parasitaria Falciparum ESS',
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

            // Campo: SILAIS Diagnóstico
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SILAIS Diagnóstico *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un SILAIS',
                  controller: silaisDiagnosticoController,
                  options: ['SILAIS - ESTELÍ', 'SILAIS - LEÓN', 'SILAIS - MANAGUA'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Establecimiento Diagnóstico
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Establecimiento Diagnóstico *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona un establecimiento',
                  controller: establecimientoDiagnosticoController,
                  options: ['Laboratorio Central', 'Hospital Regional de León', 'Centro de Salud Masaya', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Tipo de Muestra
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de Muestra *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona el tipo de muestra',
                  controller: tipoMuestraController,
                  options: ['Sangre', 'Orina', 'Esputo', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Método de Análisis
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de Análisis *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona el método de análisis',
                  controller: metodoAnalisisController,
                  options: ['Microscopía', 'PCR', 'Elisa', 'Otro'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Resultado de la Prueba
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado de la Prueba *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFieldDropdown(
                  hintText: 'Selecciona el resultado de la prueba',
                  controller: resultadoPruebaController,
                  options: ['Positivo', 'Negativo', 'Indeterminado'],
                  borderColor: const Color(0xFF00C1D4),
                  borderRadius: 8.0,
                  width: double.infinity,
                  height: 55.0,
                ),
              ],
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
    );
  }
}
