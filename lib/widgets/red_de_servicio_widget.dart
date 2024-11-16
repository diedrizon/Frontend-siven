import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';

class RedDeServicioWidget extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;

  const RedDeServicioWidget({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
  }) : super(key: key);

  @override
  _RedDeServicioWidgetState createState() => _RedDeServicioWidgetState();
}

class _RedDeServicioWidgetState extends State<RedDeServicioWidget> {
  String? selectedSilaisId;
  String? selectedUnidadSaludId;
  List<Map<String, dynamic>> silaisList = [];
  List<Map<String, dynamic>> establecimientosList = [];

  @override
  void initState() {
    super.initState();
    widget.selectionStorageService.clearSelections().then((_) {
      _initializeData();
    });
  }

  Future<void> _loadSilais() async {
    try {
      // Primero verifica si los datos están en caché
      final cachedSilais = await widget.selectionStorageService.getSilaisListCache();
      if (cachedSilais != null && cachedSilais.isNotEmpty) {
        setState(() {
          silaisList = cachedSilais;
        });
      } else {
        // Si no están en caché, carga los datos de la API y almacénalos
        final silaisData = await widget.catalogService.getAllSilais();
        setState(() {
          silaisList = silaisData;
        });
        await widget.selectionStorageService.saveSilaisListCache(silaisData);
      }
    } catch (e) {
      print('Error al cargar SILAIS: $e');
    }
  }

  Future<void> _loadEstablecimientos(int idSilais) async {
    try {
      // Verifica si los establecimientos están en caché para el SILAIS seleccionado
      final cachedEstablecimientos = await widget.selectionStorageService.getEstablecimientosCache(idSilais);
      if (cachedEstablecimientos != null && cachedEstablecimientos.isNotEmpty) {
        setState(() {
          establecimientosList = cachedEstablecimientos;
        });
      } else {
        // Si no están en caché, carga los datos de la API y almacénalos
        final establecimientosData = await widget.catalogService.getEstablecimientosBySilais(idSilais);
        setState(() {
          establecimientosList = establecimientosData;
        });
        await widget.selectionStorageService.saveEstablecimientosCache(idSilais, establecimientosData);
      }
    } catch (e) {
      print('Error al cargar establecimientos: $e');
    }
  }

  Future<void> _initializeData() async {
    final cachedSilaisId = await widget.selectionStorageService.getSelectedSilais();
    final cachedUnidadSaludId = await widget.selectionStorageService.getSelectedUnidadSalud();

    if (cachedSilaisId != null && cachedSilaisId.isNotEmpty) {
      setState(() {
        selectedSilaisId = cachedSilaisId;
        selectedUnidadSaludId = cachedUnidadSaludId?.isNotEmpty == true
            ? cachedUnidadSaludId
            : null;
      });
      await _loadEstablecimientos(int.parse(cachedSilaisId));
    }

    if (selectedSilaisId == null) {
      await _loadSilais();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        dropdownSearchField(
          'SILAIS',
          selectedSilaisId,
          silaisList,
          TextEditingController(),
          (val) async {
            setState(() {
              selectedSilaisId = val;
              selectedUnidadSaludId = null;
              establecimientosList.clear();
            });
            await widget.selectionStorageService.saveSelectedSilais(val!);
            await _loadEstablecimientos(int.parse(val));
          },
          () {
            setState(() {
              selectedSilaisId = null;
              establecimientosList.clear();
            });
            widget.selectionStorageService.clearSelections();
          },
          'id_silais',
        ),
        const SizedBox(height: 30.0),
        dropdownSearchField(
          'Seleccione Unidad de Salud',
          selectedUnidadSaludId,
          establecimientosList,
          TextEditingController(),
          (val) async {
            setState(() {
              selectedUnidadSaludId = val;
            });
            await widget.selectionStorageService.saveSelectedUnidadSalud(val!);
          },
          () {
            setState(() {
              selectedUnidadSaludId = null;
            });
            widget.selectionStorageService.clearSelections();
          },
          'id_establecimiento',
        ),
      ],
    );
  }

  Widget dropdownSearchField(
    String label,
    String? currentValue,
    List<Map<String, dynamic>> items,
    TextEditingController controller,
    ValueChanged<String?> onChanged,
    VoidCallback onClearSelection,
    String idKey,
  ) {
    return DropdownSearch<Map<String, dynamic>>(
      items: items,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) {
          return ListTile(
            title: Text(item['nombre']),
          );
        },
        searchFieldProps: TextFieldProps(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Buscar $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 122, 193, 255),
                width: 2.0,
              ),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onClearSelection,
            ),
          ),
        ),
        emptyBuilder: (context, searchEntry) => Center(
          child: Text('No hay coincidencias de $label'),
        ),
        fit: FlexFit.loose,
        constraints: BoxConstraints(
          maxHeight: 240,
        ),
      ),
      itemAsString: (item) => item['nombre'],
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 122, 193, 255),
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 122, 193, 255),
              width: 2.0,
            ),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onClearSelection,
          ),
        ),
      ),
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
      dropdownBuilder: (context, Map<String, dynamic>? selectedItem) {
        return Text(selectedItem != null ? selectedItem['nombre'] : 'Seleccione $label');
      },
    );
  }
}
