
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'obstaculo.dart';
import 'resistencia_game.dart';

class ObstaclePair {
  final int id;
  final double speed;
  final double screenWidth;
  final double screenHeight;
  bool inScreen = true;
  bool wasError = false;

  late Obstacle upper;
  late Obstacle lower;

  ObstaclePair({
    required this.id,
    required this.speed,
    required this.screenWidth,
    required this.screenHeight,
    required double lowerX,
    required double upperX,
  }) {

  // Altura fija para ambos obstáculos

    upper = Obstacle(
      position: Vector2(0,-screenHeight),
      size: Vector2(lowerX, screenHeight),
    );

    lower = Obstacle(
      position: Vector2(upperX, -screenHeight),
      size: Vector2(screenWidth - upperX, screenHeight),
    );
  }

  void addToGame(ResistanceGame game) {
    game.add(upper);
    game.add(lower);
  }



  void markAsError() {
    if (!wasError) {
      wasError = true;

      // Cambiar el color del obstáculo para indicar error
      upper.pintar(Colors.black);
      lower.pintar(Colors.black);
    }
  }

  void update(double dt) {
    upper.position.y += speed * dt;
    lower.position.y += speed * dt;



    if (upper.position.y > screenHeight || lower.position.y > screenHeight) {
      inScreen = false;
    }
  }
}