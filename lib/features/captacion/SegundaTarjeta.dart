import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart';
import 'package:siven_app/core/services/CondicionPersonaService.dart';
import 'package:siven_app/core/services/SitioExposicionService.dart';
import 'package:siven_app/core/services/LugarIngresoPaisService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/SintomasService.dart';
import 'package:siven_app/widgets/MapSelectionScreen.dart';
import 'package:siven_app/widgets/seleccion_red_servicio_trabajador_widget.dart';
import 'package:siven_app/widgets/search_persona_widget.dart';
import 'package:siven_app/widgets/TextField.dart'; // Importar CustomTextFieldDropdown

// Importaciones adicionales necesarias
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:location/location.dart'; // Para obtener la ubicación
import 'package:geojson/geojson.dart'; // Para trabajar con GeoJSON

/// Formateador para limitar la entrada numérica a un rango específico.
class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < min || value > max) {
      return oldValue;
    }

    return newValue;
  }
}

/// Clase para representar opciones de Dropdown con ID y Nombre.
class DropdownOption {
  final String id;
  final String name;

  DropdownOption({required this.id, required this.name});
}

class SegundaTarjeta extends StatefulWidget {
  final CatalogServiceRedServicio catalogService;
  final SelectionStorageService selectionStorageService;
  final LugarCaptacionService lugarCaptacionService;
  final CondicionPersonaService condicionPersonaService;
  final SitioExposicionService sitioExposicionService;
  final LugarIngresoPaisService lugarIngresoPaisService;
  final SintomasService sintomasService;

  const SegundaTarjeta({
    Key? key,
    required this.catalogService,
    required this.selectionStorageService,
    required this.lugarCaptacionService,
    required this.condicionPersonaService,
    required this.sitioExposicionService,
    required this.lugarIngresoPaisService,
    required this.sintomasService,
  }) : super(key: key);

  @override
  _SegundaTarjetaState createState() => _SegundaTarjetaState();
}

class _SegundaTarjetaState extends State<SegundaTarjeta> {
  // Controladores de texto
  final TextEditingController lugarCaptacionController =
      TextEditingController();
  final TextEditingController condicionPersonaController =
      TextEditingController();
  final TextEditingController fechaCaptacionController =
      TextEditingController();
  final TextEditingController semanaEpidemiologicaController =
      TextEditingController();
  final TextEditingController silaisCaptacionController =
      TextEditingController();
  final TextEditingController establecimientoCaptacionController =
      TextEditingController();
  final TextEditingController sitioExposicionController =
      TextEditingController();
  final TextEditingController latitudOcurrenciaController =
      TextEditingController();
  final TextEditingController longitudOcurrenciaController =
      TextEditingController();
  final TextEditingController presentaSintomasController =
      TextEditingController();
  final TextEditingController fechaInicioSintomasController =
      TextEditingController();
  final TextEditingController sintomasController = TextEditingController();
  final TextEditingController fueReferidoController = TextEditingController();
  final TextEditingController silaisTrasladoController =
      TextEditingController();
  final TextEditingController establecimientoTrasladoController =
      TextEditingController();
  final TextEditingController esViajeroController = TextEditingController();
  final TextEditingController fechaIngresoPaisController =
      TextEditingController();
  final TextEditingController lugarIngresoPaisController =
      TextEditingController();
  final TextEditingController observacionesCaptacionController =
      TextEditingController();

  // Variables de estado para manejar dinámicamente las selecciones
  List<DropdownOption> lugaresCaptacion = [];
  String? selectedLugarCaptacionId;
  bool isLoadingLugares = true;
  String? errorLugares;

  List<DropdownOption> condicionesPersona = [];
  String? selectedCondicionPersonaId;
  bool isLoadingCondiciones = true;
  String? errorCondiciones;

  List<DropdownOption> sitiosExposicion = [];
  String? selectedSitioExposicionId;
  bool isLoadingSitios = true;
  String? errorSitios;

  List<DropdownOption> lugaresIngresoPais = [];
  String? selectedLugarIngresoPaisId;
  bool isLoadingIngresoPais = true;
  String? errorIngresoPais;

  // Variables para Síntomas
  List<DropdownOption> sintomas = [];
  String? selectedSintomaId;
  bool isLoadingSintomas = true;
  String? errorSintomas;

  // Opciones para campos de preguntas binarias
  final List<DropdownOption> yesNoOptions = [
    DropdownOption(id: 'si', name: 'Sí'),
    DropdownOption(id: 'no', name: 'No'),
  ];

  bool _presentaSintomas = false;
  bool _fueReferido = false;
  bool _esViajero = false;

  // Variables para almacenar los IDs seleccionados para Captación y Traslado
  String? selectedSILAISCaptacionId;
  String? selectedEstablecimientoCaptacionId;

  String? selectedSILAISTrasladoId;
  String? selectedEstablecimientoTrasladoId;

  // Variable para almacenar el ID de la persona que captó
  int? _personaCaptadaId;

  @override
  void initState() {
    super.initState();
    // Cargar todas las listas de Dropdown
    fetchLugaresCaptacion();
    fetchCondicionesPersona();
    fetchSitiosExposicion();
    fetchLugarIngresoPais();
    fetchSintomas();

    // Listeners para actualizaciones dinámicas
    presentaSintomasController.addListener(_actualizarPresentaSintomas);
    fueReferidoController.addListener(_actualizarFueReferido);
    esViajeroController.addListener(_actualizarEsViajero);
  }

  @override
  void dispose() {
    // Dispose de los controladores
    lugarCaptacionController.dispose();
    condicionPersonaController.dispose();
    fechaCaptacionController.dispose();
    semanaEpidemiologicaController.dispose();
    silaisCaptacionController.dispose();
    establecimientoCaptacionController.dispose();
    sitioExposicionController.dispose();
    latitudOcurrenciaController.dispose();
    longitudOcurrenciaController.dispose();
    presentaSintomasController.removeListener(_actualizarPresentaSintomas);
    presentaSintomasController.dispose();
    fechaInicioSintomasController.dispose();
    sintomasController.dispose();
    fueReferidoController.removeListener(_actualizarFueReferido);
    fueReferidoController.dispose();
    silaisTrasladoController.dispose();
    establecimientoTrasladoController.dispose();
    esViajeroController.removeListener(_actualizarEsViajero);
    esViajeroController.dispose();
    fechaIngresoPaisController.dispose();
    lugarIngresoPaisController.dispose();
    observacionesCaptacionController.dispose();
    super.dispose();
  }

  // Función para actualizar el estado según si presenta síntomas
  void _actualizarPresentaSintomas() {
    setState(() {
      _presentaSintomas = presentaSintomasController.text == 'Sí';
    });
  }

  // Función para actualizar el estado según si fue referido
  void _actualizarFueReferido() {
    setState(() {
      _fueReferido = fueReferidoController.text == 'Sí';
    });
  }

  // Función para actualizar el estado según si es viajero
  void _actualizarEsViajero() {
    setState(() {
      _esViajero = esViajeroController.text == 'Sí';
    });
  }

  // Funciones para obtener datos de los servicios
  Future<void> fetchLugaresCaptacion() async {
    try {
      List<Map<String, dynamic>> lugares =
          await widget.lugarCaptacionService.listarLugaresCaptacion();
      List<DropdownOption> opciones = lugares.map((e) {
        return DropdownOption(
          id: e['id_lugar_captacion'].toString(),
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        lugaresCaptacion = opciones;
        isLoadingLugares = false;
      });

      print('Opciones de Lugares de Captación cargadas:');
      lugaresCaptacion.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorLugares = 'Error al cargar lugares de captación: $e';
        isLoadingLugares = false;
      });

      print('Error al cargar Lugares de Captación: $errorLugares');
    }
  }

  Future<void> fetchCondicionesPersona() async {
    try {
      List<Map<String, dynamic>> condiciones =
          await widget.condicionPersonaService.listarCondicionesPersona();
      List<DropdownOption> opciones = condiciones.map((e) {
        return DropdownOption(
          id: e['id_condicion_persona'].toString(),
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        condicionesPersona = opciones;
        isLoadingCondiciones = false;
      });

      print('Opciones de Condiciones de Persona cargadas:');
      condicionesPersona.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorCondiciones = 'Error al cargar condiciones de persona: $e';
        isLoadingCondiciones = false;
      });

      print('Error al cargar Condiciones de Persona: $errorCondiciones');
    }
  }

  Future<void> fetchSitiosExposicion() async {
    try {
      List<Map<String, dynamic>> sitios =
          await widget.sitioExposicionService.listarSitiosExposicion();
      List<DropdownOption> opciones = sitios.map((e) {
        return DropdownOption(
          id: e['id_sitio_exposicion'].toString(),
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        sitiosExposicion = opciones;
        isLoadingSitios = false;
      });

      print('Opciones de Sitios de Exposición cargadas:');
      sitiosExposicion.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorSitios = 'Error al cargar sitios de exposición: $e';
        isLoadingSitios = false;
      });

      print('Error al cargar Sitios de Exposición: $errorSitios');
    }
  }

  Future<void> fetchLugarIngresoPais() async {
    try {
      List<Map<String, dynamic>> lugares =
          await widget.lugarIngresoPaisService.listarLugarIngresoPais();
      List<DropdownOption> opciones = lugares.map((e) {
        return DropdownOption(
          id: e['id_lugar_ingreso_pais'].toString(),
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        lugaresIngresoPais = opciones;
        isLoadingIngresoPais = false;
      });

      print('Opciones de Lugares de Ingreso al País cargadas:');
      lugaresIngresoPais.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorIngresoPais = 'Error al cargar lugares de ingreso por país: $e';
        isLoadingIngresoPais = false;
      });

      print('Error al cargar Lugares de Ingreso al País: $errorIngresoPais');
    }
  }

  // Función para obtener los síntomas desde el servicio
  Future<void> fetchSintomas() async {
    try {
      List<Map<String, dynamic>> fetchedSintomas =
          await widget.sintomasService.listarSintomas();
      List<DropdownOption> opciones =
          fetchedSintomas.where((sintoma) => sintoma['activo'] == 1).map((e) {
        return DropdownOption(
          id: e['id_sintomas'].toString(),
          name: e['nombre'] as String,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        sintomas = opciones;
        isLoadingSintomas = false;
      });

      print('Opciones de Síntomas cargadas:');
      sintomas.forEach((opcion) {
        print('ID: ${opcion.id}, Nombre: ${opcion.name}');
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorSintomas = 'Error al cargar síntomas: $e';
        isLoadingSintomas = false;
      });

      print('Error al cargar Síntomas: $errorSintomas');
    }
  }

  // Función para abrir el diálogo de selección para Captación
  Future<void> _abrirDialogoSeleccionRedServicioCaptacion() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SeleccionRedServicioTrabajadorWidget(
            catalogService: widget.catalogService,
            selectionStorageService: widget.selectionStorageService,
          ),
        );
      },
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        silaisCaptacionController.text =
            result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoCaptacionController.text =
            result['establecimiento'] ?? 'Establecimiento no seleccionado';
        selectedSILAISCaptacionId = result['silaisId'];
        selectedEstablecimientoCaptacionId = result['establecimientoId'];
      });

      // Imprimir los IDs seleccionados
      print('ID seleccionado SILAIS Captación: $selectedSILAISCaptacionId');
      print(
          'ID seleccionado Establecimiento Captación: $selectedEstablecimientoCaptacionId');
    }
  }

  // Función para abrir el diálogo de selección para Traslado
  Future<void> _abrirDialogoSeleccionRedServicioTraslado() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SeleccionRedServicioTrabajadorWidget(
            catalogService: widget.catalogService,
            selectionStorageService: widget.selectionStorageService,
          ),
        );
      },
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        silaisTrasladoController.text =
            result['silais'] ?? 'SILAIS no seleccionado';
        establecimientoTrasladoController.text =
            result['establecimiento'] ?? 'Establecimiento no seleccionado';
        selectedSILAISTrasladoId = result['silaisId'];
        selectedEstablecimientoTrasladoId = result['establecimientoId'];
      });

      // Imprimir los IDs seleccionados
      print('ID seleccionado SILAIS Traslado: $selectedSILAISTrasladoId');
      print(
          'ID seleccionado Establecimiento Traslado: $selectedEstablecimientoTrasladoId');
    }
  }

  // Función para abrir la pantalla de selección de ubicación
  Future<void> _abrirSeleccionUbicacion() async {
    // Verificar la conectividad a internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No hay conexión a internet
      // Obtener la ubicación actual usando GPS
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          // No se puede obtener la ubicación
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied ||
          permissionGranted == PermissionStatus.deniedForever) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          // No se puede obtener la ubicación
          return;
        }
      }

      // Obtener la ubicación actual
      final locationData = await location.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          latitudOcurrenciaController.text =
              locationData.latitude!.toStringAsFixed(6);
          longitudOcurrenciaController.text =
              locationData.longitude!.toStringAsFixed(6);
        });

        print(
            'Ubicación actual: Latitud=${locationData.latitude}, Longitud=${locationData.longitude}');

        // Opcional: Comparar con GeoJSON para determinar la región
        await _compararConGeoJSON(
            locationData.latitude!, locationData.longitude!);
      } else {
        // No se pudo obtener la ubicación
        print('No se pudo obtener la ubicación actual');
      }
    } else {
      // Hay conexión a internet, proceder como antes
      final selectedLocation = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          builder: (context) => MapSelectionScreen(
            onLocationSelected: (LatLng location) {
              Navigator.of(context).pop(location);
            },
          ),
        ),
      );

      if (selectedLocation != null) {
        setState(() {
          latitudOcurrenciaController.text =
              selectedLocation.latitude.toStringAsFixed(6);
          longitudOcurrenciaController.text =
              selectedLocation.longitude.toStringAsFixed(6);
        });

        print(
            'Ubicación seleccionada: Latitud=${selectedLocation.latitude}, Longitud=${selectedLocation.longitude}');
      }
    }
  }

  // Función para comparar la ubicación actual con el GeoJSON
  Future<void> _compararConGeoJSON(double lat, double lng) async {
    try {
      String geojsonString =
          await rootBundle.loadString('lib/assets/GeoJson/ni.json');

      final geojson = GeoJson();
      await geojson.parse(geojsonString, verbose: true);

      GeoJsonFeature? featureEncontrado;

      for (var feature in geojson.features) {
        if (feature.geometry != null &&
            feature.geometry!.type == GeoJsonFeatureType.polygon) {
          final polygon = feature.geometry as GeoJsonPolygon;
          if (_puntoEnPoligono(lat, lng, polygon)) {
            featureEncontrado = feature;
            break;
          }
        } else if (feature.geometry != null &&
            feature.geometry!.type == GeoJsonFeatureType.multipolygon) {
          final multiPolygon = feature.geometry as GeoJsonMultiPolygon;
          for (var polygon in multiPolygon.polygons) {
            if (_puntoEnPoligono(lat, lng, polygon)) {
              featureEncontrado = feature;
              break;
            }
          }
          if (featureEncontrado != null) {
            break;
          }
        }
      }

      if (featureEncontrado != null) {
        print('Estás en la región: ${featureEncontrado.properties}');
        // Aquí puedes actualizar algún campo o mostrar información al usuario
      } else {
        print('No se encontró la región correspondiente en el GeoJSON');
      }

      geojson.dispose();
    } catch (e) {
      print('Error al procesar el GeoJSON: $e');
    }
  }

  // Función para determinar si un punto está dentro de un polígono
  bool _puntoEnPoligono(double lat, double lng, GeoJsonPolygon polygon) {
    // Implementación del algoritmo de ray casting
    int intersections = 0;
    for (var ring in polygon.geoSeries) {
      for (int i = 0; i < ring.geoPoints.length - 1; i++) {
        double x1 = ring.geoPoints[i].longitude;
        double y1 = ring.geoPoints[i].latitude;
        double x2 = ring.geoPoints[i + 1].longitude;
        double y2 = ring.geoPoints[i + 1].latitude;

        if (((y1 > lat) != (y2 > lat)) &&
            (lng < (x2 - x1) * (lat - y1) / (y2 - y1 + x1))) {
          intersections++;
        }
      }
    }
    return (intersections % 2) != 0;
  }

  /// Método auxiliar para construir campos de texto con ícono de mapa
  Widget buildTextFieldWithMapIcon({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    bool enabled = true,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true, // Hacer de solo lectura
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF00C1D4))
                : null,
            suffixIcon: suffixIcon,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          enabled: enabled,
          maxLines: maxLines,
        ),
      ],
    );
  }

  /// Método auxiliar para construir campos de texto
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    bool enabled = true,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF00C1D4))
                : null,
            suffixIcon: suffixIcon,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          enabled: enabled,
          maxLines: maxLines,
        ),
      ],
    );
  }

  /// Método auxiliar para construir campos desplegables usando CustomTextFieldDropdown
  Widget _buildCustomDropdownField({
    required String label,
    required List<DropdownOption> options,
    required String? selectedId,
    required TextEditingController controller,
    required Function(String?) onChanged,
    required IconData icon,
    String hintText = 'Selecciona una opción',
  }) {
    // Extraer solo los nombres para el dropdown
    List<String> opciones = options.map((option) => option.name).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextFieldDropdown(
          hintText: hintText,
          controller: controller,
          options: opciones,
          borderColor: const Color(0xFF00C1D4),
          borderWidth: 1.0,
          borderRadius: 8.0,
          onChanged: (selectedOption) {
            // Encontrar el ID correspondiente al nombre seleccionado
            final selectedOptionObj = options.firstWhere(
              (option) => option.name == selectedOption,
              orElse: () => DropdownOption(id: '', name: ''),
            );

            onChanged(
                selectedOptionObj.id.isNotEmpty ? selectedOptionObj.id : null);

            print('Opción seleccionada para $label: ${selectedOptionObj.id}');
          },
        ),
      ],
    );
  }

  /// Método auxiliar para construir campos de selección de fecha
  Widget buildDatePickerField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return buildTextField(
      label: label,
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0];
            // Calcular y establecer la semana epidemiológica
            semanaEpidemiologicaController.text =
                calcularSemanaEpidemiologica(pickedDate).toString();
          });
        }
      },
    );
  }

  /// Función para calcular la semana epidemiológica
  int calcularSemanaEpidemiologica(DateTime fecha) {
    // Ajustar la fecha al jueves de la semana
    DateTime jueves = fecha.add(Duration(days: 4 - fecha.weekday));

    // Fecha del primer jueves del año
    DateTime primerJueves = DateTime(fecha.year, 1, 4);
    while (primerJueves.weekday != DateTime.thursday) {
      primerJueves = primerJueves.add(Duration(days: 1));
    }

    // Calcular la diferencia en días y luego en semanas
    int diferenciaDias = jueves.difference(primerJueves).inDays;
    int semana = 1 + (diferenciaDias ~/ 7);

    // Asegurarse de que la semana esté en el rango correcto
    if (semana < 1) {
      // Puede pertenecer a la última semana del año anterior
      semana = 1; // Por simplicidad, asignamos 1
    } else if (semana > 53) {
      semana = 53;
    }

    return semana;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Establecer color de fondo blanco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF00C1D4), width: 1),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Asegura que el contenido sea scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la Tarjeta
              _buildCardTitle(),
              const SizedBox(height: 20),

              // Campo: Lugar de Captación
              _buildCustomDropdownField(
                label: 'Lugar de Captación *',
                options: lugaresCaptacion,
                selectedId: selectedLugarCaptacionId,
                controller: lugarCaptacionController,
                icon: Icons.location_on,
                hintText: 'Selecciona un lugar de captación',
                onChanged: (selectedId) {
                  setState(() {
                    selectedLugarCaptacionId = selectedId;
                    lugarCaptacionController.text = lugaresCaptacion
                        .firstWhere((lugar) => lugar.id == selectedId,
                            orElse: () => DropdownOption(id: '', name: ''))
                        .name;
                  });
                  print(
                      'ID seleccionado Lugar de Captación: $selectedLugarCaptacionId');
                },
              ),
              const SizedBox(height: 20),

              // Campo: Condición de la Persona
              _buildCustomDropdownField(
                label: 'Condición de la Persona *',
                options: condicionesPersona,
                selectedId: selectedCondicionPersonaId,
                controller: condicionPersonaController,
                icon: Icons.health_and_safety,
                hintText: 'Selecciona una condición',
                onChanged: (selectedId) {
                  setState(() {
                    selectedCondicionPersonaId = selectedId;
                    condicionPersonaController.text = condicionesPersona
                        .firstWhere((condicion) => condicion.id == selectedId,
                            orElse: () => DropdownOption(id: '', name: ''))
                        .name;
                  });
                  print(
                      'ID seleccionado Condición Persona: $selectedCondicionPersonaId');
                },
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de Captación
              buildDatePickerField(
                label: 'Fecha de Captación *',
                controller: fechaCaptacionController,
                hintText: 'Selecciona la fecha de captación',
                prefixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              // Campo: Semana Epidemiológica
              buildTextField(
                label: 'Semana Epidemiológica *',
                controller: semanaEpidemiologicaController,
                hintText: 'Semana calculada automáticamente',
                prefixIcon: Icons.calendar_view_week,
                readOnly: true, // Hacerlo de solo lectura
              ),
              const SizedBox(height: 20),

              // Campo: SILAIS de Captación con Icono de Búsqueda
              buildSearchableTextField(
                label: 'SILAIS de Captación *',
                controller: silaisCaptacionController,
                hintText: 'Selecciona un SILAIS',
                prefixIcon: Icons.map,
                onSearch: _abrirDialogoSeleccionRedServicioCaptacion,
              ),
              const SizedBox(height: 20),

              // Campo: Establecimiento de Captación
              buildSearchableTextField(
                label: 'Establecimiento de Captación *',
                controller: establecimientoCaptacionController,
                hintText: 'Selecciona un establecimiento',
                prefixIcon: Icons.local_hospital,
                onSearch: () {
                  // Implementa aquí la lógica para buscar establecimientos si es necesario
                },
              ),
              const SizedBox(height: 20),

              // Campo: Persona que Captó (Reemplazado por SearchPersonaWidget)
              SearchPersonaWidget(
                onPersonaSelected: (int idPersona) {
                  setState(() {
                    _personaCaptadaId = idPersona;
                  });
                  print('Persona seleccionada ID: $_personaCaptadaId');
                },
              ),
              const SizedBox(height: 20),

              // Campo: ¿Fue Referido?
              _buildCustomDropdownField(
                label: '¿Fue Referido? *',
                options: yesNoOptions,
                selectedId: fueReferidoController.text.isNotEmpty
                    ? (fueReferidoController.text == 'Sí' ? 'si' : 'no')
                    : null,
                controller: fueReferidoController,
                icon: Icons.assignment_return,
                hintText: 'Selecciona una opción',
                onChanged: (selectedId) {
                  setState(() {
                    if (selectedId == 'si') {
                      fueReferidoController.text = 'Sí';
                      _fueReferido = true;
                    } else if (selectedId == 'no') {
                      fueReferidoController.text = 'No';
                      _fueReferido = false;
                      silaisTrasladoController.clear();
                      establecimientoTrasladoController.clear();
                      selectedSILAISTrasladoId = null;
                      selectedEstablecimientoTrasladoId = null;
                    } else {
                      fueReferidoController.text = '';
                      _fueReferido = false;
                    }
                  });
                  print(
                      '¿Fue Referido? seleccionado: ${fueReferidoController.text}');
                },
              ),
              const SizedBox(height: 20),

              // Campos de Traslado (Condicional)
              if (_fueReferido) ...[
                // Campo: SILAIS de Traslado con Icono de Búsqueda
                buildSearchableTextField(
                  label: 'SILAIS de Traslado *',
                  controller: silaisTrasladoController,
                  hintText: 'Selecciona un SILAIS',
                  prefixIcon: Icons.map,
                  onSearch: _abrirDialogoSeleccionRedServicioTraslado,
                ),
                const SizedBox(height: 20),

                // Campo: Establecimiento de Traslado
                buildSearchableTextField(
                  label: 'Establecimiento de Traslado *',
                  controller: establecimientoTrasladoController,
                  hintText: 'Selecciona un establecimiento',
                  prefixIcon: Icons.local_hospital,
                  onSearch: () {
                    // Implementa aquí la lógica para buscar establecimientos si es necesario
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Campo: Sitio de Exposición
              _buildCustomDropdownField(
                label: 'Sitio de Exposición *',
                options: sitiosExposicion,
                selectedId: selectedSitioExposicionId,
                controller: sitioExposicionController,
                icon: Icons.location_on,
                hintText: 'Selecciona un sitio de exposición',
                onChanged: (selectedId) {
                  setState(() {
                    selectedSitioExposicionId = selectedId;
                    sitioExposicionController.text = sitiosExposicion
                        .firstWhere((sitio) => sitio.id == selectedId,
                            orElse: () => DropdownOption(id: '', name: ''))
                        .name;
                  });
                  print(
                      'ID seleccionado Sitio de Exposición: $selectedSitioExposicionId');
                },
              ),
              const SizedBox(height: 20),

              // Campo: Latitud de Ocurrencia con Ícono de Mapa
              buildTextFieldWithMapIcon(
                label: 'Latitud de Ocurrencia *',
                controller: latitudOcurrenciaController,
                hintText: 'Ingresa la latitud',
                prefixIcon: Icons.map,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map, color: Color(0xFF00C1D4)),
                  onPressed: _abrirSeleccionUbicacion, // Usar la nueva función
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Longitud de Ocurrencia SIN Ícono de Mapa
              buildTextFieldWithMapIcon(
                label: 'Longitud de Ocurrencia *',
                controller: longitudOcurrenciaController,
                hintText: 'Ingresa la longitud',
                prefixIcon: Icons.map,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                suffixIcon: null, // Eliminar el ícono de mapa
              ),
              const SizedBox(height: 20),

              // Campo: ¿Presenta Síntomas?
              _buildCustomDropdownField(
                label: '¿Presenta Síntomas? *',
                options: yesNoOptions,
                selectedId: presentaSintomasController.text.isNotEmpty
                    ? (presentaSintomasController.text == 'Sí' ? 'si' : 'no')
                    : null,
                controller: presentaSintomasController,
                icon: Icons.medical_services,
                hintText: 'Selecciona una opción',
                onChanged: (selectedId) {
                  setState(() {
                    if (selectedId == 'si') {
                      presentaSintomasController.text = 'Sí';
                      _presentaSintomas = true;
                    } else if (selectedId == 'no') {
                      presentaSintomasController.text = 'No';
                      _presentaSintomas = false;
                      fechaInicioSintomasController.clear();
                      sintomasController.clear();
                      selectedSintomaId = null;
                    } else {
                      presentaSintomasController.text = '';
                      _presentaSintomas = false;
                    }
                  });
                  print(
                      '¿Presenta Síntomas? seleccionado: ${presentaSintomasController.text}');
                },
              ),
              const SizedBox(height: 20),

              // Campos de Síntomas (Condicional)
              if (_presentaSintomas) ...[
                // Campo: Fecha de Inicio de Síntomas
                buildDatePickerField(
                  label: 'Fecha de Inicio de Síntomas *',
                  controller: fechaInicioSintomasController,
                  hintText: 'Selecciona la fecha de inicio de síntomas',
                  prefixIcon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),

                // Campo: Síntomas
                _buildCustomDropdownField(
                  label: 'Síntomas *',
                  options: sintomas,
                  selectedId: selectedSintomaId,
                  controller: sintomasController,
                  icon: Icons.emoji_people,
                  hintText: 'Selecciona los síntomas',
                  onChanged: (selectedId) {
                    setState(() {
                      selectedSintomaId = selectedId;
                      sintomasController.text = sintomas
                          .firstWhere((sintoma) => sintoma.id == selectedId,
                              orElse: () => DropdownOption(id: '', name: ''))
                          .name;
                    });
                    print('Síntoma seleccionado ID: $selectedSintomaId');
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Campo: ¿Es Viajero?
              _buildCustomDropdownField(
                label: '¿Es Viajero? *',
                options: yesNoOptions,
                selectedId: esViajeroController.text.isNotEmpty
                    ? (esViajeroController.text == 'Sí' ? 'si' : 'no')
                    : null,
                controller: esViajeroController,
                icon: Icons.airplanemode_active,
                hintText: 'Selecciona una opción',
                onChanged: (selectedId) {
                  setState(() {
                    if (selectedId == 'si') {
                      esViajeroController.text = 'Sí';
                      _esViajero = true;
                    } else if (selectedId == 'no') {
                      esViajeroController.text = 'No';
                      _esViajero = false;
                      fechaIngresoPaisController.clear();
                      lugarIngresoPaisController.clear();
                      selectedLugarIngresoPaisId = null;
                    } else {
                      esViajeroController.text = '';
                      _esViajero = false;
                    }
                  });
                  print(
                      '¿Es Viajero? seleccionado: ${esViajeroController.text}');
                },
              ),
              const SizedBox(height: 20),

              // Campos de Viajero (Condicional)
              if (_esViajero) ...[
                // Campo: Fecha de Ingreso al País
                buildDatePickerField(
                  label: 'Fecha de Ingreso al País *',
                  controller: fechaIngresoPaisController,
                  hintText: 'Selecciona la fecha de ingreso al país',
                  prefixIcon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),

                // Campo: Lugar de Ingreso al País
                _buildCustomDropdownField(
                  label: 'Lugar de Ingreso al País *',
                  options: lugaresIngresoPais,
                  selectedId: selectedLugarIngresoPaisId,
                  controller: lugarIngresoPaisController,
                  icon: Icons.flag,
                  hintText: 'Selecciona un lugar de ingreso al país',
                  onChanged: (selectedId) {
                    setState(() {
                      selectedLugarIngresoPaisId = selectedId;
                      lugarIngresoPaisController.text = lugaresIngresoPais
                          .firstWhere((lugar) => lugar.id == selectedId,
                              orElse: () => DropdownOption(id: '', name: ''))
                          .name;
                    });
                    print(
                        'ID seleccionado Lugar de Ingreso al País: $selectedLugarIngresoPaisId');
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Campo: Observaciones de Captación
              buildTextField(
                label: 'Observaciones de Captación',
                controller: observacionesCaptacionController,
                hintText: 'Ingresa cualquier observación',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el título de la tarjeta.
  Widget _buildCardTitle() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF00C1D4),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: const Text(
            '2',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Datos de Captación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00C1D4),
          ),
        ),
      ],
    );
  }

  /// Método auxiliar para construir campos de texto con ícono de búsqueda.
  Widget buildSearchableTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required VoidCallback onSearch,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true, // Evita modificaciones manuales
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF00C1D4)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
              onPressed: onSearch,
            ),
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
          onTap: () {
            // Opcional: Puedes implementar alguna acción al tocar el campo
          },
        ),
      ],
    );
  }
}
