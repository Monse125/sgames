


import 'package:flame/game.dart';

import 'obstaculo.dart';

class ObstaclePair {
  final int id;
  final Obstacle upper;
  final Obstacle lower;

  bool get inScreen => upper.inScreen || lower.inScreen;
  bool wasError = true; // Se usará en el futuro

  ObstaclePair({
    required this.id,
    required double speed,
    required double screenWidth,
    required double screenHeight,
    required double lowerX,
    required double upperX,
  })  : upper = Obstacle(
    speed: speed,
    screenWidth: screenWidth,
    screenHeight: screenHeight,
    position: Vector2(0, -screenHeight), // Parte superior fuera de la pantalla
    size: Vector2(lowerX, screenHeight),
    isUpper: true,
  ),
        lower = Obstacle(
          speed: speed,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          position: Vector2(upperX, -screenHeight), // Parte inferior fuera de la pantalla
          size: Vector2(screenWidth - upperX, screenHeight),
          isUpper: true,
        );

  void addToGame(FlameGame game) {
    game.add(upper);
    game.add(lower);
  }
}