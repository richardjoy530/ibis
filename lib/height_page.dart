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
  Color upArrowColor = Color(0xfff6a4b2);
  Color upBGColor = Color(0xffffe9ea);
  Color downArrowColor = Color(0xff292888);
  Color downBGColor = Color(0xffffe9ea);

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
    print('Height Page Disposed');
    mainTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        backgroundColor: Color(0xffffe9ea),
//        title: Text(
//          'Adjust Height',
//          style: TextStyle(
//            fontSize: 24,
//            color: Colors.black,
//          ),
//        ),
//      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffffe9ea), Color(0xffffffff)]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  'Adjust Height',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      '${widget.deviceObject.height.floor().toString()}% ',
                      style: TextStyle(fontSize: 40, color: Color(0xff292888))),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CustomPaint(
                    child: Text('Data'),
                    painter: HeightPainter(widget.deviceObject.height),
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
                            upBGColor = upArrowColor;
                            upArrowColor = downBGColor;
                            indicator = 1;
                            if (widget.deviceObject.height < 100) {
                              widget.deviceObject.socket.write('1\r');
                            }
                            tick();
                          },
                          onPointerUp: (data) {
                            setState(() {
                              upArrowColor = Color(0xfff6a4b2);
                              upBGColor = Color(0xffffe9ea);
                            });
                            indicator = 0;
                            timer.cancel();
                            if (widget.deviceObject.height < 100) {
                              widget.deviceObject.socket.write('0\r');
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
                              if (widget.deviceObject.height > 0) {
                                widget.deviceObject.socket.write('-1\r');
                              }
                              tick();
                            },
                            onPointerUp: (data) {
                              setState(() {
                                downArrowColor = Color(0xff292888);
                                downBGColor = Color(0xffffe9ea);
                              });
                              timer.cancel();
                              indicator = 0;
                              if (widget.deviceObject.height > 0) {
                                widget.deviceObject.socket.write('0\r');
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 50),
                child: ClayContainer(
                  borderRadius: 20,
                  spread: 3,
                  color: Color(0xffffe9ea),
//                        decoration: BoxDecoration(
//                            color: Color(0xffdec3e4),
//                            borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(
                      'Confirm height ?',
                      style: TextStyle(color: Color(0xff292888)),
                    ),
                    trailing: IconButton(
                        color: Color(0xff292888),
                        icon: Icon(Icons.check),
                        onPressed: () {
                          widget.deviceObject.progressDegrees = 0;
                          widget.deviceObject.socket.write('true');
                          widget.deviceObject.time = Duration(minutes: 1);
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> tick() async {
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        if (indicator == 1) {
          widget.deviceObject.height += 1;
        } else if (indicator == -1) {
          widget.deviceObject.height -= 1;
        }
        if (widget.deviceObject.height >= 100) {
          widget.deviceObject.height = 100;
        }
        if (widget.deviceObject.height <= 0) {
          widget.deviceObject.height = 0;
        }
      });
    });
  }

  Future<void> mainTick() async {
    mainTimer = Timer.periodic(Duration(seconds: 1), (callback) {
      if (serverOnline == false || widget.deviceObject.clientError == true) {
        Navigator.pop(context);
      }
    });
  }
}
