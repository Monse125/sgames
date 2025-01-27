import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sgames/controllers/bluetooth_conector.dart';

class BluetoothManager with ChangeNotifier {

  final BluetoothConnector _bluetoothConnector = BluetoothConnector();
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  double? currentWeight;

  // Callback para notificaciones de peso
  BluetoothManager() {
    _bluetoothConnector.onWeightChanged = (double weight) {
      currentWeight = weight;
      notifyListeners();
    };
  }

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;

  // Escanear dispositivos Bluetooth
  Future<List<BluetoothDevice>> startScan() async {
    _isScanning = true;
    List<BluetoothDevice> devices = await _bluetoothConnector.startScanning();
    _isScanning = false;
    return  devices;
  }

  // Detener el escaneo
  Future<void> stopScan() async {
    _isScanning = false;
    _bluetoothConnector.stopScanning();
  }

  // Conectar a un dispositivo
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await _bluetoothConnector.connectToDevice(device);
      _connectedDevice = device;
      notifyListeners();
    } catch (e) {
      print("Error al conectar al dispositivo: $e");
      rethrow;
    }
  }

  // Desconectar del dispositivo
  Future<void> disconnectFromDevice() async {
    if (_connectedDevice == null) {
      print("No hay un dispositivo conectado.");
      return;
    }

    try {
      await _bluetoothConnector.disconnectFromDevice(_connectedDevice!);
      _connectedDevice = null;
      currentWeight = null;
      notifyListeners();
    } catch (e) {
      print("Error al desconectar del dispositivo: $e");
      rethrow;
    }
  }

  // Inicia la recepción de mediciones
  Future<void> startReceivingMeasurements() async {
    if (_connectedDevice == null) return;
    await _bluetoothConnector.startWeightMeasurement();
  }

  // Detiene la recepción de mediciones
  Future<void> stopReceivingMeasurements(BluetoothDevice device) async {
    await _bluetoothConnector.stopWeightMeasurement();
  }

  // Envía el comando para establecer tare
  Future<void> setTare() async {
    if (_connectedDevice == null) {
      throw Exception("No hay un dispositivo conectado para establecer Tare.");
    }

    try {
      await _bluetoothConnector.setTare();
      notifyListeners(); // Notificar cambios si es necesario
    } catch (e) {
      print("Error en el manager al establecer Tare: $e");
      rethrow;
    }
  }

  Future<void> keepConnectionAlive() async {
    if (connectedDevice == null) {
      await _bluetoothConnector.reconnectToLastDevice();  // Implementa esto para mantener la conexión
    }
  }
}