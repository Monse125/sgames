import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:sgames/providers/bluetooth_manager.dart';
import '../../providers/gamesSettings/resistance_settings_provider.dart';
import '../../providers/gamesSettings/settings/resistance_game_settings.dart';
import 'resistencia_game.dart';

class ResistanceGameScreen extends StatefulWidget {


  const ResistanceGameScreen({super.key,});

  @override
  _ResistanceGameScreenState createState() => _ResistanceGameScreenState();
}

class _ResistanceGameScreenState extends State<ResistanceGameScreen> {
  late ResistanceGameSettings gameSettings;
  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    final gameSettingsProvider = Provider.of<ResistanceSettingsProvider>(context, listen: false);
    gameSettings = gameSettingsProvider.settings;

    return Scaffold(
      body: GameWidget(
        game: ResistanceGame(
          bluetoothManager: bluetoothManager,
          maxForce: gameSettings.maxForce,
          lowerBound: gameSettings.lowerBound,
          upperBound: gameSettings.upperBound,
          amountReps: gameSettings.amountReps,
          lenghtRep: gameSettings.lengthRep,
          lenghtRest: gameSettings.lengthRest,
          setRest: gameSettings.lengthRestSet,
          amountSets: gameSettings.amountSets,
        ),
      ),
    );
  }
}