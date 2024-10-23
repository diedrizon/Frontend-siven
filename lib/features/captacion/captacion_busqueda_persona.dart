import 'package:flutter/material.dart';
import 'package:siven_app/widgets/version.dart'; // Widget reutilizado
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; // Widget reutilizado
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;

class CaptacionBusquedaPersona extends StatefulWidget {
  const CaptacionBusquedaPersona({Key? key}) : super(key: key);

  @override
  _CaptacionBusquedaPersonaState createState() => _CaptacionBusquedaPersonaState();
}

class _CaptacionBusquedaPersonaState extends State<CaptacionBusquedaPersona> {
  bool habilitarBusquedaPorNombre = false;
  String? seleccion; // Para manejar la selección de botones "Recién Nacido" o "Desconocido"

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;

  @override
  void initState() {
    super.initState();

    // Inicialización de servicios
    initializeServices();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
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
              Navigator.pushNamed(context, '/home');
            },
          ),
        ),
        title: const EncabezadoBienvenida(), // Título reutilizado
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
                  // Filas con botones adicionales (BotonCentroSalud y IconoPerfil)
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
                      
                  // Red de servicio
                  RedDeServicio(
                    catalogService: catalogService,
                    selectionStorageService: selectionStorageService,
                  ),
                  const SizedBox(height: 20),

                  // Título de búsqueda con el ícono de lupa, ajustado hacia la izquierda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.search, color: Color(0xFF00BCD4)), // Ícono de lupa con color #00BCD4
                      SizedBox(width: 10),
                      Text(
                        'Búsqueda de persona',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF00BCD4), // Color del texto
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Botones de selección "Recién Nacido" y "Desconocido", centrados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centrados
                    children: [
                      SizedBox(
                        width: 150, // Fijando el ancho para ambos botones
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              seleccion = 'Recién Nacido';
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                            ),
                            color: seleccion == 'Recién Nacido' ? Color(0xFFEAF9FF) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              child: Column(
                                children: const [
                                  Icon(Icons.child_care, color: Color(0xFF00BCD4)),
                                  SizedBox(height: 5),
                                  Text(
                                    'Recién Nacido',
                                    style: TextStyle(color: Color(0xFF00BCD4)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              seleccion = 'Desconocido';
                              // Navegación hacia la pantalla captacion_busqueda_por_nombre
                              Navigator.pushNamed(context, '/captacion_busqueda_por_nombre');
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                            ),
                            color: seleccion == 'Desconocido' ? Color(0xFFEAF9FF) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              child: Column(
                                children: const [
                                  Icon(Icons.person_outline, color: Color(0xFF00BCD4)),
                                  SizedBox(height: 5),
                                  Text(
                                    'Desconocido',
                                    style: TextStyle(color: Color(0xFF00BCD4)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Fila con "Es una persona identificada" y "Habilitar búsqueda por nombre"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Usa Expanded para ajustarse al ancho disponible
                        child: const Text(
                          'Es una persona identificada',
                          style: TextStyle(color: Color(0xFF2C3E50)),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.warning, color: Color(0xFF00BCD4)),
                          SizedBox(width: 5),
                          Text(
                            'Habilitar búsqueda por nombre',
                            style: TextStyle(color: Color(0xFF2C3E50)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Campo de texto para número de identificación
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Escribe N° de identificación, Cód. de expediente único',
                      hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nota de asterisco
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* La búsqueda por nombre se habilita con un botón.',
                      style: TextStyle(color: Color(0xFFBDC3C7)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón Buscar con color de fondo 00BCD4
                  ElevatedButton(
                    onPressed: () {
                      // Navegación a captacion_resultado_busqueda
                      Navigator.pushNamed(context, '/captacion_resultado_busqueda');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      backgroundColor: const Color(0xFF00BCD4), // Fondo del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'BUSCAR',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VersionWidget(), // Widget de la versión reutilizado
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CaptacionBusquedaPersona(),
  ));
}
