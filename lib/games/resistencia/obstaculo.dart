import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent {
  Paint paint = Paint()..color = Colors.red; // Se define paint como atributo de la clase

  Obstacle({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  void pintar(Color color) {
    paint.color = color; // Cambia el color del obstáculo
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}