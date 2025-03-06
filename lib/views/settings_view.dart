import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_manager.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Dispositivo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            bluetoothManager.connectedDevice != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${bluetoothManager.deviceName()}"',
                    style: const TextStyle(fontSize: 18)),
                Text('Batería: --- No implementado --"',
                    style: const TextStyle(fontSize: 18)),
              ],
            )
                : const Text(
              'No hay un dispositivo Progressor conectado',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
