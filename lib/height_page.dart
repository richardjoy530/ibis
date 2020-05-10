import 'dart:async';

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
      appBar: AppBar(
        backgroundColor: Color(0xffffe9ea),
        automaticallyImplyLeading: false,
        title: Text(
          'Adjust Height',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffffe9ea), Color(0xffffffff)]),
        ),
        child: Center(
          child: quesVis == true
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('Do you want height'),
                    RaisedButton(
                        child: Text('YES'),
                        onPressed: () {
                          widget.deviceObject.socket.write('2\r');
                          setState(() {
                            quesVis = !quesVis;
                          });
                        }),
                    RaisedButton(
                        child: Text('NO'),
                        onPressed: () {
                          widget.deviceObject.socket.write('-2\r');
                          widget.deviceObject.time = Duration(minutes: 1);
                          widget.deviceObject.progressDegrees = 0;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(widget.deviceObject)),
                          );
                        }),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        top: 50,
                      ),
                      child: Text(
                          '${widget.deviceObject.height.floor().toString()}% ',
                          style: TextStyle(
                              fontSize: 40, color: Color(0xff9a6c9f))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IgnorePointer(
                          child: CustomPaint(
                            child: Text(''),
                            painter: HeightPainter(widget.deviceObject.height),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Listener(
                                child: IconButton(
                                  color: Colors.blueGrey,
                                  icon: Icon(Icons.arrow_upward),
                                  onPressed: () {},
                                ),
                                onPointerDown: (data) {
                                  indicator = 1;
                                  widget.deviceObject.socket.write('1\r');
                                  tick();
                                },
                                onPointerUp: (data) {
                                  indicator = 0;
                                  timer.cancel();
                                  widget.deviceObject.socket.write('0\r');
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Listener(
                                child: IconButton(
                                  color: Colors.blueGrey,
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: () {},
                                ),
                                onPointerDown: (data) {
                                  indicator = -1;
                                  widget.deviceObject.socket.write('-1\r');
                                  tick();
                                },
                                onPointerUp: (data) {
                                  timer.cancel();
                                  indicator = 0;
                                  widget.deviceObject.socket.write('0\r');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 50),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffdec3e4),
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            'Confirm height ?',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          trailing: IconButton(
                              color: Colors.blueGrey,
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
