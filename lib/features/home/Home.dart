// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/custom_card.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:siven_app/widgets/version.dart'; // Importa el widget reutilizable
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;

  final List<CardItem> cardItems = [
    CardItem(
      text: "REGISTRO Y SEGUIMIENTO DE DATOS EPIDEMIOLÓGICOS",
      iconPath: 'lib/assets/homeicon/icono-registro.webp',
      backgroundColor: const Color(0xFF00BFFF),
    ),
    CardItem(
      text: "ALERTAS TEMPRANAS",
      iconPath: 'lib/assets/homeicon/alerta-_1_-2.webp',
      backgroundColor: const Color(0xFFFF69B4),
    ),
    CardItem(
      text: "GESTIÓN DE JORNADAS DE VIGILANCIA EPIDEMIOLÓGICA",
      iconPath: 'lib/assets/homeicon/equipo-medico-_4_-1.webp',
      backgroundColor: const Color(0xFF9C27B0),
    ),
    CardItem(
      text: "REGISTRO EPIDEMIOLÓGICO A NIVEL ESCOLAR",
      iconPath: 'lib/assets/homeicon/estudio-1.webp',
      backgroundColor: const Color(0xFF1E90FF),
    ),
    CardItem(
      text: "GESTIÓN DE USUARIO Y PARAMETRIZACIÓN",
      iconPath: 'lib/assets/homeicon/configuracion-2.webp',
      backgroundColor: const Color(0xFF32CD32),
    ),
    CardItem(
      text: "REPORTES Y ANÁLISIS",
      iconPath: 'lib/assets/homeicon/analitica-1.webp',
      backgroundColor: const Color(0xFFFFA500),
    ),
  ];

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
  }

  // Método para actualizar la pantalla cuando se cambia la selección
  void _onSelectionChanged() {
    setState(() {
      // Actualiza el estado para reflejar los cambios
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

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
              // Navega a la pantalla red_servicio
              Navigator.pushNamed(context, '/red_servicio');
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
                  // Ajustamos los widgets para pasarles los servicios
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BotonCentroSalud(
                        catalogService: catalogService,
                        selectionStorageService: selectionStorageService,
                        onSelectionChanged: _onSelectionChanged, // Añadido para actualizar la pantalla
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

                  // Lista de tarjetas
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cardItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return CustomCard(
                        item: cardItems[index],
                        screenHeight: screenSize.height,
                        onTap: () {
                          // Navegación específica según el texto de la tarjeta
                          if (cardItems[index].text == "REGISTRO Y SEGUIMIENTO DE DATOS EPIDEMIOLÓGICOS") {
                            Navigator.pushNamed(context, '/captacion_busqeda_persona');
                          } else if (cardItems[index].text == "REPORTES Y ANÁLISIS") {
                            Navigator.pushNamed(context, '/FiltrarReporte');
                          } else if (cardItems[index].text == "ALERTAS TEMPRANAS") {
                            Navigator.pushNamed(context, '/alerta_temprana');
                          }
                          // Puedes agregar más condiciones para otras tarjetas si lo deseas
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const VersionWidget(), // Widget de versión en la parte inferior
        ],
      ),
    );
  }
}
