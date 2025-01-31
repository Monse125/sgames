// main.dart
import 'package:flutter/material.dart';
import 'package:sgames/providers/gamesSettings/resistance_settings_provider.dart';
import 'views/main_menu.dart'; //
import 'package:provider/provider.dart';
import 'providers/bluetooth_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => BluetoothManager()),
        ChangeNotifierProvider(
            create: (_) => ResistanceSettingsProvider()),
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