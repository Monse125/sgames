import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgames/games/resistencia/resistencia_game_screen.dart';
import 'package:flutter/services.dart';
import 'package:sgames/providers/bluetooth_manager.dart';
import 'package:sgames/providers/gamesSettings/resistance_settings_provider.dart';
import 'package:sgames/views/mvc_meusure.dart';
import '../../providers/gamesSettings/settings/resistance_game_settings.dart';


class ResistenciaSetMenu extends StatefulWidget {
  const ResistenciaSetMenu({super.key});

  @override
  _ResistenciaSetMenuState createState() => _ResistenciaSetMenuState();
}

class _ResistenciaSetMenuState extends State<ResistenciaSetMenu> {
  late ResistanceGameSettings settings;
  //TextStyles repetidos
  TextStyle titulosCard = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    // Fuerza la orientación vertical al entrar a este menú
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final gameSettingsProvider = Provider.of<ResistanceSettingsProvider>(context, listen: false);
    settings = gameSettingsProvider.settings;
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tutorial de Resistencia"),
          content: Text(
            "Haz fuerza en el Tindeq Progressor para moverte de lado a lado y evitar chocar con las paredes. :D",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _measureMaxForce() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MVCMeasure(
          miniJuegoId: "resistencia",
          onMaxForceSaved: (maxForce) {
            Provider.of<ResistanceSettingsProvider>(context, listen: false)
                .setMaxForce(maxForce);
            // Volver a ResistenciaSetMenu después de guardar el valor
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ResistenciaSetMenu()),
            );
          },
          onExit: () {
            final bluetoothManager =
            Provider.of<BluetoothManager>(context, listen: false);
            final device = bluetoothManager.connectedDevice;
            if (device != null) {
              bluetoothManager.stopReceivingMeasurements(device);
            }
            // Asegurar que se vuelve a ResistenciaSetMenu si se sale sin guardar
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ResistenciaSetMenu()),
            );
          },
        ),
      ),
    );
  }

  void _modifyInterval(bool isLower) {
    int currentValue = isLower ? settings.lowerBound : settings.upperBound;

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: currentValue.toString());
        return AlertDialog(
          title: Text("Modificar valor"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Ingresa un número entre 0 y 100",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                int? newValue = int.tryParse(controller.text);
                if (newValue != null && newValue >= 0 && newValue <= 100) {
                  setState(() {
                    if (isLower) {
                      settings.lowerBound = newValue;
                    } else {
                      settings.upperBound = newValue;
                    }
                  });
                  Navigator.pop(context);
                } else {
                  // Mostrar error si el valor es inválido
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Ingresa un número válido entre 0 y 100.")),
                  );
                }
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _showPicker(BuildContext context, int min, int max, int currentValue, Function(int) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text("Selecciona un valor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: currentValue - min),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    onSelected(index + min);
                  },
                  children: List.generate(max - min + 1, (index) => Text("${index + min}", style: TextStyle(fontSize: 24))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  //Metodo para iniciar el juego al apretar botón "jugar"
  void _playGame() {
    // Asegurar que la conexión Bluetooth sigue activa antes de jugar
    Provider.of<BluetoothManager>(context, listen: false).keepConnectionAlive();


    // Navegar al juego
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResistanceGameScreen()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Resistencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Botón de tutorial
              ElevatedButton(
                onPressed: _showTutorial,
                child: Text("Tutorial", style: TextStyle(
                    fontSize: 30 ),),
              ),
              SizedBox(width: 20),
                // Botón de jugar
                ElevatedButton(
                  onPressed: _playGame,
                  child: Text(" Jugar ",style: TextStyle(
                      fontSize: 30 )),
                ),
            ],),

            SizedBox(height: 10),

            // Contenedor de configuración
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                height: 600, // Altura máxima fija para la tarjeta
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fuerza máxima", style: titulosCard),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "${settings.maxForce} kg",
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    settings.maxForce = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _measureMaxForce,
                              child: Text("Medir", style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                        Text("Intervalo de interés", style: titulosCard),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _intervalButton(settings.lowerBound, true),
                            SizedBox(width: 10),
                            Text("-", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            _intervalButton(settings.upperBound, false),
                          ],
                        ),
                        SizedBox(height: 20),
                        _configOption("Repeticiones", settings.amountReps, 1, 20, (val) => setState(() => settings.amountReps = val)),
                        _configOption("Duración Repetición (s)", settings.lengthRep, 1, 60, (val) => setState(() => settings.lengthRep = val)),
                        _configOption("Duración Descanso (s)", settings.lengthRest, 1, 60, (val) => setState(() => settings.lengthRest = val)),
                        SizedBox(height: 20),
                        Text("Configuración de sets", style: titulosCard),
                        _configOption("Sets", settings.amountSets, 1, 10, (val) => setState(() => settings.amountSets = val)),
                        _configOption("Duración Descanso Set (s)", settings.lengthRestSet, 10, 60, (val) => setState(() => settings.lengthRestSet = val)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),


          ],
        ),
      ),
    );
  }

  Widget _configOption(String label, int value, int min, int max, Function(int) onSelected) {
    return GestureDetector(
      onTap: () => _showPicker(context, min, max, value, onSelected),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 18)),
            Text("$value", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


  Widget _intervalButton(int value, bool isLower) {
    return GestureDetector(
      onTap: () => _modifyInterval(isLower),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text("$value%", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}