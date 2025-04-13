# 📌 SGames
SGames es un videojuego móvil diseñado para guiar y hacer más lúdico e interesante el entrenamiento y rehabilitación de pacientes, con patologías que afecten a las articulaciones, mediante ejercicios isométricos.

SGames plantea minijuegos con los que el usuario pueda entrenar la fuerza, buscando abarcar las siguientes componentes de esta: Fuerza, potencia, control, propiocepción y resistencia. Estos minijuegos serán diseñados para que el paciente pueda progresar en su entrenamiento, cambiando la dificultad según sus necesidades y condiciones.

SGames evaluará el desempeño del paciente en los minijuegos gracias al Tindeq Progressor, un dinamómetro inalámbrico validado para la medición del torque máximo en la extensión de rodilla isométrica con el estándar de referencia de un dinamómetro isocinético y una buena validez para identificar el índice de simetría de las extremidades. Este dispostivo es requisito para poder utilizar jugar con SGames.

## Guía Rapida

- [Instrucciones para Usuarios Finales](#-instrucciones---usuario-final)
- [Instrucciones para Desarrolladores](#-instrucciones---desarroladores)

## 📥 Instrucciones - Usuario Final

### ✅ Requisitos

Para jugar a SGames, necesitas los siguientes elementos:

- 📱 **Dispositivo móvil**: Un teléfono o tablet que posea conexión bluetooth.
- 🎮 **Tindeq Progressor**: Este dispositivo es **requisito obligatorio** para jugar.

### Instalación

#### 📌 Android:
1. Descarga la última versión de la aplicación en formato APK desde la sección de Releases.
2. Instala el archivo APK en tu dispositivo. Es posible que necesites habilitar la instalación desde orígenes desconocidos.

### 🎮 Cómo Jugar
1. Conéctate al Tindeq Progressor mediante Bluetooth.
2. Explora las interfaces principales y accede al primer minijuego: "Resistencia".
3. Sigue las indicaciones en pantalla para realizar los ejercicios correctamente.

### 🌟 Características
✔ Conexión con Tindeq Progressor.

✔ Interfaces principales implementadas.

✔ Primer minijuego: "Resistencia".

### 🛠 Solucion de Problemas

* **No se detecta el Tindeq Progressor:** Asegúrate de que el Bluetooth está activado y el dispositivo Progressor está encendido.
* **La conexión se interrumpe:** Ve a la interfaz de conexión bluetooth dentro de la aplicación, descontecta el dispositivo Tindeq Progressor y vuelve a conectarlo. Si el error continua reiniciar la aplicación.
* **Error en la instalación:** Verifica que has habilitado la instalación desde orígenes desconocidos en la configuración de tu teléfono.

## 📥 Instrucciones - Desarrolladores

### 📋 Requisitos

- **Flutter**: La plataforma de desarrollo móvil utilizada para crear la aplicación.
- **Dart SDK**: El lenguaje de programación utilizado en el desarrollo (incluido con Flutter).

- **Android Studio** (recomendado) o **Visual Studio Code** con las extensiones:

    - Flutter
    - Dart


### ⚙ Instalación

1. **Clona el repositorio desde Github:**
2. **Instala las dependencias:**
flutter pub get

3. **Conecta un dispoitivo físico** con Bluetooth habilitado para pruebas:
4. **Ejecuta la aplicación:**
flutter run


### 📁 Estructura del Proyecto
```
SGames/
├── lib/
│   ├── controllers/           # Lógica de controladores (Bluetooth).
│   ├── games/                 # Carpetas con logica de cada minijuego.
│   ├──   ├── resistencia/     # Objetos e implementación de minijuego "Resistencia".
│   ├── providers/             # Manejo de estados (Provider).
│   ├──   ├── gameSettings/    # Estados para los settings de los minijuegos.
│   ├──   ├──   ├── settings/  # Clases con los valores de los settings de los minijuegos.
│   ├── views/                 # Interfaces de usuario (UI).
│   ├──   ├── gameMenus/       # Menus para cada minijuego.
│   ├──   ├── popups/          # Popups.
│   ├── main.dart              # Punto de entrada de la app.
├── assets/                    # Imágenes y sonidos.
│   ├── images/                        
├── pubspec.yaml               # Dependencias y configuraciones
├── README.md

```
### 🚀 Instrucciones para Añadir Nuevos Minijuegos

Para agregar un nuevo minijuego a SGames, sigue estos pasos:

1. **Crea el menú del nuevo minijuego en la carpeta** `lib/view/gameMenus`:
    - En caso de necesitar guardar settings para el minijuego, crea el provider minijuego_settings_provider.dart en `lib/providers/gamesSettings` y una clase de atributos nombre_minijuego_game_settings.dart en `lib/providers/gamesSettings/settings`
2. **Actualiza** `lib/views/main_menu` para las rutas correspondientes al menu del nuevo minijuego.
3. **Crea una carpeta nueva en** `lib/games/`:
4. **Crea los archivos necesarios** (En caso de estar usando Flame para tu minijuego):
    - nombre_minijuego_game_screen.dart
    - nombre_minijuego_game.dart

    Si no usas Flame, de todas formas dividde la lógica entre controller y view.

5. **Define la lógica del minijuego**:
    - Implementa los controles y la lógica en el archivo game.
6. **Integra con el Tindeq Progressor**:
    - Utiliza los metodos en el `lib/providders/bluetooth_manager` o agrega los que necesites.
    - Para agregar metodos, debes considerar que bluetooth_manager llama metodos en `lib/controllers/bluetooth_conector`
    - Se espera que las views y juegos no interactuen directamente con `bluetooth_conector, sino con bluetooth_manager.
7. **Conecta el juego a su menu de minijuego para poder iniciarlo desde ahi** 

### 📦 Como Exportar el APK

Para generar el archivo APK de SGames:

#### 1. Cambia al modo release:
`flutter build apk --release`

#### 2. Encuentra el APK generado en: 
`build/app/outputs/flutter-apk/app-release.apk`


## 📫 Contacto

Si tienes preguntas o necesitas ayuda con la instalación o uso de SGames, puedes contactar con monserratmonterot@gmail.com.
