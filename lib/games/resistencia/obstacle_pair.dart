import 'package:flame/components.dart';
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
    double obstacleHeight = 50; // Altura fija para ambos obstáculos

    upper = Obstacle(
      position: Vector2(upperX, 0),
      size: Vector2(50, obstacleHeight),
    );

    lower = Obstacle(
      position: Vector2(lowerX, screenHeight - obstacleHeight),
      size: Vector2(50, obstacleHeight),
    );
  }

  void addToGame(ResistanceGame game) {
    game.add(upper);
    game.add(lower);
  }

  void update(double dt) {
    upper.position.y += speed * dt;
    lower.position.y += speed * dt;

    if (upper.position.y > screenHeight || lower.position.y > screenHeight) {
      inScreen = false;
    }
  }
}