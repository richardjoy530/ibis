import 'package:flutter/material.dart';

class RadialPainter extends CustomPainter {
  double progressInDegrees;

  RadialPainter(this.progressInDegrees);

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    Paint paint = Paint()
      ..shader = RadialGradient(
              colors: [Color(0xffe563a7), Color(0xfff7a4b2), Color(0xffffe9ea)])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0;

    canvas.drawCircle(center, size.width / 2, paint);

//    Paint progressPaint = Paint()
//      ..shader = SweepGradient(
//              colors: [Color(0xff2eb8c9), Color(0xff95dcdb), Color(0xffb9dfe6)])
//          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
//      ..strokeCap = StrokeCap.butt
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = 50.0;

//    canvas.drawArc(
//        Rect.fromCircle(center: center, radius: size.width / 2),
//        math.radians(0),
//        math.radians(-progressInDegrees),
//        false,
//        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
