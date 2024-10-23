# SIVEN

SIVEN es una aplicación desarrollada en Flutter que sigue una arquitectura Cliente-Servidor.

## Comenzando

Estas instrucciones te proporcionarán los pasos necesarios para ejecutar una copia del proyecto en tu máquina local para fines de desarrollo y pruebas.

### Prerrequisitos

Asegúrate de tener instalado Flutter. Puedes verificar si lo tienes instalado correctamente y cuál es la versión ejecutando:

### Abre la terminal y ejecuta los siguientes comandos
- flutter --version
- flutter doctor


### Estructura del proyecto

lib/
├── core/                      # Código central que es compartido por varias partes de la aplicación
│   ├── api/                   # Servicios relacionados con las llamadas a la API
│   │   ├── api_service.dart   # Lógica para realizar llamadas HTTP a la API del servidor
│   │   ├── interceptor.dart   # Manejo de interceptores, como la autenticación
│   │   └── endpoints.dart     # Definición de los endpoints del servidor
│   ├── models/                # Modelos de datos que reflejan las respuestas de la API
│   │   └── user_model.dart    # Modelo de datos para los usuarios
│   ├── utils/                 # Utilidades y constantes generales
│   │   ├── constants.dart     # Definición de constantes globales
│   │   ├── helpers.dart       # Funciones auxiliares (helpers)
│   │   └── validators.dart    # Validadores comunes para formularios, por ejemplo, validación de correos
│   ├── theme/                 # Gestión de temas y estilos
│   │   └── app_theme.dart     # Definición del tema de la aplicación, colores, tipografías, etc.
│   └── config/                # Configuración de entornos y parámetros globales
│       └── environment.dart   # Configuraciones de entornos (desarrollo, producción)
├── features/                  # Módulos individuales de la aplicación divididos por funcionalidades
│   ├── home/                  # Funcionalidades relacionadas con la pantalla de inicio
│   │   ├── pages/             # Páginas visuales para la característica de inicio
│   │   │   └── home_page.dart # Página principal del inicio
│   │   ├── controllers/       # Controladores que manejan la lógica del inicio
│   │   │   └── home_controller.dart  # Lógica de negocios para la pantalla principal
│   │   └── widgets/           # Componentes visuales específicos de la pantalla de inicio
│   │       └── home_widget.dart  # Widgets reutilizables de la página principal
│   ├── login/                 # Módulo de autenticación y manejo de inicio de sesión
│   │   ├── pages/             # Páginas visuales para el inicio de sesión
│   │   │   └── login_page.dart   # Página de inicio de sesión
│   │   ├── controllers/       # Controladores para la lógica de la autenticación
│   │   │   └── login_controller.dart # Lógica para la autenticación de usuarios
│   │   └── widgets/           # Widgets relacionados con el login
│   │       └── login_form.dart # Formulario de inicio de sesión
├── widgets/                   # Widgets reutilizables en varias partes de la aplicación
│   └── common_button.dart     # Botón reutilizable en diferentes pantallas
├── main.dart                  # Punto de entrada principal de la aplicación

###Arquitectura Cliente-Servidor
SIVEN sigue una arquitectura Cliente-Servidor, donde:

Cliente (Aplicación Flutter):

La aplicación Flutter (cliente) interactúa con un servidor remoto a través de una API REST, utilizando las clases y servicios definidos en lib/core/api/.

El cliente es responsable de manejar la interfaz de usuario y de realizar las llamadas a la API para obtener o enviar datos al servidor. Estas llamadas se realizan en api_service.dart.

Los controladores en lib/features/ manejan la lógica de la aplicación y orquestan las solicitudes al servidor para cargar o actualizar los datos.
Servidor (API):

El servidor maneja la lógica de negocio y el almacenamiento de datos. Responde a las solicitudes enviadas desde el cliente a los endpoints definidos en endpoints.dart.

El servidor procesa las solicitudes (por ejemplo, para autenticación o recuperación de datos) y devuelve los datos al cliente en formato JSON, que luego son utilizados por la aplicación para actualizar la UI o ejecutar lógica de negocio.
