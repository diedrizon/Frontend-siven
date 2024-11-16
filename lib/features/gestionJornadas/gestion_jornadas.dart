import 'package:flutter/material.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';

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

  @override
  void initState() {
    super.initState();

    // Inicialización de servicios
    initializeServices();

    // Carga inicial de los datos
    // loadCatalogData();
  }

  void initializeServices() {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
