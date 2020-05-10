import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeightPainter extends CustomPainter {
  double heightIn100;
  double height = 370;
  double width = 100;

  List<Color> barColors = [
    Color(0xff292888),
    Color(0xff3b338b),
    Color(0xff594491),
    Color(0xff725496),
    Color(0xff87609b),
    Color(0xff9a6c9f),
    Color(0xffad77a3),
    Color(0xffc485a8),
    Color(0xffdc94ac),
    Color(0xfff6a4b2)
  ];

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
              colors: [Color(0xffffe9ea), Color(0xffffe9ea)])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    Paint progressPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    //canvas.drawLine(center, Offset(size.width / 2, heightIn100), progressPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-(width / 2) + size.width / 2,
                -(height / 2) + size.height / 2, width, height),
            Radius.circular(20)),
        outlinePaint);
    var temp = 35;
    for (int i = 0; i < 10; i++) {
      if ((heightIn100 / 10).floor() >= i) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(
                    5 + (-(width / 2) + size.width / 2),
                    (heightIn100 / 10).floor() <= i
                        ? -((heightIn100).remainder(10) * 3)
                        : (height / 2) - 30 - temp * i,
                    (-(width / 2) + size.width / 2) + width - 5,
                    (height / 2) - temp * i),
                Radius.circular(10)),
            progressPaint..color = barColors[i]);
      }
    }

//    for (var i = 1; i < 11; i++) {
//      if ((heightIn100 / 10).ceil() >= i) {
////        canvas.drawRRect(
////            RRect.fromRectAndRadius(
////                Rect.fromLTRB(
////                    (-(width / 2) + size.width / 2) + 5,
////                    ((height / 2) + 4) - i * 34,
////                    ((width / 2) + size.width / 2) - 5,
////                    ((height / 2)) - (i - 1) * 34),
////                Radius.circular(10)),
////            progressPaint..color = barColors[i - 1]);
//
//        canvas.drawRRect(
//            RRect.fromRectAndRadius(
//                Rect.fromCenter(
//                    center:
//                        Offset(size.width / 2, ((height / 2) + 10) - i * 35),
//                    width: width - 10,
//                    height: (heightIn100 / 10).ceil() == i
//                        ? heightIn100.remainder(10) == 0
//                            ? 30
//                            : (((heightIn100).remainder(10) * 3))
//                        : 30),
//                Radius.circular(10)),
//            progressPaint..color = barColors[i - 1]);
//      }
//    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
