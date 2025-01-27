import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent {
  final double speed; // Velocidad de movimiento
  final double screenWidth;
  final double screenHeight;
  final bool isUpper; // Indica si es la parte superior
  bool inScreen = true;
  bool wasError = false;

  Obstacle({
    required this.speed,
    required this.screenWidth,
    required this.screenHeight,
    required Vector2 position,
    required Vector2 size,
    required this.isUpper,
  }) {
    this.position = position;
    this.size = size;
  }


  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.orangeAccent;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }

  @override
  void update(double dt) {
    position.y += speed * dt;

    if ((isUpper && position.y > screenHeight) || (!isUpper && position.y < -size.y)) {
      inScreen = false;
      removeFromParent();
    }
  }
}
