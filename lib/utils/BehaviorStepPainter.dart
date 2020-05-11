import 'package:flutter/material.dart';

class BehaviorStepPainter extends CustomPainter {
  Color color;

  BehaviorStepPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = new LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [this.color, this.color],
      tileMode: TileMode.clamp,
    );

    final Rect colorBounds = Rect.fromLTRB(0, 0, size.width, size.height);
    final Paint paint = new Paint()
      ..shader = gradient.createShader(colorBounds);

    Path path = Path();
    path.moveTo(5, 0);
    path.lineTo(size.width-25, 0);
    path.quadraticBezierTo(size.width-20, 0, size.width-20, 5);
    path.lineTo(size.width-20, size.height / 3 * 1);
    path.lineTo(size.width -5, size.height / 2);
    path.lineTo(size.width-20, size.height / 3 * 2);
    path.lineTo(size.width-20, size.height - 5);
    path.quadraticBezierTo(size.width-20, size.height, size.width-25, size.height);
    path.lineTo(5, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height-5);
    path.lineTo(0, 5);
    path.quadraticBezierTo(0, 0, 5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}