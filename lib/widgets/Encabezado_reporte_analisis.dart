import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';

// Encabezado con el texto Bienvenido y logo
class EncabezadoBienvenida extends StatelessWidget {
  const EncabezadoBienvenida({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Bienvenido a ',
                  style: TextStyle(
                    color: Color(0xFF1877F2),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Image.asset(
                  'lib/assets/homeicon/siven.webp', // Ruta del logo
                  height: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Botón Centro de Salud con la Unidad de Salud seleccionada
class BotonCentroSalud extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final VoidCallback? onSelectionChanged;

  const BotonCentroSalud({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  _BotonCentroSaludState createState() => _BotonCentroSaludState();
}

class _BotonCentroSaludState extends State<BotonCentroSalud> {
  String? unidadSaludName;

  @override
  void initState() {
    super.initState();
    _loadUnidadSaludName();
  }

  Future<void> _loadUnidadSaludName() async {
    try {
      final unidadSaludIdString =
          await widget.selectionStorageService.getSelectedUnidadSalud();

      if (unidadSaludIdString != null && unidadSaludIdString.isNotEmpty) {
        final unidadSaludId = int.parse(unidadSaludIdString);
        final unidadSaludData =
            await widget.catalogService.getEstablecimientoById(unidadSaludId);
        if (mounted) {
          setState(() {
            unidadSaludName = unidadSaludData['nombre'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            unidadSaludName = 'Unidad de Salud no seleccionada';
          });
        }
      }
    } catch (e) {
      print('Error al cargar nombre de Unidad de Salud seleccionada: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayUnidadSaludName =
        unidadSaludName ?? 'Unidad de Salud no seleccionada';

    return ElevatedButton.icon(
      onPressed: () async {
        // Mostrar el diálogo modal con el widget RedDeServicioWidget
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Cambiar Red de Servicio',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Color(0xFFFF5D8F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // Widget para cambiar la red de servicio
                      RedDeServicioWidget(
                        catalogService: widget.catalogService,
                        selectionStorageService: widget.selectionStorageService,
                      ),
                      const SizedBox(height: 20.0),
                      // Botón para cerrar el diálogo
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'CONTINUAR',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        // Después de cerrar el diálogo, recargar el nombre de la Unidad de Salud
        await _loadUnidadSaludName();
        // Notificar al padre que la selección ha cambiado
        if (widget.onSelectionChanged != null) {
          widget.onSelectionChanged!();
        }
      },
      icon: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.white,
        child: const Icon(Icons.apartment, color: Color(0xFF4A4A4A), size: 14),
      ),
      label: Text(
        displayUnidadSaludName,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 163, 162, 162),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Ícono de perfil de usuario
class IconoPerfil extends StatelessWidget {
  const IconoPerfil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.person, color: Color(0xFF4A4A4A), size: 24),
        onPressed: () {
          // Acción para abrir perfil de usuario o configuraciones
        },
      ),
    );
  }
}

// Texto RED DE SERVICIO con los nombres seleccionados
class RedDeServicio extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;

  const RedDeServicio({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
  }) : super(key: key);

  @override
  _RedDeServicioState createState() => _RedDeServicioState();
}

class _RedDeServicioState extends State<RedDeServicio> {
  String? silaisName;
  String? unidadSaludName;

  @override
  void initState() {
    super.initState();
    _loadSelectedNames();
  }

  Future<void> _loadSelectedNames() async {
    try {
      // Obtener los IDs seleccionados del almacenamiento
      final silaisIdString =
          await widget.selectionStorageService.getSelectedSilais();
      final unidadSaludIdString =
          await widget.selectionStorageService.getSelectedUnidadSalud();

      if (silaisIdString != null && silaisIdString.isNotEmpty) {
        final silaisId = int.parse(silaisIdString);
        // Obtener el nombre del SILAIS
        final silaisData = await widget.catalogService.getSilaisById(silaisId);
        if (mounted) {
          setState(() {
            silaisName = silaisData['nombre'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            silaisName = 'SILAIS no seleccionado';
          });
        }
      }

      if (unidadSaludIdString != null && unidadSaludIdString.isNotEmpty) {
        final unidadSaludId = int.parse(unidadSaludIdString);
        // Obtener el nombre de la Unidad de Salud
        final unidadSaludData =
            await widget.catalogService.getEstablecimientoById(unidadSaludId);
        if (mounted) {
          setState(() {
            unidadSaludName = unidadSaludData['nombre'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            unidadSaludName = 'Unidad de Salud no seleccionada';
          });
        }
      }
    } catch (e) {
      print('Error al cargar nombres seleccionados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displaySilaisName = silaisName ?? 'SILAIS no seleccionado';
    final displayUnidadSaludName =
        unidadSaludName ?? 'Unidad de Salud no seleccionada';

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'RED DE SERVICIO:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          TextSpan(
            text: '$displaySilaisName\n',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF000000),
            ),
          ),
          TextSpan(
            text: displayUnidadSaludName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Widget RedDeServicioWidget para cambiar la red de servicio
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
  bool isLoadingSilais = true;
  bool isLoadingEstablecimientos = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
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

  // Cargar la lista de establecimientos con base al SILAIS seleccionado
  Future<void> _loadEstablecimientos(int idSilais) async {
    try {
      setState(() {
        isLoadingEstablecimientos = true;
      });
      final establecimientosData =
          await widget.catalogService.getEstablecimientosBySilais(idSilais);
      if (mounted) {
        setState(() {
          establecimientosList = establecimientosData;
          isLoadingEstablecimientos = false;
        });
      }
    } catch (e) {
      print('Error al cargar establecimientos: $e');
      if (mounted) {
        setState(() {
          isLoadingEstablecimientos = false;
        });
      }
    }
  }

  // Controlar la carga de SILAIS y cache
  Future<void> _initializeData() async {
    // Cargar las selecciones guardadas
    final cachedSilaisId =
        await widget.selectionStorageService.getSelectedSilais();
    final cachedUnidadSaludId =
        await widget.selectionStorageService.getSelectedUnidadSalud();

    // Cargar los SILAIS
    await _loadSilais();

    // Si hay una selección cacheada, cargarla
    if (cachedSilaisId != null && cachedSilaisId.isNotEmpty) {
      if (!mounted) return; // Verificar si el widget sigue montado
      setState(() {
        selectedSilaisId = cachedSilaisId;
        selectedUnidadSaludId = cachedUnidadSaludId?.isNotEmpty == true
            ? cachedUnidadSaludId
            : null;
      });

      // Cargar los establecimientos correspondientes al SILAIS cacheado
      await _loadEstablecimientos(int.parse(cachedSilaisId));
    } else {
      setState(() {
        isLoadingSilais = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isLoadingSilais
            ? const CircularProgressIndicator()
            : dropdownSearchField(
                'SILAIS',
                selectedSilaisId,
                silaisList,
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
        isLoadingEstablecimientos
            ? const CircularProgressIndicator()
            : dropdownSearchField(
                'Seleccione Unidad de Salud',
                selectedUnidadSaludId,
                establecimientosList,
                (val) async {
                  setState(() {
                    selectedUnidadSaludId = val;
                  });
                  await widget.selectionStorageService
                      .saveSelectedUnidadSalud(val!);
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

  // Dentro de tu widget RedDeServicioWidget

  Widget dropdownSearchField(
    String label,
    String? currentValue,
    List<Map<String, dynamic>> items,
    ValueChanged<String?> onChanged,
    VoidCallback onClearSelection,
    String idKey, // Clave para el ID ('id_silais' o 'id_establecimiento')
  ) {
    // Función auxiliar para obtener el elemento seleccionado
    Map<String, dynamic>? getSelectedItem() {
      try {
        return currentValue != null
            ? items.firstWhere(
                (item) => item[idKey].toString() == currentValue,
              )
            : null;
      } catch (e) {
        return null;
      }
    }

    return DropdownSearch<Map<String, dynamic>>(
      items: items,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) {
          return ListTile(
            title: Text(item['nombre']),
          );
        },
        emptyBuilder: (context, searchEntry) => Center(
          child: Text('No hay coincidencias de $label'),
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
      selectedItem: getSelectedItem(),
      onChanged: (Map<String, dynamic>? value) {
        final selectedId = value != null ? value[idKey].toString() : null;
        onChanged(selectedId);
      },
      dropdownBuilder: (context, Map<String, dynamic>? selectedItem) {
        return Text(selectedItem != null
            ? selectedItem['nombre']
            : 'Seleccione $label');
      },
    );
  }
}
