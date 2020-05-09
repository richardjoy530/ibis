import 'package:flutter/material.dart';

class HeightPainter extends CustomPainter {
  double heightIn100;

  HeightPainter(this.heightIn100);

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
//    Paint backgroundPaint = Paint()
//      ..shader = LinearGradient(
//              begin: Alignment.topCenter,
//              end: Alignment.bottomCenter,
//              colors: [Color(0xff2eb8c9), Color(0xff95dcdb), Color(0xffd1e6ea)])
//          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
//      ..strokeCap = StrokeCap.round
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = 50.0;
//
//    canvas.drawLine(
//        center, Offset(size.width / 2, size.height), backgroundPaint);

    Paint outlinePaint = Paint()
      ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffeaeaea), Color(0xffeaeaea)])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    Paint progressPaint = Paint()
      ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff18c894), Color(0xff18c894)])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    //canvas.drawLine(center, Offset(size.width / 2, heightIn100), progressPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-50 + size.width / 2, -400 / 2, 100, 400),
            Radius.circular(10)),
        outlinePaint);
    for (var i = 1; i < 11; i++) {
      if ((heightIn100 / 10).floor() >= i) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(size.width / 2, (200.0 + 15) - i * 35),
                    width: 90,
                    height: 30),
                Radius.circular(5)),
            progressPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
