import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

class AlertaTemprana extends StatefulWidget {
  const AlertaTemprana({Key? key}) : super(key: key);

  @override
  _AlertaTempranaState createState() => _AlertaTempranaState();
}

class _AlertaTempranaState extends State<AlertaTemprana> {
  String selectedRegion = "Managua";
  String selectedPeriodo = "Enero";
  String selectedEpidemia = "Dengue";

  final List<String> regiones = [
    "Managua", "RAAN", "Chinandega", "Boaco", "Masaya",
    "León", "Granada", "Carazo", "Rivas", "Matagalpa"
  ];

  final List<String> periodos = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo",
    "Junio", "Julio", "Agosto", "Septiembre", "Octubre"
  ];

  final List<String> epidemias = [
    "Dengue", "Influenza", "Malaria", "Covid-19", "Chikungunya",
    "Zika", "Hepatitis", "Tifoidea", "Colera", "Ébola"
  ];

  List<Region> departments = [];
  List<Region> municipalities = [];
  MapController mapController = MapController();
  bool showDepartments = true;

  // Mapeo de departamentos a archivos GeoJSON
  Map<String, String> departmentToFile = {
    "Boaco": "lib/assets/GeoJson/Boaco.geojson",
    "Carazo": "lib/assets/GeoJson/Carazo.geojson",
    "Chinandega": "lib/assets/GeoJson/Chinandega.geojson",
    "Chontales": "lib/assets/GeoJson/Chontales.geojson",
    "Estelí": "lib/assets/GeoJson/Estelí.geojson",
    "Granada": "lib/assets/GeoJson/Granada.geojson",
    "Jinotega": "lib/assets/GeoJson/Jinotega.geojson",
    "León": "lib/assets/GeoJson/León.geojson",
    "Madriz": "lib/assets/GeoJson/Madriz.geojson",
    "Managua": "lib/assets/GeoJson/Managua.geojson",
    "Masaya": "lib/assets/GeoJson/Masaya.geojson",
    "Matagalpa": "lib/assets/GeoJson/Matagalpa.geojson",
    "Nueva Segovia": "lib/assets/GeoJson/Nueva_Segovia.geojson",
    "Rivas": "lib/assets/GeoJson/Rivas.geojson",
    "Río San Juan": "lib/assets/GeoJson/Río_San_Juan.geojson",
    "Atlántico Norte": "lib/assets/GeoJson/Región_Autónoma_de_la_Costa_Caribe_Norte.geojson",
    "Atlántico Sur": "lib/assets/GeoJson/Región_Autónoma_de_la_Costa_Caribe_Sur.geojson",
  };

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    departments = await loadRegions('lib/assets/GeoJson/ni.json', isDepartment: true);
    setState(() {});
  }

  Future<List<Region>> loadRegions(String path, {bool isDepartment = false}) async {
    String data = await rootBundle.loadString(path);
    Map<String, dynamic> jsonResult = json.decode(data);
    List<Region> regions = [];

    List<Color> colorPalette = isDepartment ? departmentColors : municipalityColors;
    int colorIndex = 0;

    for (var feature in jsonResult['features']) {
      String name = feature['properties']['name'];
      var geometry = feature['geometry'];
      List<List<LatLng>> polygons = [];

      if (geometry['type'] == 'Polygon') {
        polygons.add(parseCoordinates(geometry['coordinates'][0]));
      } else if (geometry['type'] == 'MultiPolygon') {
        for (var polygon in geometry['coordinates']) {
          polygons.add(parseCoordinates(polygon[0]));
        }
      }

      List<Polygon> polygonShapes = [];
      List<Marker> markers = [];
      for (var coords in polygons) {
        // Asignar colores llamativos únicos
        Color color = colorPalette[colorIndex % colorPalette.length];
        colorIndex++;

        polygonShapes.add(
          Polygon(
            points: coords,
            color: color.withOpacity(0.8), // Cambiado de 'color' a 'fillColor'
            borderColor: Colors.black,
            borderStrokeWidth: 1.0,
          ),
        );

        // Calcula el centroide para colocar el marcador
        LatLng centroid = calculateCentroid(coords);
        markers.add(
          Marker(
            point: centroid,
            width: 100,
            height: 30,
            builder: (ctx) => Center(
              child: Text(
                name,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      regions.add(Region(name: name, polygons: polygonShapes, markers: markers));
    }

    return regions;
  }

  List<LatLng> parseCoordinates(List coordinates) {
    return coordinates.map<LatLng>((point) {
      return LatLng(point[1], point[0]);
    }).toList();
  }

  // Función para calcular el centroide de un polígono
  LatLng calculateCentroid(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    int totalPoints = points.length;

    for (var point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng(latitude / totalPoints, longitude / totalPoints);
  }

  // Paletas de colores llamativos para departamentos y municipios
  List<Color> departmentColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.yellowAccent,
    Colors.cyanAccent,
    Colors.deepOrangeAccent,
    Colors.indigoAccent,
    Colors.lightGreenAccent,
  ];

  List<Color> municipalityColors = [
    Colors.amber,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.lime,
    Colors.deepPurpleAccent,
    Colors.deepOrange,
    Colors.brown,
    Colors.cyan,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
  ];

  List<ChartData> _getChartData() {
    if (selectedRegion == "Managua" && selectedPeriodo == "Enero") {
      return [ChartData(1, 30), ChartData(2, 40), ChartData(3, 35), ChartData(4, 50), ChartData(5, 45)];
    } else if (selectedRegion == "RAAN" && selectedPeriodo == "Febrero") {
      return [ChartData(1, 20), ChartData(2, 35), ChartData(3, 50), ChartData(4, 40), ChartData(5, 25)];
    } else {
      return [ChartData(1, 50), ChartData(2, 60), ChartData(3, 70), ChartData(4, 55), ChartData(5, 65)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);
    final catalogService = CatalogServiceRedServicio(httpService: httpService);
    final selectionStorageService = SelectionStorageService();

    // Obtener los polígonos y marcadores a mostrar
    List<Polygon> polygons = showDepartments
        ? departments.expand((dept) => dept.polygons).toList()
        : municipalities.expand((mun) => mun.polygons).toList();

    List<Marker> markers = showDepartments
        ? departments.expand((dept) => dept.markers).toList()
        : municipalities.expand((mun) => mun.markers).toList();

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
                  // Tu código existente para los botones y dropdowns
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
                  const SizedBox(height: 20),
                  RedDeServicio(
                    catalogService: catalogService,
                    selectionStorageService: selectionStorageService,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedRegion,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRegion = newValue!;
                            });
                          },
                          items: regiones.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedPeriodo,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPeriodo = newValue!;
                            });
                          },
                          items: periodos.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedEpidemia,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedEpidemia = newValue!;
                            });
                          },
                          items: epidemias.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Gráfica de líneas
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFD9006C), width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: 600,
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Incidencias de enfermedades'),
                          legend: Legend(isVisible: true, position: LegendPosition.bottom),
                          series: <ChartSeries>[
                            LineSeries<ChartData, int>(
                              name: selectedEpidemia,
                              color: Color(0xFFC2185B),
                              dataSource: _getChartData(),
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Gráficas circulares
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFD9006C), width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Distribución de los casos",
                          style: TextStyle(
                            color: Color(0xFFD9006C),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: _buildCircularChart(context, "Managua", 29)),
                            Expanded(child: _buildCircularChart(context, "RAAN", 25)),
                            Expanded(child: _buildCircularChart(context, "Chinandega", 23)),
                            Expanded(child: _buildCircularChart(context, "Boaco", 21)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mapa interactivo sin OpenStreetMap
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFD9006C), width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: departments.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              center: LatLng(12.865416, -85.207229),
                              zoom: 7.0,
                              minZoom: 5.0,
                              maxZoom: 10.0,
                              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                              onTap: _handleTap,
                            ),
                            nonRotatedChildren: [],
                            children: [
                              // Fondo blanco
                              Container(
                                color: Colors.white,
                              ),
                              PolygonLayer(
                                polygons: polygons,
                              ),
                              MarkerLayer(
                                markers: markers,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          const VersionWidget(),
        ],
      ),
    );
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    if (showDepartments) {
      _checkTapOnRegion(latlng, departments);
    } else {
      // Si deseas manejar taps en municipios, puedes agregar lógica aquí
    }
  }

  void _checkTapOnRegion(LatLng point, List<Region> regions) async {
    for (var region in regions) {
      for (var polygon in region.polygons) {
        if (isPointInPolygon(point, polygon.points)) {
          await _loadMunicipalities(region.name);
          setState(() {
            showDepartments = false;
          });
          // Centrar y hacer zoom en el departamento seleccionado
          mapController.fitBounds(LatLngBounds.fromPoints(polygon.points),
              options: const FitBoundsOptions(padding: EdgeInsets.all(20)));
          return;
        }
      }
    }
  }

  Future<void> _loadMunicipalities(String departmentName) async {
    String? filePath = departmentToFile[departmentName];
    if (filePath == null) {
      print('Archivo no encontrado para $departmentName');
      return;
    }
    municipalities = await loadRegions(filePath);
    setState(() {});
  }

  // Implementación manual del algoritmo de punto en polígono
  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng a = polygon[j];
      LatLng b = polygon[j + 1];
      if (rayCastIntersect(point, a, b)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // true si es impar
  }

  bool rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    double m = (bY - aY) / (bX - aX);
    double bee = aY - m * aX;
    double x = (pY - bee) / m;

    return x > pX;
  }

  Widget _buildCircularChart(BuildContext context, String label, double percentage) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<_PieData, String>(
                dataSource: [
                  _PieData(label, percentage),
                  _PieData("Restante", 100 - percentage),
                ],
                pointColorMapper: (_PieData data, _) =>
                    data.y == percentage ? Color(0xFFD9006C) : Color(0xFFe0e0e0),
                xValueMapper: (_PieData data, _) => data.x,
                yValueMapper: (_PieData data, _) => data.y,
                innerRadius: '70%',
              ),
            ],
          ),
        ),
        Text("$label", style: TextStyle(fontSize: 12)),
        Text("$percentage%", style: TextStyle(fontSize: 16, color: Color(0xFFD9006C))),
      ],
    );
  }

  List<BarChartData> _getBarChartData() {
    return [
      BarChartData('Cat1', 10),
      BarChartData('Cat2', 30),
      BarChartData('Cat3', 20),
      BarChartData('Cat4', 50),
    ];
  }
}

// Clases auxiliares
class Region {
  String name;
  List<Polygon> polygons;
  List<Marker> markers;

  Region({required this.name, required this.polygons, required this.markers});
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double y;
}

class BarChartData {
  BarChartData(this.category, this.value);
  final String category;
  final double value;
}

class _PieData {
  _PieData(this.x, this.y);
  final String x;
  final double y;
}
