// lib/widgets/search_persona_widget.dart

import 'package:flutter/material.dart';
import 'package:siven_app/core/services/PersonaService.dart';
import 'package:siven_app/core/services/http_service.dart';
import 'package:http/http.dart' as http; // Añadir esta línea

class SearchPersonaWidget extends StatefulWidget {
  final Function(int) onPersonaSelected; // Callback para retornar el ID seleccionado

  const SearchPersonaWidget({Key? key, required this.onPersonaSelected}) : super(key: key);

  @override
  _SearchPersonaWidgetState createState() => _SearchPersonaWidgetState();
}

class _SearchPersonaWidgetState extends State<SearchPersonaWidget> {
  final TextEditingController _personaController = TextEditingController();
  int? _selectedPersonaId;
  late PersonaService _personaService;

  @override
  void initState() {
    super.initState();
    // Inicializar PersonaService con HttpService
    _personaService = PersonaService(
      httpService: HttpService(httpClient: http.Client()), // Pasar httpClient
    );
  }

  @override
  void dispose() {
    _personaController.dispose();
    _personaService.close(); // Cerrar el servicio para evitar fugas
    super.dispose();
  }

  // Función para abrir el diálogo de búsqueda
  Future<void> _openSearchDialog() async {
    final selectedPersona = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const PersonaSearchDialog();
      },
    );

    if (selectedPersona != null) {
      setState(() {
        _personaController.text = selectedPersona['nombreCompleto'] ?? '';
        _selectedPersonaId = selectedPersona['id_persona'];
      });

      // Llamar al callback con el ID seleccionado
      widget.onPersonaSelected(_selectedPersonaId!);

      // Imprimir el ID en la terminal
      print('ID seleccionado Persona que Captó: $_selectedPersonaId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Persona que Captó *',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _openSearchDialog,
          child: AbsorbPointer(
            child: TextFormField(
              controller: _personaController,
              decoration: InputDecoration(
                hintText: 'Selecciona la persona que captó',
                prefixIcon: const Icon(Icons.person, color: Color(0xFF00C1D4)),
                suffixIcon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonaSearchDialog extends StatefulWidget {
  const PersonaSearchDialog({Key? key}) : super(key: key);

  @override
  _PersonaSearchDialogState createState() => _PersonaSearchDialogState();
}

class _PersonaSearchDialogState extends State<PersonaSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _resultados = [];
  bool _isLoading = false;
  late PersonaService _personaService;

  @override
  void initState() {
    super.initState();
    _personaService = PersonaService(
      httpService: HttpService(httpClient: http.Client()), // Pasar httpClient
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _personaService.close(); // Cerrar el servicio
    super.dispose();
  }

  // Función para buscar personas
  Future<void> _buscarPersonas(String query) async {
    if (query.isEmpty) {
      setState(() {
        _resultados = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> resultados = await _personaService.buscarPersonasPorNombreOApellido(query);
      setState(() {
        _resultados = resultados;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al buscar personas: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al buscar personas.')),
      );
    }
  }

  // Función para seleccionar una persona
  void _seleccionarPersona(Map<String, dynamic> persona) {
    int idPersona = persona['id_persona'];
    String nombreCompleto = '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
        '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'.trim();

    print('Persona seleccionada ID: $idPersona');

    Navigator.pop(context, {
      'id_persona': idPersona,
      'nombreCompleto': nombreCompleto,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _buscarPersonas,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o apellido',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00C1D4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xFF00C1D4)),
                  ),
                ),
              ),
            ),
            // Lista de resultados
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _resultados.isEmpty
                      ? const Center(child: Text('No hay resultados'))
                      : ListView.builder(
                          itemCount: _resultados.length,
                          itemBuilder: (context, index) {
                            final persona = _resultados[index];
                            String nombreCompleto = '${persona['primer_nombre'] ?? ''} ${persona['segundo_nombre'] ?? ''} '
                                '${persona['primer_apellido'] ?? ''} ${persona['segundo_apellido'] ?? ''}'.trim();
                            return ListTile(
                              leading: const Icon(Icons.person, color: Color(0xFF00C1D4)),
                              title: Text(nombreCompleto.isNotEmpty ? nombreCompleto : 'Sin nombre'),
                              subtitle: Text('ID: ${persona['id_persona']}'),
                              onTap: () => _seleccionarPersona(persona),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
