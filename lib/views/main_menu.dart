import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sgames/states/bluetooth_manager.dart';
import 'popups/bluetooth_popup.dart';
import 'popups/tare_popup.dart';
import 'package:flutter/services.dart';
// Archivo con AppBluetoothState
import 'gamesMenus/resistencia_set_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Fuerza orientación vertical al entrar en el menú
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    double widthButton = MediaQuery.of(context).size.width - 80;

    return Scaffold( // Asegúrate de usar Scaffold aquí
      backgroundColor: Colors.red[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'SGames',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      fontSize: 70,
                    ),
                  )
                ],
              ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  circButton(FontAwesomeIcons.gear, context),
                  SizedBox(width: 30),
                  circButton(FontAwesomeIcons.bluetooth, context),
                  SizedBox(width: 30),
                  circButton(FontAwesomeIcons.weightHanging, context),
                ],
              ),
              Wrap(
                runSpacing: 16,
                children: [
                  modeButton('Fuerza', Colors.orangeAccent, widthButton),
                  modeButton('Resistencia', Colors.orangeAccent, widthButton,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResistenciaSetMenu()),
                        );
                      }),
                  SizedBox(height: 400)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding circButton(IconData icon, BuildContext context) {
    // Usamos BluetoothManager en lugar de AppBluetoothState
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: RawMaterialButton(
        onPressed: () {
          if (icon == FontAwesomeIcons.bluetooth) {
            // Muestra el popup Bluetooth.
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const BluetoothPopup();
              },
            );
          }
          if (icon == FontAwesomeIcons.weightHanging) {
            // Verifica si hay un dispositivo conectado
            if (bluetoothManager.connectedDevice != null) {
              // Muestra el popup de tare
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return TarePopup();
                },
              );
            } else {
              // Muestra una alerta si no hay dispositivo conectado
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("¡No hay un dispositivo conectado!"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        fillColor: Colors.white,
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 55, minWidth: 55),
        child: FaIcon(
          icon,
          size: 45,
          color: Colors.deepOrangeAccent,
        ),
      ),
    );
  }

  GestureDetector modeButton(String title, Color color, double width,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 37,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


