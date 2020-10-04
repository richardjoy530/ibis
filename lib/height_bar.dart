// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class HeightPainter extends CustomPainter {
//   double heightIn100;
//   double height = 370;
//   double width = 100;

//   List<Color> barColors = [
//     Color(0xff009ce9),
//     Color(0xff26aaea),
//     Color(0xff44b3ea),
//     Color(0xff5cbceb),
//     Color(0xff6ac1eb),
//     Color(0xff75c5ec),
//     Color(0xff83caec),
//     Color(0xff9ad2ec),
//     Color(0xffadd8ed),
//     Color(0xffbddeee)
//   ];

//   HeightPainter(this.heightIn100);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Offset center = Offset(size.width / 2, size.height / 2);
// //    Paint backgroundPaint = Paint()
// //      ..shader = LinearGradient(
// //              begin: Alignment.topCenter,
// //              end: Alignment.bottomCenter,
// //              colors: [Color(0xff2eb8c9), Color(0xff95dcdb), Color(0xffd1e6ea)])
// //          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
// //      ..strokeCap = StrokeCap.round
// //      ..style = PaintingStyle.stroke
// //      ..strokeWidth = 50.0;
// //
// //    canvas.drawLine(
// //        center, Offset(size.width / 2, size.height), backgroundPaint);

//     Paint outlinePaint = Paint()
//       ..shader = LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xffd6e7ee), Color(0xffd6e7ee)])
//           .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.fill
//       ..strokeWidth = 2;

//     Paint progressPaint = Paint()
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.fill
//       ..strokeWidth = 2;

//     //canvas.drawLine(center, Offset(size.width / 2, heightIn100), progressPaint);
//     canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(-(width / 2) + size.width / 2,
//               -(height / 2) + size.height / 2, width, height),
//           Radius.circular(20),
//         ),
//         outlinePaint);
//     var temp = 35;
//     for (int i = 0; i < 10; i++) {
//       if ((heightIn100 / 10).floor() >= i) {
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//             Rect.fromLTRB(
//                 5 + (-(width / 2) + size.width / 2),
//                 (heightIn100 / 10).floor() <= i
//                     ? -(heightIn100).remainder(10) * 3 + (height / 2) - temp * i
//                     : (height / 2) - 30 - temp * i,
//                 (-(width / 2) + size.width / 2) + width - 5,
//                 (height / 2) - temp * i),
//             Radius.circular(10),
//           ),
//           progressPaint..color = barColors[9 - i],
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
