import 'package:flutter/material.dart';
import 'features/gestionJornadas/gestion_jornadas.dart';
import 'features/login/Login.dart';
import 'features/home/Home.dart';
import 'features/red_de_servicio_screen.dart';
import 'features/search/search_screen.dart';
import 'features/search/ResultadosBusquedaScreen.dart';
import 'features/Notificationsearch/alerta_temprana.dart';
import 'features/captacion/captacion_busqueda_persona.dart';
import 'features/captacion/buscar_por_nombre.dart';
import 'features/captacion/captacion_resultado_busqueda.dart';
import 'features/captacion/inf_dt_paciente_captacion.dart';
import 'features/captacion/Captacion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIVEN App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => Home(),
        '/FiltrarReporte': (context) => SearchScreen(),
        '/red_servicio': (context) => RedDeServicioScreen(),
        '/alerta_temprana': (context) => AlertaTemprana(),
        '/captacion_busqeda_persona': (context) => CaptacionBusquedaPersona(),
        '/captacion_busqueda_por_nombre': (context) =>
            BusquedaPorNombreScreen(),
        '/captacion_resultado_busqueda': (context) =>
            CaptacionResultadoBusqueda(),
        '/captacion_inf_paciente': (context) => InfoDtPacienteCaptacion(),
        '/captacion': (context) => Captacion(),
        '/gestion_jornadas': (context) => GestionJornadas(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/resultados_busqueda') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return ResultadosBusquedaScreen(
                silais: args['silais'],
                unidadSalud: args['unidadSalud'],
                evento: args['evento'],
                fechaInicio: args['fechaInicio'],
                fechaFin: args['fechaFin'],
              );
            },
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Ruta no encontrada: ${settings.name}'),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
