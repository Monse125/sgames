import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sgames/providers/bluetooth_manager.dart';

class BluetoothPopup extends StatefulWidget {
  const BluetoothPopup({super.key});

  @override
  State<BluetoothPopup> createState() => _BluetoothPopupState();
}

class _BluetoothPopupState extends State<BluetoothPopup> {
  bool hasError = false;
  String errorMessage = '';
  List devices = [];

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    final connectedDevice = bluetoothManager.connectedDevice;

    // Iniciar escaneo de dispositivos
    Future<void> startScan() async {
      setState(() {
        devices.clear();
        hasError = false;
      });
      try {
        List<BluetoothDevice> foundDevices = await bluetoothManager.startScan();
        setState(() {
          devices = foundDevices;
        });
      } catch (e) {
        setState(() {
          hasError = true;
          errorMessage = "Error al escanear: $e";
        });
      }
    }

    // Detener escaneo de dispositivos
    Future<void> stopScan() async {
      try {
        await bluetoothManager.stopScan();
      } catch (e) {
        setState(() {
          hasError = true;
          errorMessage = "Error al detener el escaneo: $e";
        });
      }
    }

    // Conectar a un dispositivo
    Future<void> connectDevice(device) async {
      try {
        await bluetoothManager.connectToDevice(device);
      } catch (e) {
        setState(() {
          hasError = true;
          errorMessage = "Error al conectar: $e";
        });
      }
    }

    // Desconectar del dispositivo
    Future<void> disconnectDevice() async {
      try {
        await bluetoothManager.disconnectFromDevice();
      } catch (e) {
        setState(() {
          hasError = true;
          errorMessage = "Error al desconectar: $e";
        });
      }
    }

    // Cerrar el popup correctamente
    void closePopup() {
      if (bluetoothManager.isScanning) {
        stopScan();
      }
      Navigator.of(context).pop();
    }

    return PopScope(
      canPop:  false, // Bloquea el botón de retroceso
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Conexión Bluetooth"),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: closePopup,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (connectedDevice != null) ...[
              const Text("Conectado a:"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(connectedDevice.platformName.isNotEmpty
                      ? connectedDevice.platformName
                      : 'Dispositivo desconocido'),
                ),
              ),
              ElevatedButton(
                onPressed: disconnectDevice,
                child: const Text("Desconectar"),
              ),
            ] else if (bluetoothManager.isScanning) ...[
              const Text("Buscando dispositivos..."),
              const CircularProgressIndicator(),
              ElevatedButton(
                onPressed: stopScan,
                child: const Text("Detener"),
              ),
            ] else if (hasError) ...[
              Text(errorMessage),
              ElevatedButton(
                onPressed: startScan,
                child: const Text("Intentar de nuevo"),
              ),
            ] else if (devices.isNotEmpty) ...[
              const Text("Dispositivos encontrados:"),
              ...devices.map((device) => ListTile(
                title: Text(device.platformName.isNotEmpty
                    ? device.platformName
                    : device.remoteId.toString()),
                onTap: () => connectDevice(device),
              )),
              ElevatedButton(
                onPressed: startScan,
                child: const Text("Reescanear"),
              ),
            ] else ...[
              const Text("Activa tu dispositivo y presiona Escanear."),
              ElevatedButton(
                onPressed: startScan,
                child: const Text("Escanear"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}