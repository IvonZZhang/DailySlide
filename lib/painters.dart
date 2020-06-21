
import 'package:flutter/material.dart';

class DrawCircle extends CustomPainter {

  var radius = 30.0;

  Paint _paint = Paint()
    ..color = Colors.green
    ..strokeWidth = 10.0
    ..style = PaintingStyle.fill;

  DrawCircle(isTraining, lightsOn, color, strokeWidth, style, [radius=30.0]) {
    this.radius = radius;
    color = isTraining ? (lightsOn ? color : Colors.transparent)
        : Colors.transparent;
    _paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = style;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), radius, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}