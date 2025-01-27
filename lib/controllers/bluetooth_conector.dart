import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

// Progressor response codes
const int RES_WEIGHT_MEAS = 1;
const int RES_RFD_PEAK = 2;
const int RES_RFD_PEAK_SERIES = 3;
const int RES_LOW_PWR_WARNING = 4;

//Progressor Commands
const CMD_START_WEIGHT_MEAS = 101;
const CMD_ENTER_SLEEP = 110;

// Progressors UUIDS
String progressorService = "7e4e1701-1ea6-40c9-9dcc-13d34ffead57";
String data = "7e4e1702-1ea6-40c9-9dcc-13d34ffead57";
String controlPoint = "7e4e1703-1ea6-40c9-9dcc-13d34ffead57";


class BluetoothConnector {
  bool isScanning = false;
  String? lastDeviceId;

  BluetoothCharacteristic? controlPointCharacteristic;
  BluetoothCharacteristic? dataPointCharacteristic;

  // Callback para datos en tiempo real
  Function(double)? onWeightChanged;
  StreamSubscription? _weightStreamSubscription;

  // Solicitar permisos Bluetooth
  Future<void> requestPermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();

    if (statuses.values.any((status) => status != PermissionStatus.granted)) {
      throw Exception("No se otorgaron los permisos necesarios.");
    }
  }

  // Escaneo de dispositivos BLE
  // Inicia el escaneo y espera a que se complete
  Future<List<BluetoothDevice>> startScanning() async {
    if (isScanning) {
      print("Ya hay un escaneo en curso. Por favor, espera.");
      return [];
    }

    isScanning = true; // Marcar que el escaneo ha comenzado
    await requestPermissions(); // Solicitar permisos antes de escanear
    List<BluetoothDevice> foundDevices = [];

    // Comenzamos el escaneo con un timeout mayor (15 segundos)
    print("Iniciando escaneo...");
    FlutterBluePlus.startScan(timeout: Duration(seconds: 15));

    // Usamos el stream para escuchar los resultados del escaneo
    FlutterBluePlus.scanResults.listen((results) {
      print("Escaneando...");

      // Filtrar dispositivos que coincidan con "Progressor"
      var progressorDevices = results.where((result) {
        return result.device.platformName.startsWith("Progressor");
      }).toList();

      // Evitar duplicados en la lista
      for (var device in progressorDevices) {
        if (!foundDevices.any((d) => d.remoteId == device.device.remoteId)) {
          foundDevices.add(device.device);
        }
      }
    });

    // Aseguramos que el escaneo se detenga después de 15 segundos
    await Future.delayed(Duration(seconds: 15));

    if (isScanning) {
      // Detenemos el escaneo manualmente después de 15 segundos
      FlutterBluePlus.stopScan();
      isScanning = false; // Restablecer el estado del escaneo
      print("Escaneo detenido automáticamente por timeout.");
    }

    // Imprimir los dispositivos encontrados
    print("Dispositivos encontrados: ");
    for (var device in foundDevices) {
      print(
          "Dispositivo: ${device.platformName}, Dirección: ${device.remoteId}");
    }

    // Retornar los dispositivos encontrados
    return foundDevices;
  }


  // Detener escaneo
  void stopScanning() {
    if (isScanning) {
      FlutterBluePlus.stopScan();
      isScanning = false;
      print("Escaneo detenido manualmente.");
    }
  }


  // Conexión al dispositivo
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await requestPermissions();

      if (!device.isConnected){
        await device.connect();
      }

      await _discoverServices(device);
      print("Conectado a ${device.platformName}");
    } catch (e) {
      print("Error al conectar: $e");
      rethrow;
    }
  }

  // Obtener el último dispositivo conectado
  Future<BluetoothDevice?> getLastConnectedDevice() async {
    if (lastDeviceId == null) return null;
    List<BluetoothDevice> connectedDevices =
    FlutterBluePlus.connectedDevices;

    for (var device in connectedDevices) {
      if (device.remoteId.toString() == lastDeviceId) {
        return device;
      }
    }
    return null;
  }

  // Reconectar al último dispositivo
  Future<void> reconnectToLastDevice() async {
    BluetoothDevice? lastDevice = await getLastConnectedDevice();
    if (lastDevice != null) {
      await connectToDevice(lastDevice);
    } else {
      print("No se encontró un dispositivo previo para reconectar.");
    }
  }

  // Descubrir servicios y características
  Future<void> _discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == controlPoint) {
          controlPointCharacteristic = characteristic;
        } else if (characteristic.uuid.toString() == data) {
          dataPointCharacteristic = characteristic;
        }
      }
    }

    if (controlPointCharacteristic == null || dataPointCharacteristic == null) {
      throw Exception("No se encontraron las características requeridas.");
    }
  }

  // Iniciar medición de peso
  Future<void> startWeightMeasurement() async {

    if (controlPointCharacteristic == null || dataPointCharacteristic == null) {
      throw Exception("Características no disponibles.");
    }
    await controlPointCharacteristic!.write([CMD_START_WEIGHT_MEAS, 0x00]);
    await dataPointCharacteristic!.setNotifyValue(true);
    _weightStreamSubscription = dataPointCharacteristic!.lastValueStream.listen(
          (data) {
            //print("Datos recibidos: $data");
            final weight = _extractWeightFromData(Uint8List.fromList(data));
            onWeightChanged?.call(weight);
      },
    );
  }

  // Extraer peso de los datos recibidos
  double _extractWeightFromData(Uint8List data) {
    if (data.length < 9) return 0.0; // 1 byte de código + 1 byte de longitud + 4 bytes de peso + 4 bytes de timestamp
    if (data[0] != 0x01) return 0.0; // Verifica que es un peso medido

    final byteData = ByteData.sublistView(data);
    double weight = byteData.getFloat32(2, Endian.little); // El peso comienza en el byte 2
    return weight < 0 ? 0.0 : weight;
  }


  // Detener medición de peso
  Future<void> stopWeightMeasurement() async {
    if (controlPointCharacteristic == null) return;

    try {
      await controlPointCharacteristic!.write([CMD_ENTER_SLEEP, 0x00]);
      await _weightStreamSubscription?.cancel();
      print("Medición detenida.");
    } catch (e) {
      print("Error al detener medición: $e");
      rethrow;
    }
  }

  // Desconectar del dispositivo
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await _weightStreamSubscription?.cancel();
      await device.disconnect();
      print("Desconectado de ${device.platformName}");
    } catch (e) {
      print("Error al desconectar: $e");
      rethrow;
    }
  }


  // Establecer Tare
  Future<void> setTare() async {
    if (controlPointCharacteristic == null) {
      throw Exception(
          "Características no disponibles para enviar el comando Tare.");
    }

    try {
      // Enviar comando para establecer Tare
      await controlPointCharacteristic!.write(
          [CMD_START_WEIGHT_MEAS, 0x01]); // Comando Tare
      print("Comando Tare enviado.");
    } catch (e) {
      print("Error al establecer Tare: $e");
      rethrow;
    }
  }
}