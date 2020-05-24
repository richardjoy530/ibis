import 'front_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class Loding extends StatefulWidget {
  @override
  _LodingState createState() => _LodingState();
}

class _LodingState extends State<Loding> {
  Timer time, timer;
  double per = 0;
  @override
  void initState() {
    /*timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if (per < 1.0) {
          if (per > 0.9) {
            per = 1.0;
          } else {
            per += 0.05;
          }
        }
      });
    });*/
    redirect();
    super.initState();
  }

  void redirect() {
    time = Timer.periodic(Duration(seconds: 2), (timer) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context)=>FrontPage())
      );
    });
  }

  @override
  void dispose() {
    print('Loding page disposed');
    //timer.cancel();
    time.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              'Loading',
              style: TextStyle(fontSize: 60),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(50),
              child: LinearProgressIndicator(),
            ),
          )
        ],
      )),
    );
  }
}
