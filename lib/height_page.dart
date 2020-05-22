import 'dart:async';

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibis/height_bar.dart';

import 'data.dart';
import 'front_page.dart';
import 'main.dart';

class HeightPage extends StatefulWidget {
  final DeviceObject deviceObject;
  HeightPage(this.deviceObject);
  @override
  _HeightPageState createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  Color upArrowColor = Color(0xff02457a);
  Color upBGColor = Color(0xff97cadb);
  Color downArrowColor = Color(0xffd6e7ee);
  Color downBGColor = Color(0xff97cadb);

  Timer mainTimer;
  Timer timer;
  int indicator = 0;
  bool quesVis = true;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              '${widget.deviceObject.height.floor().toString()}% ',
                              style: TextStyle(
                                  fontSize: 40, color: Color(0xff02457a))),
                        ),
                      ),
                      Container(
                        height: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CustomPaint(
                              child: Text(''),
                              painter:
                                  HeightPainter(widget.deviceObject.height),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Listener(
                                    child: ClayContainer(
                                      color: upBGColor,
                                      spread: 2,
                                      borderRadius: 20,
                                      child: IconButton(
                                        color: upArrowColor,
                                        icon: Icon(Icons.arrow_upward),
                                        onPressed: () {},
                                      ),
                                    ),
                                    onPointerDown: (data) {
                                      widget.deviceObject.socket
                                            .write('-3\r');
                                      upBGColor = upArrowColor;
                                      upArrowColor = downBGColor;
                                      indicator = 1;
                                      if (widget.deviceObject.height != 100) {
                                        
                                        tick();
                                      }
                                    },
                                    onPointerUp: (data) {
                                      widget.deviceObject.socket
                                            .write('-1\r');
                                      setState(() {
                                        upArrowColor = Color(0xff02457a);
                                        upBGColor = Color(0xff97cadb);
                                      });
                                      timer.cancel();
                                      if (indicator != 0) {
                                        prefs.setInt(
                                            '${widget.deviceObject.ip}height',
                                            widget.deviceObject.height.toInt());
                                        indicator = 0;
                                        
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ClayContainer(
                                    spread: 2,
                                    color: downBGColor,
                                    borderRadius: 20,
                                    child: Listener(
                                      child: IconButton(
                                        color: downArrowColor,
                                        icon: Icon(Icons.arrow_downward),
                                        onPressed: () {},
                                      ),
                                      onPointerDown: (data) {
                                        downBGColor = downArrowColor;
                                        downArrowColor = upBGColor;
                                        indicator = -1;
                                         widget.deviceObject.socket
                                              .write('-2\r');
                                        if (widget.deviceObject.height != 0) {
                                         
                                          tick();
                                        }
                                      },
                                      onPointerUp: (data) {
                                         widget.deviceObject.socket
                                              .write('-1\r');
                                        setState(() {
                                          downArrowColor = Color(0xff02457a);
                                          downBGColor = Color(0xff97cadb);
                                        });
                                        timer.cancel();
                                        if (indicator != 0) {
                                          prefs.setInt(
                                              '${widget.deviceObject.ip}height',
                                              widget.deviceObject.height
                                                  .toInt());
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff97cadb),
                ),
                child: ListTile(
                  title: Text(
                    'Confirm height ?',
                    style: TextStyle(color: Color(0xff02457a)),
                  ),
                  trailing: IconButton(
                      color: Color(0xff02457a),
                      icon: Icon(Icons.check),
                      onPressed: () {
                        widget.deviceObject.progressDegrees = 0;
                        if (widget.deviceObject.height.toInt() == 0) {
                          widget.deviceObject.socket.write('0\r');
                        } else {
                          widget.deviceObject.socket.write('5\r');
                        }
                        prefs.setInt('${widget.deviceObject.ip}height',
                            widget.deviceObject.height.toInt());
                        widget.deviceObject.time = Duration(minutes: 0);
                        widget.deviceObject.temp = true;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(widget.deviceObject)),
                        );
                      }),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
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
      if (serverOnline == false || widget.deviceObject.clientError == true||widget.deviceObject.motionDetected==true) {
        Navigator.pop(context);
      }
    });
  }
}
