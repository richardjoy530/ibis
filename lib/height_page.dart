import 'dart:async';

import 'package:clay_containers/clay_containers.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'main.dart';

class HeightPage extends StatefulWidget {
  final DeviceObject deviceObject;
  final bool justHeight;
  HeightPage(this.deviceObject, {this.justHeight = false});
  @override
  _HeightPageState createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  Color upArrowColor = Color(0xff02457a);
  Color upBGColor = Color(0xff5cbceb);
  Color downArrowColor = Color(0xffd6e7ee);
  Color downBGColor = Color(0xff5cbceb);

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
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Container(
          //     margin: EdgeInsets.only(top:100),
          //     height: 300,
          //     child: FlareActor(
          //       'assets/lift.flr',
          //       animation: 'up',
          //     ),
          //   ),
          // ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    height: 300,
                    child: FlareActor(
                      'assets/lift.flr',
                      animation: flare,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Listener(
                          child: ClayContainer(
                            color: upBGColor,
                            spread: 0,
                            borderRadius: 20,
                            customBorderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                            child: IconButton(
                              iconSize: 50.0,
                              color: upArrowColor,
                              icon: Icon(Icons.add),
                              onPressed: () {},
                            ),
                          ),
                          onPointerDown: (data) {
                            widget.deviceObject.socket.write('-3\r');
                            upBGColor = upArrowColor;
                            setState(() {
                              flare = 'up';
                            });
                            upArrowColor = downBGColor;
                            indicator = 1;
                            if (widget.deviceObject.height != 100) {
                              tick();
                            }
                          },
                          onPointerUp: (data) {
                            widget.deviceObject.socket.write('-1\r');
                            setState(() {
                              flare = 'idle';
                            });
                            setState(() {
                              upArrowColor = Color(0xff02457a);
                              upBGColor = Color(0xff5cbceb);
                            });
                            timer.cancel();
                            if (indicator != 0) {
                              prefs.setInt('${widget.deviceObject.ip}height',
                                  widget.deviceObject.height.toInt());
                              indicator = 0;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ClayContainer(
                          spread: 0,
                          color: downBGColor,
                          customBorderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0)),
                          child: Listener(
                            child: IconButton(
                              iconSize: 50.0,
                              color: downArrowColor,
                              icon: Icon(Icons.remove),
                              onPressed: () {},
                            ),
                            onPointerDown: (data) {
                              downBGColor = downArrowColor;
                              downArrowColor = upBGColor;
                              setState(() {
                                flare = 'down';
                              });

                              indicator = -1;
                              widget.deviceObject.socket.write('-2\r');
                              if (widget.deviceObject.height != 0) {
                                tick();
                              }
                            },
                            onPointerUp: (data) {
                              widget.deviceObject.socket.write('-1\r');

                              setState(() {
                                flare = 'idle';
                                downArrowColor = Color(0xff02457a);
                                downBGColor = Color(0xff5cbceb);
                              });
                              timer.cancel();
                              if (indicator != 0) {
                                prefs.setInt('${widget.deviceObject.ip}height',
                                    widget.deviceObject.height.toInt());
                                indicator = 0;
                              }
                            },
                          ),
                        ),
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
                width: MediaQuery.of(context).size.width,
                height: 70,
                decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(20),
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
                if (widget.deviceObject.height.toInt() == 0) {
                  widget.deviceObject.socket.write('5\r');
                } else {
                  widget.deviceObject.socket.write('5\r');
                }
                prefs.setInt('${widget.deviceObject.ip}height',
                    widget.deviceObject.height.toInt());
                widget.deviceObject.time = Duration(minutes: 0);
                widget.deviceObject.temp = true;
                widget.deviceObject.elapsedTime = 0;
                widget.deviceObject.clientError = false;
                isConnected = true;

                if (widget.justHeight == false) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(widget.deviceObject)),
                  );
                }else{
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xff02457a),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Adjust Height',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff02457a),
                    ),
                  ),
                ),
              ],
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
