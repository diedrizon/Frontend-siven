import 'package:flutter/material.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/widgets/red_de_servicio_widget.dart';
import 'package:http/http.dart' as http;

class RedDeServicioScreen extends StatefulWidget {
  const RedDeServicioScreen({Key? key}) : super(key: key);

  @override
  _RedDeServicioScreenState createState() => _RedDeServicioScreenState();
}

class _RedDeServicioScreenState extends State<RedDeServicioScreen> {
  CatalogServiceRedServicio? catalogService;
  SelectionStorageService? selectionStorageService;

  Future<void> initializeServices() async {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    // Inicializamos los servicios
    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder(
        future: initializeServices(), // Inicializa los servicios de manera asíncrona
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Indicador de carga
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al inicializar servicios'));
          } else {
            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 0.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/ministerio_de_salud_nicaragua_2020.webp',
                              width: 195.0,
                              height: 150.0,
                            ),
                            const SizedBox(width: 30.0),
                            Image.asset(
                              'lib/assets/SIVEN-SD.webp',
                              width: 100.0,
                              height: 150.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 80.0),
                        Container(
                          width: screenWidth * 0.85,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromRGBO(255, 106, 153, 1),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text(
                                  'RED DE SERVICIO - MINSA',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Color(0xFFFF5D8F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                const Text(
                                  'ESTABLECER UNIDAD DE SALUD',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                const SizedBox(height: 30.0),

                                // Llamada al widget RedDeServicioWidget con los servicios inyectados
                                RedDeServicioWidget(
                                  catalogService: catalogService!,
                                  selectionStorageService: selectionStorageService!,
                                ),

                                const SizedBox(height: 50.0),

                                // Botón de continuar
                                continueButton(screenWidth),

                                const SizedBox(height: 20.0),

                                GestureDetector(
                                  onTap: () {
                                    // Navegar a la pantalla de login
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: const Text(
                                    'Regresar',
                                    style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      decoration: TextDecoration.underline,
                                      fontSize: 16.0,
                                    ),
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
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SIVEN 1.0',
                          style: TextStyle(fontSize: 12.0, color: Color(0xFF757575)),
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  Widget continueButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.6,
      height: 50.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: () {
          // Navegar a la pantalla de Home
          Navigator.pushNamed(context, '/home');
        },
        child: const Text(
          'CONTINUAR',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
