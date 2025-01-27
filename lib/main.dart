// main.dart
import 'package:flutter/material.dart';
import 'views/main_menu.dart'; //
import 'package:provider/provider.dart';
import 'states/bluetooth_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Proveedor para BluetoothManager
        ChangeNotifierProvider(
          create: (_) => BluetoothManager(), // No requiere argumentos
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainMenu(), // La pantalla principal
    );
  }
}