import 'package:flutter/material.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';

class SeleccionRedServicioTrabajadorWidget extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;

  const SeleccionRedServicioTrabajadorWidget({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
  }) : super(key: key);

  @override
  _SeleccionRedServicioTrabajadorWidgetState createState() =>
      _SeleccionRedServicioTrabajadorWidgetState();
}

class _SeleccionRedServicioTrabajadorWidgetState
    extends State<SeleccionRedServicioTrabajadorWidget> {
  String? selectedSilaisId;
  String? selectedEstablecimientoId;

  List<Map<String, dynamic>> silaisList = [];
  List<Map<String, dynamic>> establecimientosList = [];

  bool isLoadingSilais = true;
  bool isLoadingEstablecimientos = false;

  @override
  void initState() {
    super.initState();
    _loadSilais();
  }

  Future<void> _loadSilais() async {
    try {
      final silaisData = await widget.catalogService.getAllSilais();
      if (mounted) {
        setState(() {
          silaisList = silaisData;
          isLoadingSilais = false;
        });
      }
    } catch (e) {
      print('Error al cargar SILAIS: $e');
      setState(() {
        isLoadingSilais = false;
      });
    }
  }

  Future<void> _loadEstablecimientos(int silaisId) async {
    try {
      setState(() {
        isLoadingEstablecimientos = true;
      });
      final establecimientosData =
          await widget.catalogService.getEstablecimientosBySilais(silaisId);
      if (mounted) {
        setState(() {
          establecimientosList = establecimientosData;
          isLoadingEstablecimientos = false;
        });
      }
    } catch (e) {
      print('Error al cargar Establecimientos: $e');
      setState(() {
        isLoadingEstablecimientos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecciona Red de Servicio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Selección de SILAIS
          isLoadingSilais
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: selectedSilaisId,
                  decoration: InputDecoration(
                    labelText: 'SILAIS',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                    ),
                  ),
                  items: silaisList.map((silais) {
                    return DropdownMenuItem<String>(
                      value: silais['id_silais'].toString(),
                      child: Text(silais['nombre']),
                    );
                  }).toList(),
                  onChanged: (val) async {
                    setState(() {
                      selectedSilaisId = val;
                      selectedEstablecimientoId = null;
                      establecimientosList.clear();
                    });
                    await _loadEstablecimientos(int.parse(val!));
                  },
                ),
          const SizedBox(height: 20),

          // Selección de Establecimiento
          isLoadingEstablecimientos
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
                  value: selectedEstablecimientoId,
                  decoration: InputDecoration(
                    labelText: 'Establecimiento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                    ),
                  ),
                  items: establecimientosList.map((establecimiento) {
                    return DropdownMenuItem<String>(
                      value: establecimiento['id_establecimiento'].toString(),
                      child: Text(establecimiento['nombre']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedEstablecimientoId = val;
                    });
                  },
                ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              if (selectedSilaisId != null &&
                  selectedEstablecimientoId != null) {
                final selectedData = {
                  'silais': silaisList
                      .firstWhere((silais) =>
                          silais['id_silais'].toString() ==
                          selectedSilaisId)['nombre']
                      .toString(),
                  'establecimiento': establecimientosList
                      .firstWhere((establecimiento) =>
                          establecimiento['id_establecimiento'].toString() ==
                          selectedEstablecimientoId)['nombre']
                      .toString(),
                };

                // Agregamos un retraso para evitar el error de navegación
                await Future.delayed(const Duration(milliseconds: 100));
                if (mounted) {
                  Navigator.of(context).pop(selectedData);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C1D4),
            ),
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
  }
}
