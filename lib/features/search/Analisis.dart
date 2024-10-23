import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; // Importar widgets reutilizables
import 'package:siven_app/widgets/Version.dart'; // Pie de página reutilizable
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(AnalisisApp());
}

class AnalisisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFBFBFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 13.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF1877F2), size: 32),
              onPressed: () {
                // Navegar a resultados_busqueda
                Navigator.pushNamed(context, '/resultados_busqueda');
              },
            ),
          ),
          title: const EncabezadoBienvenida(), // Encabezado reutilizable
          centerTitle: true,
        ),
        body: AnalisisScreen(),
      ),
    );
  }
}

class AnalisisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inicializar servicios
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);
    final catalogService = CatalogServiceRedServicio(httpService: httpService);
    final selectionStorageService = SelectionStorageService();

    return Scaffold(
      backgroundColor: Color(0xFFFBFBFB),
      // Se elimina el AppBar duplicado aquí
      body: Column(
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
                      Icon(Icons.bar_chart, color: Color(0xFFF7941D)),
                      SizedBox(width: 10),
                      Text(
                        'Análisis de captación',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF7941D),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Fila con 3 Card para Casos registrados, activos y finalizados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ResumenCard(
                          bordeColor: Color(0xFFF7941D),
                          numero: '150',
                          titulo: 'Casos registrados',
                          numeroColor: Color(0xFFF7941D),
                        ),
                      ),
                      SizedBox(width: 10), // Separación entre cards
                      Expanded(
                        child: ResumenCard(
                          bordeColor: Color(0xFFD9006C),
                          numero: '80',
                          titulo: 'Casos activos',
                          numeroColor: Color(0xFFD9006C),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ResumenCard(
                          bordeColor: Color(0xFF39B54A),
                          numero: '70',
                          titulo: 'Casos finalizados',
                          numeroColor: Color(0xFF39B54A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Card para los gráficos de torta
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Color(0xFFF7941D)), // Borde naranja
                    ),
                    color: Colors.white, // Fondo blanco
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distribución de los casos por localidad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF7941D), // Título color naranja
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: PieChartCard(
                                  localidad: 'Juigalpa',
                                  porcentaje: 40,
                                  color: Color(0xFFF7941D),
                                ),
                              ),
                              Expanded(
                                child: PieChartCard(
                                  localidad: 'Acoyapa',
                                  porcentaje: 35,
                                  color: Color(0xFFFFA500),
                                ),
                              ),
                              Expanded(
                                child: PieChartCard(
                                  localidad: 'La Libertad',
                                  porcentaje: 25,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Fila con los gráficos de líneas y columnas apiladas con scroll
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: Color(0xFFF7941D)), // Borde naranja
                          ),
                          color: Colors.white, // Fondo blanco
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Máximos de incidencia',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF7941D), // Título color naranja
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 300, // Gráfico más alto
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Container(
                                      height: 300, // Limitar el alto máximo del gráfico
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        series: <LineSeries>[
                                          LineSeries<ChartData, String>(
                                            dataSource: [
                                              ChartData('8 AM', 30, Color(0xFFF7941D)),
                                              ChartData('10 AM', 40, Color(0xFFF7941D)),
                                              ChartData('12 PM', 35, Color(0xFFF7941D)),
                                              ChartData('2 PM', 50, Color(0xFFF7941D)),
                                            ],
                                            xValueMapper: (ChartData data, _) => data.label,
                                            yValueMapper: (ChartData data, _) => data.value,
                                            color: Color(0xFFF7941D),
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
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: Color(0xFFF7941D)), // Borde naranja
                          ),
                          color: Colors.white, // Fondo blanco
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Distribución por género',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF7941D), // Título color naranja
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 300, // Gráfico más alto
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Container(
                                      height: 300, // Limitar el alto máximo del gráfico
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        series: <StackedColumnSeries>[
                                          StackedColumnSeries<ChartData, String>(
                                            dataSource: [
                                              ChartData('Hombres', 60, Color(0xFFF7941D)),
                                              ChartData('Mujeres', 40, Color(0xFF4A4A4A)),
                                            ],
                                            xValueMapper: (ChartData data, _) => data.label,
                                            yValueMapper: (ChartData data, _) => data.value,
                                            pointColorMapper: (ChartData data, _) => data.color,
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
                      ),
                    ],
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
          height: 150,
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: [
                  ChartData(localidad, porcentaje, color),
                ],
                xValueMapper: (ChartData data, _) => data.label,
                yValueMapper: (ChartData data, _) => data.value,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelMapper: (ChartData data, _) => '${data.value}%',
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
      width: MediaQuery.of(context).size.width * 0.3,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: bordeColor, width: 1), // Borde color naranja
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
              color: Color(0xFFF7941D), // Título color naranja
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para los datos del gráfico
class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
