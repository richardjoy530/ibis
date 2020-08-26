// import 'package:flutter/material.dart';

// class RadialPainter extends CustomPainter {
//   double progressInDegrees;

//   RadialPainter(this.progressInDegrees);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Offset center = Offset(size.width / 2, size.height / 2);
//     Paint paint = Paint()
//       ..shader = RadialGradient(colors: [
//         Color(0xff008bc0),
//         Color(0xff97cadb),
//       ]).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 50.0;

//     canvas.drawCircle(center, size.width / 2, paint);

// //    Paint progressPaint = Paint()
// //      ..shader = SweepGradient(
// //              colors: [Color(0xff2eb8c9), Color(0xff95dcdb), Color(0xffb9dfe6)])
// //          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
// //      ..strokeCap = StrokeCap.butt
// //      ..style = PaintingStyle.stroke
// //      ..strokeWidth = 50.0;

// //    canvas.drawArc(
// //        Rect.fromCircle(center: center, radius: size.width / 2),
// //        math.radians(0),
// //        math.radians(-progressInDegrees),
// //        false,
// //        progressPaint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
// class TrianglePainter extends CustomPainter {
//   final Color strokeColor;
//   final PaintingStyle paintingStyle;
//   final double strokeWidth;

//   TrianglePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = strokeColor
//       ..strokeWidth = strokeWidth
//       ..style = paintingStyle;

//     canvas.drawPath(getTrianglePath(size.width, size.height), paint);
//   }

//   Path getTrianglePath(double x, double y) {
//     return Path()
//       ..moveTo(0, y)
//       ..lineTo(x / 2, 0)
//       ..lineTo(x, y)
//       ..lineTo(0, y);
//   }

//   @override
//   bool shouldRepaint(TrianglePainter oldDelegate) {
//     return oldDelegate.strokeColor != strokeColor ||
//         oldDelegate.paintingStyle != paintingStyle ||
//         oldDelegate.strokeWidth != strokeWidth;
//   }
// }