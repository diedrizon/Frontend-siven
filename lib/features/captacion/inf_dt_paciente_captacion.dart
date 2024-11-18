// lib/features/captacion/inf_dt_paciente_captacion.dart

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

class _InfoDtPacienteCaptacionState
    extends State<InfoDtPacienteCaptacion> {
  bool _showDatosPaciente = true; // Control de visibilidad
  bool _showDatosCaptacion = false; // Control de visibilidad

  // Lista de eventos de captación
  final List<Map<String, dynamic>> _eventosCaptacion = [
    {
      'id_evento_salud': 1,
      'nombre': 'Malaria',
      'status': 'ACTIVO',
      'lugarCaptacion': 'Domicilio',
      'silais': 'BOACO',
      'unidad': 'CAPS - BOACO',
      'fecha': '27/08/2024'
    },
    {
      'id_evento_salud': 2,
      'nombre': 'Malaria',
      'status': 'FINALIZADO',
      'lugarCaptacion': 'Domicilio',
      'silais': 'BOACO',
      'unidad': 'CAPS - BOACO',
      'fecha': '14/11/2023'
    },
    {
      'id_evento_salud': 3,
      'nombre': 'Dengue',
      'status': 'ACTIVO',
      'lugarCaptacion': 'Escuela',
      'silais': 'LEÓN',
      'unidad': 'CAPS - LEÓN',
      'fecha': '11/09/2024'
    },
    {
      'id_evento_salud': 4,
      'nombre': 'COVID-19',
      'status': 'FINALIZADO',
      'lugarCaptacion': 'Hospital',
      'silais': 'MANAGUA',
      'unidad': 'CAPS - MANAGUA',
      'fecha': '03/05/2024'
    },
    // Asegúrate de que todos los eventos tengan IDs únicos
  ];

  // Paginación
  int _currentPage = 0;
  final int _itemsPerPage = 2;

  // Servicios
  late CatalogServiceRedServicio catalogService;
  late SelectionStorageService selectionStorageService;
  late EventoSaludService eventoSaludService;

  // Datos de la persona
  Map<String, dynamic> persona = {};

  // Variables para IDs
  int? _idPersona;
  int? _idEventoSalud;

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
    eventoSaludService = EventoSaludService(httpService: httpService);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        persona = args;
        _idPersona = persona['id_persona'] as int?;
      });
      // Log de id_persona
      print('ID de persona recuperado: $_idPersona');
    } else {
      setState(() {
        persona = {};
        _idPersona = null;
      });
      print('No se encontraron datos de persona en los argumentos.');
    }
  }

  // Alternar tarjetas
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

  // Paginación de eventos
  List<Map<String, dynamic>> _getPaginatedEventos() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (start >= _eventosCaptacion.length) {
      return [];
    }
    return _eventosCaptacion.sublist(
        start, end.clamp(0, _eventosCaptacion.length));
  }

  // Cambio de página
  void _changePage(int direction) {
    setState(() {
      int maxPage =
          (_eventosCaptacion.length / _itemsPerPage).ceil() - 1;
      if (direction == -1 && _currentPage > 0) {
        _currentPage--;
      } else if (direction == 1 && _currentPage < maxPage) {
        _currentPage++;
      }
    });
  }

  // Diálogo para agregar captación
  void _showCaptacionDialog() async {
    List<Map<String, dynamic>> eventos = [];

    try {
      eventos = await eventoSaludService.listarEventosSalud();
    } catch (e) {
      print('Error al listar eventos de salud: $e');
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return _CaptacionDialog(eventos: eventos);
      },
    );

    if (result != null) {
      setState(() {
        _eventosCaptacion.add({
          'id_evento_salud': result['id_evento_salud'],
          'nombre': result['nombre'],
          'status': 'ACTIVO',
          'lugarCaptacion': 'Nuevo Lugar',
          'silais': 'Nuevo SILAIS',
          'unidad': 'Nueva Unidad',
          'fecha': 'Fecha Actual',
        });
        _idEventoSalud = result['id_evento_salud'];
      });

      // Log de id_evento_salud
      print('ID de evento de salud seleccionado: $_idEventoSalud');

      // Construir el nombre completo
      String nombreCompleto =
          '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
                  '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'
              .trim();

      // Navegar a '/captacion' con los argumentos necesarios
      Navigator.pushNamed(
        context,
        '/captacion',
        arguments: {
          'id_persona': _idPersona,
          'id_evento_salud': _idEventoSalud,
          'nombreCompleto': nombreCompleto,
        },
      );
    }
  }

  // Calcular edad
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
    List<Map<String, dynamic>> eventosPagina = _getPaginatedEventos();
    int totalRegistros = _eventosCaptacion.length;
    int paginaInicio = _currentPage * _itemsPerPage + 1;
    int paginaFin = (_currentPage * _itemsPerPage + eventosPagina.length)
        .clamp(0, totalRegistros);

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
                '/captacion_resultado_busqueda',
              );
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
                  // Filas con botones adicionales
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

                  // Nombre del paciente
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
                          color: Color(0xFF00C1D4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta 1: Datos del paciente
                  _DatosPacienteCard(
                    persona: persona,
                    showDatos: _showDatosPaciente,
                    toggleCard: () => _toggleCard('paciente'),
                    calcularEdad: calcularEdad,
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta 2: Datos de captación
                  _DatosCaptacionCard(
                    eventosPagina: eventosPagina,
                    showDatos: _showDatosCaptacion,
                    toggleCard: () => _toggleCard('captacion'),
                    showCaptacionDialog: _showCaptacionDialog,
                    changePage: _changePage,
                    paginaInicio: paginaInicio,
                    paginaFin: paginaFin,
                    totalRegistros: totalRegistros,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          const VersionWidget(),
        ],
      ),
    );
  }
}

// Widget para la tarjeta de Datos del Paciente
class _DatosPacienteCard extends StatelessWidget {
  final Map<String, dynamic> persona;
  final bool showDatos;
  final VoidCallback toggleCard;
  final String? Function(String?) calcularEdad;

  const _DatosPacienteCard({
    required this.persona,
    required this.showDatos,
    required this.toggleCard,
    required this.calcularEdad,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggleCard,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
              color: Color(0xFF00C1D4), width: 1),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Número en cuadro
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
                          color: Color(0xFF00C1D4)),
                    ],
                  ),
                ],
              ),
              if (showDatos) ...[
                const SizedBox(height: 10),
                // Información del paciente
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
                            value: persona['tipo_sangre']
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
    );
  }
}

// Widget para la tarjeta de Datos de Captación
class _DatosCaptacionCard extends StatelessWidget {
  final List<Map<String, dynamic>> eventosPagina;
  final bool showDatos;
  final VoidCallback toggleCard;
  final VoidCallback showCaptacionDialog;
  final Function(int) changePage;
  final int paginaInicio;
  final int paginaFin;
  final int totalRegistros;

  const _DatosCaptacionCard({
    required this.eventosPagina,
    required this.showDatos,
    required this.toggleCard,
    required this.showCaptacionDialog,
    required this.changePage,
    required this.paginaInicio,
    required this.paginaFin,
    required this.totalRegistros,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggleCard,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
              color: Color(0xFF00C1D4), width: 1),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Número en cuadro
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
                    onPressed: showCaptacionDialog,
                  ),
                ],
              ),
              if (showDatos) ...[
                const SizedBox(height: 10),
                // Mostrar eventos paginados
                for (var evento in eventosPagina)
                  _EventCard(
                    event: evento['nombre'],
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
                    // Botón retroceder
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF00C1D4)),
                      onPressed: () => changePage(-1),
                    ),
                    // Texto de paginado
                    Text(
                      '$paginaInicio-$paginaFin de $totalRegistros Registros encontrados',
                      style:
                          const TextStyle(color: Colors.black54),
                    ),
                    // Botón avanzar
                    IconButton(
                      icon: const Icon(Icons.arrow_forward,
                          color: Color(0xFF00C1D4)),
                      onPressed: () => changePage(1),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Diálogo personalizado para captación
class _CaptacionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> eventos;

  const _CaptacionDialog({required this.eventos});

  @override
  __CaptacionDialogState createState() => __CaptacionDialogState();
}

class __CaptacionDialogState extends State<_CaptacionDialog> {
  int? selectedEventoId;
  String? selectedEventoNombre;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
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
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Seleccionar evento de salud *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            items: widget.eventos.map((evento) {
              return DropdownMenuItem<int>(
                value: evento['id_evento_salud'],
                child: Text(evento['nombre']),
              );
            }).toList(),
            value: selectedEventoId,
            onChanged: (int? value) {
              setState(() {
                selectedEventoId = value;
                selectedEventoNombre = widget.eventos
                    .firstWhere((evento) => evento['id_evento_salud'] == value)['nombre'];
              });
            },
          ),
          const SizedBox(height: 20),
        ],
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
                style:
                    TextStyle(fontSize: 16, color: Color(0xFF00C1D4)),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedEventoId != null &&
                    selectedEventoNombre != null) {
                  Navigator.pop(context, {
                    'id_evento_salud': selectedEventoId,
                    'nombre': selectedEventoNombre,
                  });
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
                style:
                    TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Tarjeta interna para los eventos de salud
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
            // Encabezado del evento
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

// Widget auxiliar para mostrar información del paciente
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
