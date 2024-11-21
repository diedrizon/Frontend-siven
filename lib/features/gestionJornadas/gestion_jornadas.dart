import 'package:flutter/material.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:table_calendar/table_calendar.dart';

class GestionJornadas extends StatefulWidget {
  const GestionJornadas({Key? key}) : super(key: key);

  @override
  _GestionJornadasScreenState createState() => _GestionJornadasScreenState();
}

class _GestionJornadasScreenState extends State<GestionJornadas> {
  // IDs seleccionados
  int? idSilaisSeleccionado;
  int? idUnidadSaludSeleccionado;

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;

  // Eventos del calendario
  Map<DateTime, List<String>> eventos = {};

  @override
  void initState() {
    super.initState();

    // Inicialización de servicios
    initializeServices();

    // Simulación: Carga de eventos desde un servicio
    cargarEventosDesdeServicio();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
  }

  void cargarEventosDesdeServicio() async {
    // Simula una llamada al servicio y agrega eventos al mapa
    // Aquí deberías reemplazarlo con la lógica real de tu servicio
    setState(() {
      eventos = {
        DateTime(2024, 11, 4): ['Jornada completada'],
        DateTime(2024, 11, 16): ['Jornada en curso'],
        DateTime(2024, 11, 28): ['Jornada pendiente'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color morado = Color(0xFF9C27B0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF1877F2), size: 32),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ),
        title: const EncabezadoBienvenida(),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BotonCentroSalud(
                            catalogService: catalogService,
                            selectionStorageService: selectionStorageService),
                        const IconoPerfil()
                      ]),
                  const SizedBox(height: 20.0),
                  RedDeServicio(
                      catalogService: catalogService,
                      selectionStorageService: selectionStorageService),
                  const SizedBox(height: 20.0),
                  TableCalendar(
                    focusedDay: DateTime.now(),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 1, 1),
                    eventLoader: (day) => eventos[day] ?? [],
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: morado,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        // Muestra algo basado en el día seleccionado si es necesario
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
