// lib/features/login/Login.dart

import 'package:flutter/material.dart';
import 'package:siven_app/widgets/version.dart'; // Importa el widget reutilizable
import 'package:siven_app/core/network/auth_repository.dart'; 
import 'package:siven_app/core/network/api_client.dart'; 
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Importa url_launcher
import 'package:siven_app/core/services/storage_service.dart'; // Importa StorageService
import 'package:bcrypt/bcrypt.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores y variables de estado
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showPassword = false;
  bool _isLoading = false; // Para manejar el estado de carga
  String _greetingMessage = '';

  // Inicializamos AuthRepository con ApiClient
  final AuthRepository _authRepository =
      AuthRepository(apiClient: ApiClient(httpClient: http.Client()));

  // Instancia de StorageService
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Detectar cuando el campo de contraseña obtiene el foco
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && _usernameController.text.isNotEmpty) {
        setState(() {
          _greetingMessage = '¡Hola, ${_usernameController.text}!';
        });
      } else {
        setState(() {
          _greetingMessage = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Verifica si hay conexión a Internet
  Future<bool> hayConexion() async {
    // Utiliza Connectivity para verificar la conexión
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Verifica las credenciales en modo offline
  Future<bool> verificarUsuarioOffline(String username, String password) async {
    final storedUsername = await _storageService.getUser();
    final storedPasswordHash = await _storageService.getPasswordHash();

    if (storedUsername == null || storedPasswordHash == null) {
      return false; // No hay datos guardados
    }

    // Verificar si el usuario y contraseña coinciden
    final passwordMatches = BCrypt.checkpw(password, storedPasswordHash);
    return storedUsername == username && passwordMatches;
  }

  // Maneja el inicio de sesión
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, rellene todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final tieneConexion = await hayConexion();
    if (tieneConexion) {
      // Login Online
      try {
        final response = await _authRepository.login(username, password);
        final token = response['token'];

        if (token != null && token.isNotEmpty) {
          // Guardar datos localmente
          await _storageService.saveToken(token);
          await _storageService.saveUser(username);
          await _storageService.savePasswordHash(password); // El hash se genera en el método

          // Navegar a la siguiente pantalla
          Navigator.pushNamed(context, '/red_servicio');
        } else {
          throw Exception('Token inválido');
        }
      } catch (e) {
        // Mostrar un mensaje de error si ocurre una excepción
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de autenticación: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Oculta el indicador de carga
        });
      }
    } else {
      // Login Offline
      final esValidoOffline = await verificarUsuarioOffline(username, password);
      if (esValidoOffline) {
        Navigator.pushNamed(context, '/red_servicio'); // Acceso offline
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciales Incorrectas')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Envía un mensaje de "Olvidé mi contraseña" vía WhatsApp
  Future<void> _sendForgotPasswordMessage() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa tu usuario primero')),
      );
      return;
    }

    final phoneNumber = '50558800062'; // Formato internacional sin símbolos
    final message = 'El usuario $username olvidó su contraseña.';

    // Construir las URLs
    final whatsappSchemeUrl = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');
    final whatsappWebUrl = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    // Intentar abrir con el esquema de WhatsApp
    if (await canLaunchUrl(whatsappSchemeUrl)) {
      await launchUrl(whatsappSchemeUrl, mode: LaunchMode.externalApplication);
    }
    // Si falla, intentar abrir en el navegador
    else if (await canLaunchUrl(whatsappWebUrl)) {
      await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
    }
    // Si ambas fallan, mostrar un mensaje de error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/SIVEN-SD.webp',
                        height: 82,
                      ),
                      SizedBox(height: 20),
                      if (_greetingMessage.isNotEmpty)
                        Text(
                          _greetingMessage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 77, 160, 255),
                          ),
                        ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        controller: _usernameController,
                        icon: Icons.person,
                        hintText: 'Ingresa tu usuario',
                        focusNode: _usernameFocusNode,
                      ),
                      SizedBox(height: 20),
                      buildCustomTextField(
                        controller: _passwordController,
                        icon: Icons.lock,
                        hintText: 'Ingresa tu contraseña',
                        obscureText: !_showPassword,
                        focusNode: _passwordFocusNode,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _sendForgotPasswordMessage,
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 255, 27, 27)),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _isLoading
                          ? CircularProgressIndicator(
                              color: const Color.fromARGB(255, 69, 156, 255),
                            )
                          : ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 69, 156, 255),
                                foregroundColor: Colors.white,
                                minimumSize: Size(290, 50), // Botón más corto
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                              ),
                              child: Text('SIGUIENTE'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VersionWidget(), 
        ],
      ),
    );
  }

  Widget buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0), // Redondeado para todo el contenedor
        border: Border.all(
          color: const Color.fromARGB(255, 77, 160, 255), // Color del borde
          width: 2.0, // Ancho del borde
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50, // Ajustar el ancho del icono
            height: 60, // Mantener el mismo alto que el TextField
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 73, 158, 255), // Fondo del icono
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), // Igualar el redondeado del contenedor principal
                bottomLeft: Radius.circular(10), // Igualar el redondeado del contenedor principal
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: suffixIcon, // Icono de visibilidad
                contentPadding:
                    EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12), // Asegura el redondeado de las esquinas derechas
                    bottomRight: Radius.circular(12),
                  ),
                  borderSide:
                      BorderSide.none, // Sin bordes visibles dentro del TextField
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
