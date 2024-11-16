import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/Version.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/captacion_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AnalisisScreen extends StatefulWidget {
  final String silais;
  final String unidadSalud;
  final String evento;
  final String fechaInicio;
  final String fechaFin;

  const AnalisisScreen({
    required this.silais,
    required this.unidadSalud,
    required this.evento,
    required this.fechaInicio,
    required this.fechaFin,
    Key? key,
  }) : super(key: key);

  @override
  _AnalisisScreenState createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen> {
  // Variables para almacenar los resultados del análisis
  int totalCasosRegistrados = 0;
  int totalCasosActivos = 0;
  int totalCasosFinalizados = 0;

  // Datos para los gráficos
  List<ChartData> distribucionLocalidad = [];
  List<IncidenceData> maximosIncidencia = [];
  List<ChartData> distribucionGenero = [];

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late CaptacionService captacionService;

  bool isLoading = true; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();

    // Inicializar servicios
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);
    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
    captacionService = CaptacionService(httpService: httpService);

    // Obtener análisis de captaciones
    obtenerAnalisisCaptaciones();
  }

  void obtenerAnalisisCaptaciones() async {
    try {
      Map<String, dynamic> analysisData =
          await captacionService.analizarCaptaciones(
        fechaInicio: widget.fechaInicio.isNotEmpty
            ? DateTime.parse(widget.fechaInicio)
            : null,
        fechaFin:
            widget.fechaFin.isNotEmpty ? DateTime.parse(widget.fechaFin) : null,
        idSilais: int.tryParse(widget.silais),
        idEventoSalud: int.tryParse(widget.evento),
        idEstablecimiento: int.tryParse(widget.unidadSalud),
      );

      setState(() {
        totalCasosRegistrados = analysisData['casosRegistrados'] ?? 0;
        totalCasosActivos = analysisData['casosActivos'] ?? 0;
        totalCasosFinalizados = analysisData['casosFinalizados'] ?? 0;

        // Procesar distribución por localidad
        distribucionLocalidad = [];
        Map<String, dynamic> distribucionLocalidadData =
            analysisData['distribucionLocalidad'] ?? {};
        distribucionLocalidadData.forEach((localidad, cantidad) {
          double porcentaje = (cantidad / totalCasosRegistrados) * 100;
          distribucionLocalidad
              .add(ChartData(localidad, porcentaje, Colors.orange));
        });

        // Procesar máximos de incidencia
        maximosIncidencia = [];
        Map<String, dynamic> maximosIncidenciaData =
            analysisData['maximosIncidencia'] ?? {};
        maximosIncidenciaData.forEach((fechaStr, cantidad) {
          DateTime fecha = DateTime.parse(fechaStr);
          maximosIncidencia.add(IncidenceData(fecha, cantidad));
        });
        // Ordenar por fecha
        maximosIncidencia.sort((a, b) => a.date.compareTo(b.date));

        // Procesar distribución por género
        distribucionGenero = [];
        Map<String, dynamic> distribucionGeneroData =
            analysisData['distribucionGenero'] ?? {};
        distribucionGeneroData.forEach((genero, cantidad) {
          Color color;
          if (genero == 'MUJER') {
            color = Colors.pink;
          } else if (genero == 'HOMBRE') {
            color = Colors.blue;
          } else {
            color = Colors.grey;
          }
          distribucionGenero.add(ChartData(genero, cantidad.toDouble(), color));
        });

        isLoading = false; // Finaliza la carga
      });
    } catch (e) {
      print('Error al obtener análisis de captaciones: $e');
      setState(() {
        isLoading = false; // Finaliza la carga incluso si hay error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores utilizados
    const Color fondoColor = Color(0xFFFBFBFB);
    const Color naranja = Color(0xFFF7941D);
    const Color azulBrillante = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: fondoColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 13.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: azulBrillante, size: 32),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const EncabezadoBienvenida(),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de carga
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Uso de los widgets pasando los servicios
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BotonCentroSalud(
                              catalogService: catalogService,
                              selectionStorageService: selectionStorageService,
                            ),
                            const IconoPerfil(),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Texto Red de Servicio
                        Center(
                          child: RedDeServicio(
                            catalogService: catalogService,
                            selectionStorageService: selectionStorageService,
                          ),
                        ),
                        SizedBox(height: 32),

                        // Encabezado con el icono naranja de estadísticas
                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: naranja),
                            SizedBox(width: 10),
                            Text(
                              'Análisis de captación',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: naranja,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Fila con 3 Cards para Casos registrados, activos y finalizados
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ResumenCard(
                                bordeColor: naranja,
                                numero: '$totalCasosRegistrados',
                                titulo: 'Casos registrados',
                                numeroColor: naranja,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ResumenCard(
                                bordeColor: Color(0xFFD9006C),
                                numero: '$totalCasosActivos',
                                titulo: 'Casos activos',
                                numeroColor: Color(0xFFD9006C),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ResumenCard(
                                bordeColor: Color(0xFF39B54A),
                                numero: '$totalCasosFinalizados',
                                titulo: 'Casos finalizados',
                                numeroColor: Color(0xFF39B54A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Card para los gráficos de torta con scroll horizontal
                        if (distribucionLocalidad.isNotEmpty)
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side:
                                  BorderSide(color: naranja), // Borde naranja
                            ),
                            color: Colors.white, // Fondo blanco
                            child: Container(
                              height: 350, // Altura fija para la tarjeta
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Distribución de los casos por localidad',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          naranja, // Título color naranja
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:
                                            distribucionLocalidad.map((data) {
                                          return Container(
                                            width:
                                                200, // Ancho fijo para cada gráfico
                                            child: PieChartCard(
                                              localidad: data.label,
                                              porcentaje: data.value,
                                              color: data.color,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 20),

                        // Gráfico de Máximos de incidencia con scroll horizontal
                        if (maximosIncidencia.isNotEmpty)
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side:
                                  BorderSide(color: naranja), // Borde naranja
                            ),
                            color: Colors.white, // Fondo blanco
                            child: Container(
                              height: 400, // Altura fija para la tarjeta
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Máximos de incidencia',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          naranja, // Título color naranja
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        width: 600, // Ancho fijo para el gráfico
                                        child: SfCartesianChart(
                                          primaryXAxis: DateTimeAxis(
                                            dateFormat:
                                                DateFormat('dd/MM/yyyy'),
                                            intervalType:
                                                DateTimeIntervalType.days,
                                            // visibleMinimum:
                                            //     maximosIncidencia.first.date,
                                            // visibleMaximum:
                                            //     maximosIncidencia.last.date,
                                            interval: 1,
                                          ),
                                          series: <
                                              ChartSeries<IncidenceData,
                                                  DateTime>>[
                                            SplineAreaSeries<IncidenceData,
                                                DateTime>(
                                              dataSource: maximosIncidencia,
                                              xValueMapper:
                                                  (IncidenceData data, _) =>
                                                      data.date,
                                              yValueMapper:
                                                  (IncidenceData data, _) =>
                                                      data.count.toDouble(),
                                              color: naranja.withOpacity(0.5),
                                              borderColor: naranja,
                                              borderWidth: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 20),

                        // Gráfico de Distribución por género
                        if (distribucionGenero.isNotEmpty)
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side:
                                  BorderSide(color: naranja), // Borde naranja
                            ),
                            color: Colors.white, // Fondo blanco
                            child: Container(
                              height: 400, // Altura fija para la tarjeta
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Distribución por género',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          naranja, // Título color naranja
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: SfCartesianChart(
                                      primaryXAxis: CategoryAxis(),
                                      primaryYAxis: NumericAxis(
                                        interval: 1, // Intervalos de 1 en 1
                                      ),
                                      series: <
                                          ColumnSeries<ChartData, String>>[
                                        ColumnSeries<ChartData, String>(
                                          dataSource: distribucionGenero,
                                          xValueMapper: (ChartData data, _) =>
                                              data.label,
                                          yValueMapper: (ChartData data, _) =>
                                              data.value,
                                          pointColorMapper:
                                              (ChartData data, _) =>
                                                  data.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const VersionWidget(), // Pie de página con la versión
              ],
            ),
    );
  }
}

// Clases auxiliares para los datos de los gráficos
class IncidenceData {
  final DateTime date;
  final int count;

  IncidenceData(this.date, this.count);
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

// Widget personalizado para gráficos de torta en la card
class PieChartCard extends StatelessWidget {
  final String localidad;
  final double porcentaje;
  final Color color;

  PieChartCard({
    required this.localidad,
    required this.porcentaje,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200, // Altura fija para el gráfico
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: [
                  ChartData(localidad, porcentaje, color),
                  ChartData('Resto', 100 - porcentaje, Colors.grey[200]!),
                ],
                xValueMapper: (ChartData data, _) => data.label,
                yValueMapper: (ChartData data, _) => data.value,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelMapper: (ChartData data, _) =>
                    '${data.value.toStringAsFixed(1)}%',
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  labelPosition: ChartDataLabelPosition.outside,
                ),
              ),
            ],
          ),
        ),
        Text(localidad),
      ],
    );
  }
}

// Widget personalizado para los bloques de resumen
class ResumenCard extends StatelessWidget {
  final Color bordeColor;
  final String numero;
  final String titulo;
  final Color numeroColor;

  ResumenCard({
    required this.bordeColor,
    required this.numero,
    required this.titulo,
    required this.numeroColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Altura fija para las tarjetas de resumen
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: bordeColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            numero,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: numeroColor,
            ),
          ),
          SizedBox(height: 5),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              color: bordeColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
