import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgames/states/bluetooth_manager.dart';

class TarePopup extends StatefulWidget {
  const TarePopup({super.key});

  @override
  _TarePopupState createState() => _TarePopupState();
}

class _TarePopupState extends State<TarePopup> {
  BluetoothManager? _bluetoothManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
      _bluetoothManager?.startReceivingMeasurements();
    });
  }

  @override
  void dispose() {
    final device = _bluetoothManager?.connectedDevice;
    if (device != null) {
      _bluetoothManager?.stopReceivingMeasurements(device);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothManager>(
      builder: (context, bluetoothManager, child) {
        double currentWeight = bluetoothManager.currentWeight ?? 0.0;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Calibración de Tare", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Peso actual:", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("${currentWeight.toStringAsFixed(2)} kg", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await bluetoothManager.setTare();
                        Navigator.of(context).pop();
                      },
                      child: Text("Establecer Tare"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}