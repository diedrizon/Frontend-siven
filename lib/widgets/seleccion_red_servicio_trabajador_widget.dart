import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
      if (mounted) {
        setState(() {
          isLoadingSilais = false;
        });
      }
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
      if (mounted) {
        setState(() {
          isLoadingEstablecimientos = false;
        });
      }
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink, // Título en color rosado
            ),
          ),
          const SizedBox(height: 20),

          // Selección de SILAIS
          dropdownSearchField(
            label: 'SILAIS',
            currentValue: selectedSilaisId,
            items: silaisList,
            isLoading: isLoadingSilais,
            idKey: 'id_silais',
            onChanged: (val) async {
              setState(() {
                selectedSilaisId = val;
                selectedEstablecimientoId = null;
                establecimientosList.clear();
              });
              if (val != null) {
                print('SILAIS seleccionado ID: $val');
                await _loadEstablecimientos(int.parse(val));
              }
            },
          ),
          const SizedBox(height: 20),

          // Selección de Establecimiento
          dropdownSearchField(
            label: 'Establecimiento',
            currentValue: selectedEstablecimientoId,
            items: establecimientosList,
            isLoading: isLoadingEstablecimientos,
            idKey: 'id_establecimiento',
            onChanged: (val) {
              setState(() {
                selectedEstablecimientoId = val;
              });
              if (val != null) {
                print('Establecimiento seleccionado ID: $val');
              }
            },
          ),
          const SizedBox(height: 20),

          // Botón CONTINUAR
          ElevatedButton(
            onPressed: () async {
              if (selectedSilaisId != null && selectedEstablecimientoId != null) {
                final selectedData = {
                  'silais': silaisList
                      .firstWhere((silais) =>
                          silais['id_silais'].toString() == selectedSilaisId)['nombre']
                      .toString(),
                  'establecimiento': establecimientosList
                      .firstWhere((establecimiento) =>
                          establecimiento['id_establecimiento'].toString() ==
                          selectedEstablecimientoId)['nombre']
                      .toString(),
                  'silaisId': selectedSilaisId!,
                  'establecimientoId': selectedEstablecimientoId!,
                };

                print('Seleccionado SILAIS ID: ${selectedData['silaisId']}');
                print('Seleccionado Establecimiento ID: ${selectedData['establecimientoId']}');

                await Future.delayed(const Duration(milliseconds: 100));
                if (mounted) {
                  Navigator.of(context).pop(selectedData);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, selecciona SILAIS y Establecimiento'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C1D4),
              foregroundColor: Colors.white, // Texto en blanco
            ),
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
  }

  Widget dropdownSearchField({
    required String label,
    required String? currentValue,
    required List<Map<String, dynamic>> items,
    required bool isLoading,
    required String idKey,
    required ValueChanged<String?> onChanged,
  }) {
    return isLoading
        ? const CircularProgressIndicator()
        : DropdownSearch<Map<String, dynamic>>(
            items: items,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              itemBuilder: (context, item, isSelected) {
                return ListTile(
                  title: Text(item['nombre']),
                );
              },
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Buscar $label',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF00C1D4),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              emptyBuilder: (context, searchEntry) => Center(
                child: Text('No hay coincidencias para $label'),
              ),
              constraints: const BoxConstraints(maxHeight: 400),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: label,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF00C1D4), // Bordes celeste siempre
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF00C1D4), // Bordes celeste al enfocar
                    width: 2.0,
                  ),
                ),
              ),
            ),
            itemAsString: (item) => item['nombre'],
            selectedItem: currentValue != null
                ? items.firstWhere(
                    (item) => item[idKey].toString() == currentValue,
                    orElse: () => {},
                  )
                : null,
            onChanged: (Map<String, dynamic>? value) {
              final selectedId = value != null ? value[idKey].toString() : null;
              onChanged(selectedId);
            },
          );
  }
}
