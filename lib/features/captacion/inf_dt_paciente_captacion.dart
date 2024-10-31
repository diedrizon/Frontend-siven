// lib/screens/info_dt_paciente_captacion.dart

import 'package:flutter/material.dart';
import 'package:siven_app/widgets/version.dart'; // Widget reutilizado
import 'package:siven_app/widgets/Encabezado_reporte_analisis.dart'; // Widget reutilizado
import 'package:siven_app/core/services/catalogo_service_red_servicio.dart';
import 'package:siven_app/core/services/selection_storage_service.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http;
import 'package:siven_app/core/services/EventoSaludService.dart';

class InfoDtPacienteCaptacion extends StatefulWidget {
  const InfoDtPacienteCaptacion({Key? key}) : super(key: key);

  @override
  _InfoDtPacienteCaptacionState createState() =>
      _InfoDtPacienteCaptacionState();
}

class _InfoDtPacienteCaptacionState extends State<InfoDtPacienteCaptacion> {
  bool _showDatosPaciente =
      true; // Estado para controlar la visibilidad de "Datos del paciente"
  bool _showDatosCaptacion =
      false; // Estado para controlar la visibilidad de "Datos de captación"

  // Lista de eventos de captación (simulando más datos)
  final List<Map<String, dynamic>> _eventosCaptacion = [
    {
      'event': 'Malaria',
      'status': 'ACTIVO',
      'lugarCaptacion': 'Domicilio',
      'silais': 'BOACO',
      'unidad': 'CAPS - BOACO',
      'fecha': '27/08/2024'
    },
    {
      'event': 'Malaria',
      'status': 'FINALIZADO',
      'lugarCaptacion': 'Domicilio',
      'silais': 'BOACO',
      'unidad': 'CAPS - BOACO',
      'fecha': '14/11/2023'
    },
    {
      'event': 'Dengue',
      'status': 'ACTIVO',
      'lugarCaptacion': 'Escuela',
      'silais': 'LEÓN',
      'unidad': 'CAPS - LEÓN',
      'fecha': '11/09/2024'
    },
    {
      'event': 'COVID-19',
      'status': 'FINALIZADO',
      'lugarCaptacion': 'Hospital',
      'silais': 'MANAGUA',
      'unidad': 'CAPS - MANAGUA',
      'fecha': '03/05/2024'
    },
  ];

  // Paginación
  int _currentPage = 0;
  final int _itemsPerPage = 2;

  // Declaración de servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late EventoSaludService eventoSaludService; // Servicio agregado

  // Datos de la persona seleccionada
  Map<String, dynamic> persona = {};

  // Variable para almacenar el nombre del evento seleccionado
  String? _selectedEventoName;

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
    eventoSaludService =
        EventoSaludService(httpService: httpService); // Inicializar
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener los argumentos pasados desde la pantalla de búsqueda
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        persona = args;
      });
    } else {
      // Manejar el caso donde no se pasaron argumentos
      persona = {};
    }
  }

  // Función para alternar entre las tarjetas
  void _toggleCard(String card) {
    setState(() {
      if (card == 'paciente') {
        _showDatosPaciente = !_showDatosPaciente;
        _showDatosCaptacion = false;
      } else if (card == 'captacion') {
        _showDatosCaptacion = !_showDatosCaptacion;
        _showDatosPaciente = false;
      }
    });
  }

  // Función para obtener los eventos en la página actual
  List<Map<String, dynamic>> _getPaginatedEventos() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    return _eventosCaptacion.sublist(
        start, end.clamp(0, _eventosCaptacion.length));
  }

  // Función para cambiar de página
  void _changePage(int direction) {
    setState(() {
      int maxPage = (_eventosCaptacion.length / _itemsPerPage).ceil() - 1;
      if (direction == -1 && _currentPage > 0) {
        _currentPage--;
      } else if (direction == 1 && _currentPage < maxPage) {
        _currentPage++;
      }
    });
  }

  // Mostrar tarjeta flotante centrada al hacer clic en el ícono "+"
  void _showCaptacionDialog() async {
    List<Map<String, dynamic>> eventos = [];
    String? selectedEvento;

    try {
      // Obtener eventos desde el servicio
      eventos = await eventoSaludService.listarEventosSalud();
    } catch (e) {
      print('Error al listar eventos de salud: $e');
    }

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nueva captación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF00C1D4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar evento de salud *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: eventos.map((evento) {
                      return DropdownMenuItem<String>(
                        value: evento['nombre'],
                        child: Text(evento['nombre']),
                      );
                    }).toList(),
                    value: selectedEvento,
                    onChanged: (value) {
                      setState(() {
                        selectedEvento = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                        context); // Cerrar el diálogo sin retornar valor
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF00C1D4), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(fontSize: 16, color: Color(0xFF00C1D4)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (selectedEvento != null) {
                      Navigator.pop(context,
                          selectedEvento); // Retornar el evento seleccionado
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00C1D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedEventoName =
            result; // Actualizar la variable de estado con el evento seleccionado
        // Opcional: Agregar el nuevo evento a la lista de eventos si es necesario
        _eventosCaptacion.add({
          'event': result,
          'status': 'ACTIVO', // Puedes ajustar estos valores según tu lógica
          'lugarCaptacion': 'Nuevo Lugar',
          'silais': 'Nuevo SILAIS',
          'unidad': 'Nueva Unidad',
          'fecha': 'Fecha Actual',
        });
      });

      // Construir el nombre completo desde los datos de la persona
      String nombreCompleto =
          '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
                  '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'
              .trim();

      // Navegar a la pantalla '/captacion' pasando el evento seleccionado y el nombre completo
      Navigator.pushNamed(
        context,
        '/captacion',
        arguments: {
          'eventoSeleccionado': result,
          'nombreCompleto': nombreCompleto,
        },
      );
    }
  }

  // Función para calcular la edad a partir de la fecha de nacimiento
  String? calcularEdad(String? fechaNacimiento) {
    if (fechaNacimiento == null || fechaNacimiento.isEmpty) return null;
    try {
      DateTime fecha = DateTime.parse(fechaNacimiento);
      DateTime ahora = DateTime.now();
      int edad = ahora.year - fecha.year;
      if (ahora.month < fecha.month ||
          (ahora.month == fecha.month && ahora.day < fecha.day)) {
        edad--;
      }
      return '$edad años';
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los eventos a mostrar en la página actual
    List<Map<String, dynamic>> eventosPagina = _getPaginatedEventos();
    int totalRegistros = _eventosCaptacion.length;
    int paginaInicio = _currentPage * _itemsPerPage + 1;
    int paginaFin = (_currentPage * _itemsPerPage + eventosPagina.length)
        .clamp(0, totalRegistros);

    // Construir el nombre completo desde los datos de la persona
    String nombreCompleto =
        '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
                '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'
            .trim();

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
              Navigator.pushNamed(
                context,
                '/captacion_resultado_busqueda', // Navegar a '/captacion_resultado_busqueda'
              );
            },
          ),
        ),
        title: const EncabezadoBienvenida(), // Reutilizando el encabezado
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

                  // Nombre del paciente con el color #00C1D4
                  Row(
                    children: [
                      Icon(Icons.account_circle,
                          color: Color(0xFF00C1D4), size: 32),
                      const SizedBox(width: 10),
                      Text(
                        nombreCompleto.isNotEmpty
                            ? nombreCompleto
                            : 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C1D4), // Mantener el mismo color
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta 1: Datos del paciente (con función para ocultar/mostrar)
                  InkWell(
                    onTap: () => _toggleCard('paciente'),
                    child: Card(
                      color: Colors.white, // Fondo blanco de la tarjeta
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                            color: Color(0xFF00C1D4), width: 1), // Borde azul
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado de la tarjeta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Número dentro de un cuadro
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF00C1D4),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        '1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Datos del paciente',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00C1D4),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: const [
                                    Icon(Icons.edit, color: Color(0xFF00C1D4)),
                                    SizedBox(width: 10),
                                    Icon(Icons.copy,
                                        color: Color(
                                            0xFF00C1D4)), // Icono de copiar
                                  ],
                                ),
                              ],
                            ),
                            if (_showDatosPaciente) ...[
                              const SizedBox(height: 10),
                              // Información del paciente organizada en dos columnas usando Table
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      _PatientInfoRow(
                                          label: 'Código expediente único',
                                          value: persona['codigo_expediente']
                                                  ?.toString() ??
                                              'Sin dato'),
                                      _PatientInfoRow(
                                          label: 'Teléfono',
                                          value:
                                              persona['telefono']?.toString() ??
                                                  'Sin dato'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      _PatientInfoRow(
                                          label: 'Nº de cédula',
                                          value:
                                              persona['cedula']?.toString() ??
                                                  'Sin cédula'),
                                      _PatientInfoRow(
                                          label: 'Estado civil',
                                          value: persona['estado_civil']
                                                  ?.toString() ??
                                              'Sin dato'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      _PatientInfoRow(
                                          label: 'Fecha de nacimiento',
                                          value: persona['fecha_nacimiento']
                                                  ?.toString() ??
                                              'Sin dato'),
                                      _PatientInfoRow(
                                          label: 'Etnia',
                                          value: persona['grupo_etnico']
                                                  ?.toString() ??
                                              'Sin dato'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      _PatientInfoRow(
                                          label: 'Edad',
                                          value: calcularEdad(persona[
                                                  'fecha_nacimiento']) ??
                                              'Sin dato'),
                                      _PatientInfoRow(
                                          label: 'Ocupación',
                                          value: persona['ocupacion']
                                                  ?.toString() ??
                                              'Sin dato'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      _PatientInfoRow(
                                          label: 'Sexo',
                                          value: persona['sexo']?.toString() ??
                                              'Sin dato'),
                                      _PatientInfoRow(
                                          label: 'Lugar de nacimiento',
                                          value: persona['direccion_domicilio']
                                                  ?.toString() ??
                                              'Sin dato'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      _PatientInfoRow(
                                          label: 'Tipo de sangre',
                                          value: persona['tipo_telefono']
                                                  ?.toString() ??
                                              'Sin dato'),
                                      _PatientInfoRow(
                                          label: 'Residencia actual',
                                          value: persona['direccion_domicilio']
                                                  ?.toString() ??
                                              'Sin dato'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta 2: Datos de captación con tarjetas internas y paginación
                  InkWell(
                    onTap: () => _toggleCard('captacion'),
                    child: Card(
                      color: Colors.white, // Fondo blanco de la tarjeta
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                            color: Color(0xFF00C1D4), width: 1), // Borde azul
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado de la tarjeta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Número dentro de un cuadro
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF00C1D4),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Datos de captación',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00C1D4),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Color(0xFF00C1D4)),
                                  onPressed: _showCaptacionDialog,
                                ),
                              ],
                            ),
                            if (_showDatosCaptacion) ...[
                              const SizedBox(height: 10),
                              // Mostramos los eventos paginados
                              for (var evento in eventosPagina)
                                _EventCard(
                                  event: evento['event'],
                                  status: evento['status'],
                                  lugarCaptacion: evento['lugarCaptacion'],
                                  silais: evento['silais'],
                                  unidad: evento['unidad'],
                                  fecha: evento['fecha'],
                                ),
                              const SizedBox(height: 20),

                              // Control de paginado
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Botón de retroceder página
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Color(0xFF00C1D4)),
                                    onPressed: () => _changePage(-1),
                                  ),
                                  // Texto de paginado
                                  Text(
                                    '$paginaInicio-$paginaFin de $totalRegistros Registros encontrados',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                  // Botón de avanzar página
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward,
                                        color: Color(0xFF00C1D4)),
                                    onPressed: () => _changePage(1),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          const VersionWidget(), // Widget de la versión en la parte inferior
        ],
      ),
    );
  }
}

// Tarjeta interna para los eventos de salud con íconos de estado activo/inactivo
class _EventCard extends StatelessWidget {
  final String event;
  final String status;
  final String lugarCaptacion;
  final String silais;
  final String unidad;
  final String fecha;

  const _EventCard({
    required this.event,
    required this.status,
    required this.lugarCaptacion,
    required this.silais,
    required this.unidad,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el color y el ícono del estado (ACTIVO o FINALIZADO)
    bool isActive = status == 'ACTIVO';
    Color statusColor = isActive ? Colors.pink : Colors.green;
    IconData statusIcon = isActive ? Icons.toggle_on : Icons.toggle_off;

    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Evento de salud $event',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: statusColor),
                    ),
                    Icon(statusIcon, color: statusColor, size: 20),
                  ],
                ),
              ],
            ),
            Text('Lugar de captación: $lugarCaptacion'),
            Text('SILAIS: $silais'),
            Text('Unidad de captación: $unidad'),
            Text('Fecha de captación: $fecha'),
          ],
        ),
      ),
    );
  }
}

// Helper widget para mostrar la información del paciente
class _PatientInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PatientInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
