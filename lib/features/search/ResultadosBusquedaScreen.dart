// ResultadosBusquedaScreen.dart

import 'package:flutter/material.dart';
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart';
import 'package:siven_app/widgets/version.dart';
import 'package:siven_app/widgets/card_persona.dart';
import 'package:siven_app/widgets/filtro_persona.dart';
import 'package:siven_app/core/services/captacion_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'Analisis.dart';

class ResultadosBusquedaScreen extends StatefulWidget {
  final String silais;
  final String unidadSalud;
  final String evento;
  final String fechaInicio;
  final String fechaFin;

  const ResultadosBusquedaScreen({
    required this.silais,
    required this.unidadSalud,
    required this.evento,
    required this.fechaInicio,
    required this.fechaFin,
    Key? key,
  }) : super(key: key);

  @override
  _ResultadosBusquedaScreenState createState() =>
      _ResultadosBusquedaScreenState();
}

class _ResultadosBusquedaScreenState extends State<ResultadosBusquedaScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;

  late CaptacionService captacionService;
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  bool _servicesInitialized = false;
  List<Map<String, dynamic>> personasFiltradas = [];

  @override
  void initState() {
    super.initState();
    initializeServices().then((_) {
      _fetchResultadosFiltrados();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 0) {
        if (!_showHeader) {
          setState(() {
            _showHeader = true;
          });
        }
      } else if (_scrollController.position.pixels > 100) {
        if (_showHeader) {
          setState(() {
            _showHeader = false;
          });
        }
      }
    });
  }

  Future<void> initializeServices() async {
    final httpClient = http.Client();
    final httpService = HttpService(httpClient: httpClient);

    captacionService = CaptacionService(httpService: httpService);
    catalogService = CatalogServiceRedServicio(httpService: httpService);
    selectionStorageService = SelectionStorageService();

    setState(() {
      _servicesInitialized = true;
    });
  }

  Future<void> _fetchResultadosFiltrados() async {
    if (!_servicesInitialized) {
      return;
    }

    try {
      final resultados = await captacionService.buscarCaptaciones(
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
        personasFiltradas = resultados;

        // Imprimir datos para verificar el campo 'sexo'
        print('Datos de personasFiltradas:');
        for (var persona in personasFiltradas) {
          print(
              'Nombre: ${persona['nombreCompleto']}, Sexo: ${persona['sexo']}');
        }
      });
    } catch (error) {
      print('Error al buscar captaciones: $error');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Función existente para generar un reporte general
  Future<void> generarReportePDF() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load('lib/assets/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('lib/assets/Isotipo-.webp')).buffer.asUint8List(),
    );

    final tituloEstilo = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      color: PdfColors.lightBlue,
    );

    final subtituloEstilo = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      color: PdfColors.blueGrey700,
    );

    final textoEstilo = pw.TextStyle(
      fontSize: 12,
      font: ttf,
      color: PdfColors.blueGrey700,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(logoImage, width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('SIVEN', style: tituloEstilo),
                pw.SizedBox(height: 10),
                pw.Text('Reporte de Resultados de Búsqueda',
                    style: subtituloEstilo),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                    style: textoEstilo),
              ],
            ),
          );
        },
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 1,
              child: pw.Text('Detalles de Resultados', style: tituloEstilo),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                'Identificación',
                'Expediente',
                'Nombre',
                'Ubicación',
              ],
              data: personasFiltradas.map((persona) {
                return [
                  persona['cedula'] ?? 'Sin cédula',
                  persona['codigoExpediente'] ?? 'Sin expediente',
                  persona['nombreCompleto'] ?? 'Sin nombre',
                  '${persona['municipio'] ?? 'Sin municipio'}/${persona['departamento'] ?? 'Sin departamento'}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                font: ttf,
                color: PdfColors.white,
              ),
              cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.lightBlue,
              ),
              cellHeight: 25,
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
              },
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
              },
              border: pw.TableBorder.all(color: PdfColors.blueGrey700),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Reporte_Generado.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reporte generado en: ${file.path}')),
    );
  }

  // Nueva función para generar un reporte individual en formato de tabla
  Future<void> generarReportePDFPersona(Map<String, dynamic> persona) async {
    final pdf = pw.Document();

    // Cargar fuentes y assets
    final fontData = await rootBundle.load('lib/assets/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('lib/assets/Isotipo-.webp')).buffer.asUint8List(),
    );

    // Definir estilos
    final tituloEstilo = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      color: PdfColors.lightBlue,
    );

    final subtituloEstilo = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      font: ttf,
      color: PdfColors.blueGrey700,
    );

    final textoEstilo = pw.TextStyle(
      fontSize: 12,
      font: ttf,
      color: PdfColors.blueGrey700,
    );

    // Crear la primera página con el encabezado
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(logoImage, width: 100, height: 100),
                pw.SizedBox(height: 20),
                pw.Text('SIVEN', style: tituloEstilo),
                pw.SizedBox(height: 10),
                pw.Text('Reporte de Persona', style: subtituloEstilo),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                    style: textoEstilo),
              ],
            ),
          );
        },
      ),
    );

    // Crear una página con los detalles de la persona en formato de tabla
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 1,
                child: pw.Text('Detalles de la Persona', style: subtituloEstilo),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Campo', 'Valor'],
                data: [
                  ['Identificación', persona['cedula'] ?? 'Sin cédula'],
                  ['Expediente', persona['codigoExpediente'] ?? 'Sin expediente'],
                  ['Nombre', persona['nombreCompleto'] ?? 'Sin nombre'],
                  [
                    'Ubicación',
                    '${persona['municipio'] ?? 'Sin municipio'}/${persona['departamento'] ?? 'Sin departamento'}'
                  ],
                  ['Sexo', persona['sexo'] ?? 'No especificado'],
                  // Agrega más campos según tus necesidades
                ],
                headerStyle: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                  color: PdfColors.white,
                ),
                cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.lightBlue,
                ),
                cellHeight: 25,
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                },
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(2),
                },
                border: pw.TableBorder.all(color: PdfColors.blueGrey700),
              ),
            ],
          );
        },
      ),
    );

    // Guardar el PDF en el dispositivo
    final output = await getTemporaryDirectory();
    final sanitizedNombre = (persona['nombreCompleto'] ?? 'Persona')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final file = File("${output.path}/Reporte_$sanitizedNombre.pdf");
    await file.writeAsBytes(await pdf.save());

    // Abrir el PDF generado
    await OpenFilex.open(file.path);

    // Mostrar una notificación al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Reporte generado para ${persona['nombreCompleto'] ?? 'la persona'} en: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color azulBrillante = Color(0xFF1877F2);
    const Color grisOscuro = Color(0xFF4A4A4A);
    const Color naranja = Color(0xFFF7941D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 90),
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
                      const SizedBox(height: 10),
                      RedDeServicio(
                        catalogService: catalogService,
                        selectionStorageService: selectionStorageService,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: const [
                          Icon(Icons.search, color: naranja, size: 26),
                          SizedBox(width: 8),
                          Text(
                            'Resultado de búsqueda',
                            style: TextStyle(
                              fontSize: 18,
                              color: naranja,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FiltroPersonaWidget(
                              hintText: 'Filtro por datos de la persona',
                              colorBorde: naranja,
                              colorIcono: grisOscuro,
                              colorTexto: grisOscuro,
                              onChanged: (valor) {
                                _filtrarPorDatosPersona(valor);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                generarReportePDF();
                              },
                              icon: const Icon(Icons.article,
                                  color: naranja, size: 40),
                              label: const Text(
                                'Generar Reporte de Esta Lista',
                                style: TextStyle(color: naranja),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: naranja),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(150, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnalisisScreen(
                                      silais: widget.silais,
                                      unidadSalud: widget.unidadSalud,
                                      evento: widget.evento,
                                      fechaInicio: widget.fechaInicio,
                                      fechaFin: widget.fechaFin,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.analytics,
                                  color: naranja, size: 40),
                              label: const Text(
                                'Generar Análisis de Esta Lista',
                                style: TextStyle(color: naranja),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: naranja),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(150, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: personasFiltradas.length,
                        itemBuilder: (context, index) {
                          final persona = personasFiltradas[index];
                          return CardPersonaWidget(
                            identificacion: persona['cedula'] ?? 'Sin cédula',
                            expediente:
                                persona['codigoExpediente'] ?? 'Sin expediente',
                            nombre:
                                persona['nombreCompleto'] ?? 'Sin nombre',
                            ubicacion:
                                '${persona['municipio'] ?? 'Sin municipio'}/${persona['departamento'] ?? 'Sin departamento'}',
                            colorBorde: naranja,
                            colorBoton: naranja,
                            textoBoton: 'Generar Reporte',
                            onBotonPressed: () {
                              generarReportePDFPersona(persona);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const VersionWidget(),
            ],
          ),
          if (_showHeader)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 13.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: azulBrillante, size: 32),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      title: const EncabezadoBienvenida(),
                      centerTitle: true,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _filtrarPorDatosPersona(String filtro) async {
    try {
      final resultados =
          await captacionService.filtrarPorDatosPersona(filtro);

      setState(() {
        personasFiltradas = resultados;

        // Imprimir datos para verificar el campo 'sexo' después de filtrar
        print('Datos filtrados de personasFiltradas:');
        for (var persona in personasFiltradas) {
          print(
              'Nombre: ${persona['nombreCompleto']}, Sexo: ${persona['sexo']}');
        }
      });
    } catch (error) {
      print('Error al filtrar por persona: $error');
    }
  }
}
