import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'main.dart';

Color lightBlue = Color(0xff5cbceb);
Color upArrowColor = Color(0xff02457a);
Color darkBlue = Color(0xff02457a);
Color downArrowColor = Color(0xff02457a);

class HeightPage extends StatefulWidget {
  final DeviceObject deviceObject;
  final bool justHeight;
  HeightPage(this.deviceObject, {this.justHeight = false});
  @override
  _HeightPageState createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  Timer mainTimer;
  Timer timer;
  int indicator = 0;
  bool quesVis = true;
  String flare = 'idle';

  @override
  void initState() {
    mainTick();
    super.initState();
  }

  @override
  void dispose() {
    mainTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              //margin: EdgeInsets.only(right: 50,left: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 100,
                    child: FlareActor(
                      'assets/lift.flr',
                      animation: flare,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Listener(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            'images/up.png',
                            color: upArrowColor,
                          ),
                        ),
                        onPointerDown: (data) {
                          if (topHit == false) {
                            bottumHit = false;
                            widget.deviceObject.socket.write('-3\r');
                            setState(() {
                              upArrowColor = lightBlue;
                              downArrowColor = darkBlue;
                              flare = 'up';
                            });
                            indicator = 1;
                            if (widget.deviceObject.height != 100) {
                              tick();
                            }
                          }
                        },
                        onPointerUp: (data) {
                          setState(() {
                            flare = 'idle';
                             downArrowColor = darkBlue;
                            upArrowColor = darkBlue;
                          });
                          widget.deviceObject.socket.write('-1\r');
                          if (timer != null) {
                            timer.cancel();
                          }
                          if (indicator != 0) {
                            prefs.setInt('${widget.deviceObject.ip}height',
                                widget.deviceObject.height.toInt());
                            indicator = 0;
                          }
                        },
                      ),
                      Listener(
                        child: Transform.rotate(
                          angle: 3.14,
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Image.asset('images/up.png',
                                color: downArrowColor),
                          ),
                        ),
                        onPointerDown: (data) {
                          if (bottumHit == false) {
                            topHit = false;
                            setState(() {
                              downArrowColor = lightBlue;
                              upArrowColor = darkBlue;
                              flare = 'down';
                            });
                            indicator = -1;
                            widget.deviceObject.socket.write('-2\r');
                            if (widget.deviceObject.height != 0) {
                              tick();
                            }
                          }
                        },
                        onPointerUp: (data) {
                          setState(() {
                            flare = 'idle';
                            downArrowColor = darkBlue;
                            upArrowColor = darkBlue;
                          });
                          widget.deviceObject.socket.write('-1\r');
                          if (timer != null) {
                            timer.cancel();
                          }
                          if (indicator != 0) {
                            prefs.setInt('${widget.deviceObject.ip}height',
                                widget.deviceObject.height.toInt());
                            indicator = 0;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Listener(
              child: Container(
                margin: EdgeInsets.only(
                    bottom: 10,
                    left: (MediaQuery.of(context).size.width - 200) / 3,
                    right: (MediaQuery.of(context).size.width - 200) / 3),
                //width: MediaQuery.of(context).size.width,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                        colors: [Color(0xff009ce9), Color(0xff83caec)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Center(
                  child: Text(
                    'Confirm Height',
                    style: TextStyle(fontSize: 24, color: Color(0xff02457a)),
                  ),
                ),
              ),
              onPointerUp: (pointerUp) {
                widget.deviceObject.progressDegrees = 0;

                prefs.setInt('${widget.deviceObject.ip}height',
                    widget.deviceObject.height.toInt());
                widget.deviceObject.time = Duration(minutes: 0);
                //widget.deviceObject.temp = true;
                widget.deviceObject.elapsedTime = 0;
                widget.deviceObject.clientError = false;
                isConnected = true;

                if (widget.justHeight == false) {
                  if (widget.deviceObject.height.toInt() == 0) {
                    widget.deviceObject.socket.write('5\r');
                  } else {
                    widget.deviceObject.socket.write('5\r');
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(widget.deviceObject)),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Adjust Height',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xff02457a),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> tick() async {
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        if (indicator == 1) {
          widget.deviceObject.height += 0.5;
        } else if (indicator == -1) {
          widget.deviceObject.height -= 0.5;
        }
        if (widget.deviceObject.height >= 100) {
          widget.deviceObject.height = 100;
          indicator = 0;
          prefs.setInt('${widget.deviceObject.ip}height',
              widget.deviceObject.height.toInt());
          //widget.deviceObject.socket.write('-1\r');
        }
        if (widget.deviceObject.height <= 0) {
          widget.deviceObject.height = 0;
          indicator = 0;
          prefs.setInt('${widget.deviceObject.ip}height',
              widget.deviceObject.height.toInt());
          //widget.deviceObject.socket.write('-1\r');
        }
      });
    });
  }

  Future<void> mainTick() async {
    mainTimer = Timer.periodic(Duration(milliseconds: 1000), (callback) {
      if (serverOnline == false ||
          widget.deviceObject.clientError == true ||
          widget.deviceObject.motionDetected == true) {
        Navigator.pop(context);
      }
    });
  }
}
