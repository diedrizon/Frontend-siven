// Captacion.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importaciones de servicios personalizados
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/EventoSaludService.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/Maternidadservice.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/LugarCaptacionService.dart';
import 'package:siven_app/core/services/CondicionPersonaService.dart';
import 'package:siven_app/core/services/SitioExposicionService.dart';
import 'package:siven_app/core/services/LugarIngresoPaisService.dart';
import 'package:siven_app/core/services/SintomasService.dart';
import 'package:siven_app/core/services/PuestoNotificacionService.dart';
import 'package:siven_app/core/services/DiagnosticoService.dart';
import 'package:siven_app/core/services/ResultadoDiagnosticoService.dart';
import 'package:siven_app/core/services/ComorbilidadesService.dart';
import 'package:siven_app/core/services/CaptacionService.dart';
import 'package:siven_app/core/services/storage_service.dart';

// Importaciones de widgets personalizados
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';

import 'PrimeraTarjeta.dart';
import 'SegundaTarjeta.dart';
import 'TerceraTarjeta.dart';
import 'CuartaTarjeta.dart';

class Captacion extends StatefulWidget {
  const Captacion({Key? key}) : super(key: key);

  @override
  _CaptacionState createState() => _CaptacionState();
}

class _CaptacionState extends State<Captacion> {
  final PageController _pageController = PageController();

  int _currentCardIndex = 0;
  String? _selectedEventoName;
  String? nombreCompleto;

  // Evita el cambio rápido entre páginas
  bool _isNavigating = false;

  // Servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late StorageService storageService;
  late EventoSaludService eventoSaludService;
  late MaternidadService maternidadService;
  late LugarCaptacionService lugarCaptacionService;
  late CondicionPersonaService condicionPersonaService;
  late SitioExposicionService sitioExposicionService;
  late LugarIngresoPaisService lugarIngresoPaisService;
  late SintomasService sintomasService;

  late PuestoNotificacionService puestoNotificacionService;
  late DiagnosticoService diagnosticoService;
  late ResultadoDiagnosticoService resultadoDiagnosticoService;
  late ComorbilidadesService comorbilidadesService;
  late CaptacionService captacionService;

  // Instancias de las tarjetas con GlobalKey
  late GlobalKey<PrimeraTarjetaState> _primeraTarjetaKey;
  late PrimeraTarjeta _primeraTarjeta;

  late GlobalKey<SegundaTarjetaState> _segundaTarjetaKey;
  late SegundaTarjeta _segundaTarjeta;

  late GlobalKey<TerceraTarjetaState> _terceraTarjetaKey;
  late TerceraTarjeta _terceraTarjeta;

  late GlobalKey<CuartaTarjetaState> _cuartaTarjetaKey;
  late CuartaTarjeta _cuartaTarjeta;

  // Flag para inicializar las tarjetas una sola vez
  bool _cardsInitialized = false;

  // Variable para almacenar los datos
  Map<String, dynamic> collectedData = {};

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    // Inicializar StorageService y SelectionStorageService
    storageService = StorageService();
    selectionStorageService = SelectionStorageService();

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    eventoSaludService = EventoSaludService(httpService: httpService);
    maternidadService = MaternidadService(httpService: httpService);
    lugarCaptacionService = LugarCaptacionService(httpService: httpService);
    condicionPersonaService = CondicionPersonaService(httpService: httpService);
    sitioExposicionService = SitioExposicionService(httpService: httpService);
    lugarIngresoPaisService = LugarIngresoPaisService(httpService: httpService);
    sintomasService = SintomasService(httpService: httpService);

    puestoNotificacionService = PuestoNotificacionService(
      httpService: httpService,
      storageService: storageService,
    );

    diagnosticoService = DiagnosticoService(httpService: httpService);
    resultadoDiagnosticoService = ResultadoDiagnosticoService(httpService: httpService);
    comorbilidadesService = ComorbilidadesService(httpService: httpService);

    captacionService = CaptacionService(
      httpService: httpService,
      storageService: storageService,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _selectedEventoName = args['eventoSeleccionado'];
        nombreCompleto = args['nombreCompleto'];
      });
    }

    // Inicializar las tarjetas una sola vez después de obtener los argumentos
    if (!_cardsInitialized) {
      final int? idPersona = args != null && args is Map<String, dynamic> ? args['id_persona'] as int? : null;
      final int? idEventoSalud = args != null && args is Map<String, dynamic> ? args['id_evento_salud'] as int? : null;

      _primeraTarjetaKey = GlobalKey<PrimeraTarjetaState>();

      _primeraTarjeta = PrimeraTarjeta(
        key: _primeraTarjetaKey,
        nombreEventoSeleccionado: _selectedEventoName,
        nombreCompleto: nombreCompleto,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        maternidadService: maternidadService,
        idEventoSalud: idEventoSalud?.toString(),
        idPersona: idPersona,
        comorbilidadesService: comorbilidadesService,
      );

      _segundaTarjetaKey = GlobalKey<SegundaTarjetaState>();

      _segundaTarjeta = SegundaTarjeta(
        key: _segundaTarjetaKey,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        lugarCaptacionService: lugarCaptacionService,
        condicionPersonaService: condicionPersonaService,
        sitioExposicionService: sitioExposicionService,
        lugarIngresoPaisService: lugarIngresoPaisService,
        sintomasService: sintomasService,
      );

      _terceraTarjetaKey = GlobalKey<TerceraTarjetaState>();

      _terceraTarjeta = TerceraTarjeta(
        key: _terceraTarjetaKey,
        puestoNotificacionService: puestoNotificacionService,
      );

      _cuartaTarjetaKey = GlobalKey<CuartaTarjetaState>();

      _cuartaTarjeta = CuartaTarjeta(
        key: _cuartaTarjetaKey,
        diagnosticoService: diagnosticoService,
        resultadoDiagnosticoService: resultadoDiagnosticoService,
        catalogService: catalogService,
        selectionStorageService: selectionStorageService,
        onGuardarPressed: _onGuardarPressed,
      );

      _cardsInitialized = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Cerrar los servicios si es necesario
    lugarCaptacionService.close();
    condicionPersonaService.close();
    sitioExposicionService.close();
    lugarIngresoPaisService.close();
    sintomasService.close();
    puestoNotificacionService.close();
    diagnosticoService.close();
    resultadoDiagnosticoService.close();
    captacionService.close();
    super.dispose();
  }

  void _goToPage(int index) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    if (index >= 0 && index < 4) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentCardIndex = index;
          });
        }
        _isNavigating = false;
      });
    } else {
      _isNavigating = false;
    }
  }

  void _onNextPressed() {
    if (_currentCardIndex < 3) {
      List<String> errors = [];

      if (_currentCardIndex == 0) {
        final primeraTarjetaState = _primeraTarjetaKey.currentState;
        if (primeraTarjetaState != null) {
          errors = primeraTarjetaState.validate();
          if (errors.isNotEmpty) {
            _showErrorDialog(errors);
            return; // No proceder al siguiente
          } else {
            collectedData = primeraTarjetaState.getData();
            debugPrint('Datos de PrimeraTarjeta: $collectedData', wrapWidth: 1024);
          }
        }
      } else if (_currentCardIndex == 1) {
        final segundaTarjetaState = _segundaTarjetaKey.currentState;
        if (segundaTarjetaState != null) {
          errors = segundaTarjetaState.validate();
          if (errors.isNotEmpty) {
            _showErrorDialog(errors);
            return; // No proceder al siguiente
          } else {
            final segundaData = segundaTarjetaState.getData();
            collectedData.addAll(segundaData);
            debugPrint('Datos de SegundaTarjeta: $segundaData', wrapWidth: 1024);
            debugPrint('Datos recopilados hasta ahora: $collectedData', wrapWidth: 1024);
          }
        }
      } else if (_currentCardIndex == 2) {
        final terceraTarjetaState = _terceraTarjetaKey.currentState;
        if (terceraTarjetaState != null) {
          errors = terceraTarjetaState.validate();
          if (errors.isNotEmpty) {
            _showErrorDialog(errors);
            return; // No proceder al siguiente
          } else {
            final terceraData = terceraTarjetaState.getData();
            collectedData.addAll(terceraData);
            debugPrint('Datos de TerceraTarjeta: $terceraData', wrapWidth: 1024);
            debugPrint('Datos recopilados hasta ahora: $collectedData', wrapWidth: 1024);
          }
        }
      }

      _goToPage(_currentCardIndex + 1);
    } else if (_currentCardIndex == 3) {
      // En la cuarta tarjeta, no hacemos nada al presionar "Siguiente"
    }
  }

  // Función para manejar el guardado
  Future<void> _onGuardarPressed() async {
    // Recopilar datos de la TerceraTarjeta si no se ha hecho ya
    if (!_collectedDataContainsTerceraTarjeta()) {
      final terceraData = _terceraTarjetaKey.currentState?.getData() ?? {};
      collectedData.addAll(terceraData);
      debugPrint('Datos de TerceraTarjeta: $terceraData', wrapWidth: 1024);

      final errorsTercera = _terceraTarjetaKey.currentState?.validate() ?? [];
      if (errorsTercera.isNotEmpty) {
        _showErrorDialog(errorsTercera);
        return;
      }
    }

    // Recopilar datos de la CuartaTarjeta
    final cuartaData = _cuartaTarjetaKey.currentState?.getData() ?? {};
    collectedData.addAll(cuartaData);
    debugPrint('Datos de CuartaTarjeta: $cuartaData', wrapWidth: 1024);
    debugPrint('Datos recopilados hasta ahora: $collectedData', wrapWidth: 1024);

    // Validar los campos de la CuartaTarjeta
    final errorsCuarta = _cuartaTarjetaKey.currentState?.validate() ?? [];
    if (errorsCuarta.isNotEmpty) {
      _showErrorDialog(errorsCuarta);
      return;
    }

    // Mostrar diálogo de confirmación
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmación',
            style: TextStyle(color: Color(0xFF00C1D4)),
          ),
          content: const Text('¿Desea guardar la captación?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No',
                style: TextStyle(color: Color(0xFF00C1D4)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sí',
                style: TextStyle(color: Color(0xFF00C1D4)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != null && confirmar) {
      // Mostrar animación de guardado
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xFF00C1D4), width: 2),
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: const Center(
                child: AnimatedCheckmark(),
              ),
            ),
          );
        },
      );

      // Preparar los datos para el guardado
      final dataToSave = _prepareDataForSaving(collectedData);

      try {
        // Guardar los datos
        await captacionService.crearCaptacion(dataToSave);

        // Navegar a la pantalla deseada
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/captacion_inf_paciente',
          (route) => false,
        );

        // Limpiar los campos de todas las tarjetas
        _clearAllFields();
      } catch (e) {
        // Manejar errores durante el guardado
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la captación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Verificar si los datos de la TerceraTarjeta ya fueron recopilados
  bool _collectedDataContainsTerceraTarjeta() {
    return collectedData.containsKey('tipoBusqueda');
  }

  // Función para preparar los datos para guardarlos
  Map<String, dynamic> _prepareDataForSaving(Map<String, dynamic> data) {
    return {
      'id_evento_salud': data['idEventoSalud'],
      'id_persona': data['idPersona'],
      'id_maternidad': data['selectedMaternidadId'],
      'semana_gestacion': data['semanasGestacion'],
      'trabajador_salud': data['esTrabajadorSalud'],
      'id_silais_trabajador': data['selectedSILAISId'],
      'id_establecimiento_trabajador': data['selectedEstablecimientoId'],
      'tiene_comorbilidades': data['tieneComorbilidades'],
      'id_comorbilidades': data['selectedComorbilidadId'],
      'nombre_jefe_familia': data['nombreJefeFamilia'],
      'telefono_referencia': data['telefonoReferencia'],
      'id_lugar_captacion': data['selectedLugarCaptacionId'],
      'id_condicion_persona': data['selectedCondicionPersonaId'],
      'fecha_captacion': data['fechaCaptacion'],
      'semana_epidemiologica': data['semanaEpidemiologica'],
      'id_silais_captacion': data['selectedSILAISCaptacionId'],
      'id_establecimiento_captacion': data['selectedEstablecimientoCaptacionId'],
      'id_persona_captacion': data['personaCaptadaId'],
      'fue_referido': data['fueReferido'],
      'id_silais_traslado': data['selectedSILAISTrasladoId'],
      'id_establecimiento_traslado': data['selectedEstablecimientoTrasladoId'],
      'id_sitio_exposicion': data['selectedSitioExposicionId'],
      'latitud_ocurrencia': data['latitudOcurrencia'],
      'longitud_ocurrencia': data['longitudOcurrencia'],
      'presenta_sintomas': data['presentaSintomas'],
      'fecha_inicio_sintomas': data['fechaInicioSintomas'],
      'id_sintomas': data['selectedSintomaId'],
      'es_viajero': data['esViajero'],
      'fecha_ingreso_pais': data['fechaIngresoPais'],
      'id_lugar_ingreso_pais': data['selectedLugarIngresoPaisId'],
      'direccion_ocurrencia': data['direccionOcurrencia'],
      'observaciones_captacion': data['observacionesCaptacion'],
      'id_puesto_notificacion': data['selectedPuestoNotificacionId'],
      'no_clave': data['numeroClave'],
      'no_lamina': data['numeroLamina'],
      'toma_muestra': data['tomaMuestra'],
      'tipobusqueda': data['tipoBusqueda'],
      'id_diagnostico': data['selectedDiagnosticoId'],
      'fecha_toma_muestra': data['fechaTomaMuestra'],
      'fecha_recepcion_laboratorio': data['fechaRecepcionLab'],
      'fecha_diagnostico': data['fechaDiagnostico'],
      'id_resultado_diagnostico': data['selectedResultadoDiagnosticoId'],
      'densidad_parasitaria_vivax_eas': data['densidadVivaxEAS'],
      'densidad_parasitaria_vivax_ess': data['densidadVivaxESS'],
      'densidad_parasitaria_falciparum_eas': data['densidadFalciparumEAS'],
      'densidad_parasitaria_falciparum_ess': data['densidadFalciparumESS'],
      'id_silais_diagnostico': data['selectedSILAISDiagnosticoId'],
      'id_establecimiento_diagnostico': data['selectedEstablecimientoDiagnosticoId'],
      'usuario_creacion': null,
      'fecha_creacion': null,
      'usuario_modificacion': null,
      'fecha_modificacion': null,
      'activo': null,
    };
  }

  // Función para mostrar el diálogo de errores
  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Fondo blanco
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            children: const [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Campos incompletos o inválidos',
                  style: TextStyle(color: Color(0xFF00C1D4)),
                ),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: ListBody(
                children: errors.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF00C1D4)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Función para limpiar los campos de todas las tarjetas
  void _clearAllFields() {
    // _primeraTarjetaKey.currentState?.resetFields();
    // _segundaTarjetaKey.currentState?.resetFields();
    // _terceraTarjetaKey.currentState?.resetFields();
    _cuartaTarjetaKey.currentState?.resetFields();
  }


  Widget _buildHeader() {
    return Column(
      children: [
        // Fila con el botón de Centro de Salud y el ícono de perfil
        Row(
/// - Un contenedor que muestra el nombre del evento de salud seleccionado.
/// - Una fila que muestra un ícono de persona y el nombre completo del paciente.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BotonCentroSalud(
              catalogService: catalogService,
              selectionStorageService: selectionStorageService,
            ),
            const IconoPerfil(),
          ],
        ),
        const SizedBox(height: 20),
        // Widget de Red de Servicio
        RedDeServicio(
          catalogService: catalogService,
          selectionStorageService: selectionStorageService,
        ),
        const SizedBox(height: 30),
        // Contenedor con el nombre del evento de salud
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFF00C1D4),
          child: Center(
            child: Text(
              'Evento de salud - ${_selectedEventoName ?? 'Evento no seleccionado'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Fila con el ícono de persona y el nombre completo
        Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF00C1D4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ver detalle del paciente - ${nombreCompleto ?? 'Sin nombre'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Método auxiliar para construir el contenido de una tarjeta
  Widget _buildCard(Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(),
          KeepAlivePage(child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1877F2), size: 32),
            onPressed: () {
              Navigator.pushNamed(context, '/captacion_inf_paciente');
            },
          ),
        ),
        title: const EncabezadoBienvenida(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCard(_primeraTarjeta),
                _buildCard(_segundaTarjeta),
                _buildCard(_terceraTarjeta),
                _buildCard(_cuartaTarjeta),
              ],
            ),
          ),
          // Botones de navegación y puntos indicadores
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentCardIndex > 0
                      ? () => _goToPage(_currentCardIndex - 1)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ANTERIOR',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: _currentCardIndex == i
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C1D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIGUIENTE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const VersionWidget(),
        ],
      ),
    );
  }
}

/// Widget auxiliar para mantener el estado
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para el mixin
    return widget.child;
  }
}

/// Widget para la animación de "Listo"
class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({Key? key}) : super(key: key);

  @override
  _AnimatedCheckmarkState createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().whenComplete(() {
      Navigator.of(context).pop(); // Cerrar el diálogo al finalizar la animación
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle,
            color: Color(0xFF00C1D4),
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Listo',
            style: TextStyle(
              color: Color(0xFF00C1D4),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
