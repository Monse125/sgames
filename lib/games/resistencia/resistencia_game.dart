import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sgames/states/bluetooth_manager.dart';
import 'dart:async' as async;

import '../../views/gamesMenus/resistencia_set_menu.dart';
import 'obstacle_pair.dart';


class ResistanceGame extends FlameGame with TapDetector {
  late SpriteComponent ball;
  late TextComponent countdownText;
  late TextComponent timerText;
  late TextComponent endText;

  final BluetoothManager bluetoothManager;
  final double maxForce;
  final int lowerBound;
  final int upperBound;
  final int amountReps;
  final int lenghtRep;
  final int lenghtRest;
  final int setRest;
  final int amountSets;

  double currentForce = 0;
  double elapsedTime = 0;
  bool gameStarted = false;
  int completedReps = 0;

  List<ObstaclePair> activeObstacles = [];
  int obstacleIdCounter = 0;

  bool showingRestText = false;
  int totalErrors = 0;


  ResistanceGame({
    required this.bluetoothManager,
    required this.maxForce,
    required this.lowerBound,
    required this.upperBound,
    required this.amountReps,
    required this.lenghtRep,
    required this.lenghtRest,
    required this.setRest,
    required this.amountSets,
  }); // Constructor

  @override
  Color backgroundColor() => Colors.deepPurpleAccent; // Fondo sólido (gris oscuro)

  @override
  Future<void> onLoad() async {

    // Cargar la pelota
    ball = SpriteComponent(
        sprite: await loadSprite("ball.png"),
      size: Vector2(50, 50),
      position: Vector2(
        size.x * ((currentForce / maxForce)),
        size.y * 7 / 9,
      ),
    );
    add(ball);

    // Contador de cuenta regresiva
    countdownText = TextComponent(
      text: "¡Prepárate!",
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 60, color: Colors.white),
      ),
    );
    add(countdownText);

    // Temporizador
    timerText = TextComponent(
      text: "0.00s",
      position: Vector2(size.x - 100, 20), // Esquina superior derecha
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
    add(timerText);

    endText = TextComponent(
      text: "",
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 60, color: Colors.white),
      ),
    );
    add(endText);

    startCountdown(); // Iniciar la cuenta regresiva

    // Iniciar la escucha del peso si hay un dispositivo conectado
    if (bluetoothManager.connectedDevice != null) {
      await bluetoothManager.startReceivingMeasurements( );
    }
  }

  void startCountdown() async {
    await Future.delayed(Duration(seconds: 2));
    for (int i = 3; i > 0; i--) {
      countdownText.text = "$i";
      await Future.delayed(Duration(seconds: 1));
    }
    countdownText.text = "¡Ya!";
    await Future.delayed(Duration(seconds: 1));
    countdownText.removeFromParent(); // Eliminar texto de la cuenta regresiva
    spawnObstacles();
    gameStarted = true; // Iniciar el juego
  }

  void spawnObstacles() {
    double screenWidth = size.x;
    double screenHeight = size.y;
    final double obstacleSpeed = screenHeight / lenghtRep;

    void startRep(int repIndex) {
      if (repIndex >= amountReps) {
        endGame();
        return;
      }

      double lowerX = (lowerBound / 100) * screenWidth;
      double upperX = (upperBound / 100) * screenWidth;

      // Crear y agregar un nuevo ObstaclePair
      final obstaclePair = ObstaclePair(
        id: obstacleIdCounter++,
        speed: obstacleSpeed,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        lowerX: lowerX,
        upperX: upperX,
      );

      obstaclePair.addToGame(this);
      activeObstacles.add(obstaclePair);

      completedReps++;

      // Iniciar la siguiente repetición después de `lenghtRep` segundos
      async.Timer(Duration(seconds: lenghtRep), () {
        if (completedReps < amountReps) {
          async.Timer(Duration(seconds: lenghtRest), () {
            startRep(completedReps);
          });
        }
      });
    }

    startRep(0); // Iniciar la primera repetición
  }

  void endGame() async {
    gameStarted = false;
    endText.text = "Fin!";
    totalErrors = activeObstacles.where((pair) => pair.wasError).length;

    await bluetoothManager.stopReceivingMeasurements(bluetoothManager.connectedDevice!);

    await Future.delayed(Duration(seconds: 2));
    endText.text ="Errores: $totalErrors";
    await Future.delayed(Duration(seconds: setRest - 2));

    goToMenu();
  }

  void goToMenu() {
    Navigator.pushReplacement(
      buildContext!,
      MaterialPageRoute(builder: (context) => ResistenciaSetMenu()),
    );
  }


  @override
  void update(double dt) {
    super.update(dt);

    if (gameStarted) {
      elapsedTime += dt;
      timerText.text = "${elapsedTime.toStringAsFixed(2)}s";
    }

    double? newWeight = bluetoothManager.currentWeight;
    if (newWeight != null) {
      currentForce = newWeight.clamp(0, maxForce);
      ball.position.x = size.x * (currentForce / maxForce);
    }

    for (final obstaclePair in activeObstacles) {
      if (ball.toRect().overlaps(obstaclePair.upper.toRect()) ||
          ball.toRect().overlaps(obstaclePair.lower.toRect())) {
        obstaclePair.wasError = true;
      }
    }

    activeObstacles.removeWhere((pair) => !pair.inScreen);

    if (completedReps >= amountReps && activeObstacles.isEmpty) {
      endGame();
    }
  }

  @override
  Future<void> onRemove() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.onRemove();
  }
}




