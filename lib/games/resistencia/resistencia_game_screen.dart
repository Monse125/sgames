import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:sgames/states/bluetooth_manager.dart';
import 'resistencia_game.dart';

class ResistanceGameScreen extends StatefulWidget {
  final double maxForce;
  final int lowerBound;
  final int upperBound;
  final int amountReps;
  final int lenghtRep;
  final int lenghtRest;

  ResistanceGameScreen({
    required this.maxForce,
    required this.lowerBound,
    required this.upperBound,
    required this.amountReps,
    required this.lenghtRep,
    required this.lenghtRest,
  });

  @override
  _ResistanceGameScreenState createState() => _ResistanceGameScreenState();
}

class _ResistanceGameScreenState extends State<ResistanceGameScreen> {


  @override
  Widget build(BuildContext context) {
    // Obtener el BluetoothManager desde Provider
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);

    return Scaffold(
      body: GameWidget(
        game: ResistanceGame(
          bluetoothManager: bluetoothManager,
          maxForce: widget.maxForce,
          lowerBound: widget.lowerBound,
          upperBound: widget.upperBound,
          amountReps: widget.amountReps,
          lenghtRep: widget.lenghtRep,
          lenghtRest: widget.lenghtRest,

        ),
      ),
    );
  }
}
