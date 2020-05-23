import 'front_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Loding extends StatefulWidget {
  @override
  _LodingState createState() => _LodingState();
}

class _LodingState extends State<Loding> {
  Timer time,Time;
  double per=0;
  @override
  void initState() {
    // TODO: implement initState
    Time=Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if(per<1.0) {
          if(per>0.9)
            {
              per=1.0;
            }
          else {
            per += 0.05;
          }
        }
      });

    });
    redirect();
    super.initState();
  }
  void redirect()
  {
    time=Timer.periodic(Duration(seconds: 2), (timer) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context)=>FrontPage())
      );
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    print('Loding page disposed');
    Time.cancel();
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
                child: Text('Loading',style: TextStyle(fontSize: 60),),
              ),
              Positioned(
                bottom: 50.0,
                left: MediaQuery.of(context).size.width/3,
                child: LinearPercentIndicator(
                  lineHeight: 6.0,
                  width: 150,
                  percent:per ,
                  progressColor: Colors.blue,
                ),
              )
            ],
        )
      ),
    );
  }
}
