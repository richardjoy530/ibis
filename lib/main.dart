import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'front_page.dart';
import 'radial_painter.dart';
import 'test_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BalooTamma2',
      ),
      home: FrontPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final DeviceObject deviceObject;
  HomePage(this.deviceObject);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Timer t;
  var ti=0;
  @override
  void initState() {
    if (widget.deviceObject.power == true) {
      runAnimation(
          begin: (360 / (mapValues(widget.deviceObject.time) * 60)) *
              widget.deviceObject.timer.tick.toDouble(),
          deviceObject: widget.deviceObject,
          end: 360);
      widget.deviceObject.radialProgressAnimationController.forward();
    }
    t = Timer.periodic(Duration(milliseconds: 100), (callback)
    {
      if(widget.deviceObject.isMotion==true)
        {
          ti=ti+1;
          widget.deviceObject.timer.cancel();
        }
      if(ti==30)
        {

          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (context) =>
                      FrontPage())
          );

        }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.deviceObject.power == true) {
      widget.deviceObject.radialProgressAnimationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffb9dfe6),
        leading: Container(
          height: 30,
          width: 30,
          child: FlareActor(
            'assets/status.flr',
            animation: 'Connected',
          ),
        ),
        title: Text(
          widget.deviceObject.name,
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.phonelink_off),
            color: Color(0xff3d84a7),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SocketScreen()),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffb9dfe6), Color(0xffffffff)]),
        ),
        child: tabView(context, widget.deviceObject),
      ),
    );
  }

  startTimer(DeviceObject deviceObject) {
    deviceObject.timer = Timer.periodic(Duration(seconds: 1), (timer) {});
  }

  List<Widget> createTabViewList(int numberOfItems) {
    List<Widget> list = [];
    for (var index = 0; index < numberOfItems; index++) {
      list.add(tabView(context, deviceObjectList[index]));
    }
    return list;
  }

  Widget tabView(BuildContext context, DeviceObject deviceObject) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              FlareActor(
                'assets/breathing.flr',
                animation: deviceObject.power == true ? 'breath' : 'off',
              ),

              CustomPaint(
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.5,
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Center(
                    child: Container(
                      height: (MediaQuery.of(context).size.width / 1.5) - 50,
                      width: (MediaQuery.of(context).size.width / 1.5) - 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            deviceObject.power == true
                                ? 'Time Remaining'
                                : 'Sterilizer Idle',
                            style: TextStyle(fontSize: 20,color: deviceObject.isMotion==false ? Colors.black:Colors.red),
                          ),
                          Text(
                            '${getMinuets(((mapValues(deviceObject.time) * 60) - ((mapValues(deviceObject.time) * 60) / 360) * deviceObject.progressDegrees).round())}'
                            ':${getSeconds(((mapValues(deviceObject.time) * 60) - ((mapValues(deviceObject.time) * 60) / 360) * deviceObject.progressDegrees).round())}',
                            style: TextStyle(fontSize: 60),
                          ),


                        ],
                      ),

                    ),
                  ),
                ),
                painter: RadialPainter(deviceObject.progressDegrees),
              ),
              Visibility(
                visible: deviceObject.isMotion,
                child:  SimpleDialog(
                  title: Center(child: Text('Alert',style: TextStyle(fontSize: 30,fontStyle: FontStyle.italic,color: Colors.pink),),),
                  children: <Widget>[
                    SimpleDialogOption(

                      child: Icon(Icons.add_alert,color: Colors.red,size: 100,),
                    )
                  ],
                ),
              )
            ],

          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            decoration: BoxDecoration(
                color: Color(0xffdae6eb),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffdae6eb),
                    spreadRadius: 10.0, //extend the shadow
                  )
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '1 min',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                Expanded(
                  child: Slider(
                    onChanged: (double value) {
                      if (deviceObject.power == false) {
                        setState(() {
                          deviceObject.time = value;
                        });
                      }
                    },
                    divisions: 12,
                    label: mapValues(deviceObject.time).round().toString(),
                    min: 1,
                    max: 13,
                    value: deviceObject.time,
                    activeColor: Color(0xff2eb8c9),
                    inactiveColor: Color(0xffffffff),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '30 mins',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: GestureDetector(
            onTap: () {
              setState(() {

                if (deviceObject.power == false) {
                  deviceObject.socket
                      .writeln(mapValues(deviceObject.time).round());
                  deviceObject.progressDegrees = 0;
                  deviceObject.power = !deviceObject.power;
                  startTimer(deviceObject);
                  runAnimation(deviceObject: deviceObject);
                  deviceObject.radialProgressAnimationController.forward();
                } else {
                  //time = 2;
                  destroyAnimation(deviceObject);
                  deviceObject.power = !deviceObject.power;
                  deviceObject.timer.cancel();
                  runAnimation(
                      begin: deviceObject.progressDegrees,
                      end: 0,
                      deviceObject: deviceObject);
                  deviceObject.radialProgressAnimationController.forward();
                }
              });
            },
            child: Container(
              height: 100,
              width: 100,
              child: FlareActor('assets/powerButton.flr',
                  animation: deviceObject.power == true ? "on" : "off"),
            ),
          ),
        )
      ],
    );
  }

  double mapValues(value) {
    double temp;
    if (value == 1) {
      temp = 1;
    } else if (value == 2) {
      temp = 2;
    } else if (value == 3) {
      temp = 3;
    } else if (value == 4) {
      temp = 4;
    } else if (value == 5) {
      temp = 5;
    } else if (value == 6) {
      temp = 7;
    } else if (value == 7) {
      temp = 9;
    } else if (value == 8) {
      temp = 10;
    } else if (value == 9) {
      temp = 12;
    } else if (value == 10) {
      temp = 15;
    } else if (value == 11) {
      temp = 20;
    } else if (value == 12) {
      temp = 25;
    } else if (value == 13) {
      temp = 30;
    }
    return temp;
  }

  Future<void> motionDialog(context, DeviceObject deviceObject) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Motion Detected',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            RaisedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  Future<void> setHeight(context, DeviceObject deviceObject) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Set height of the Equipment',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            Listener(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(Icons.arrow_upward),
                  onPressed: () {
                    print('[*]');
                  },
                ),
              ),
              onPointerDown: (data) {
                print('tap up');
                //tap = true;
                //heightOnTap(socket, '1');
              },
              onPointerUp: (data) {
                print('cancel');
                //tap = false;
              },
            ),
            Listener(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () {
                    print('[*]');
                  },
                ),
              ),
              onPointerDown: (data) {
                print('tap up');
                //tap = true;
                //heightOnTap(socket, '-1');
              },
              onPointerUp: (data) {
                print('cancel');
                //tap = false;
              },
            ),
            ListTile(
              title: Text('Confirm height ?'),
              trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    print('confirm');

                    Navigator.pop(context);
                  }),
            )
          ],
        );
      },
    );
  }

  runAnimation(
      {double begin = 0.0, double end = 360.0, DeviceObject deviceObject}) {
    deviceObject.radialProgressAnimationController = AnimationController(
        vsync: this,
        duration: deviceObject.power == true
            ? Duration(minutes: mapValues(deviceObject.time).round())
            : Duration(milliseconds: 500));
    deviceObject.progressAnimation = Tween(begin: begin, end: end).animate(
        CurvedAnimation(
            parent: deviceObject.radialProgressAnimationController,
            curve: Curves.linear))
      ..addListener(() {
        setState(() {
          deviceObject.progressDegrees = deviceObject.progressAnimation.value;
          if (deviceObject.progressDegrees == 360) {
            deviceObject.power = false;
            deviceObject.radialProgressAnimationController.stop();
            deviceObject.timer.cancel();
          }
        });
        if (deviceObject.progressDegrees == 360) {
          deviceObject.progressDegrees = 0;
        }
      });
  }

  destroyAnimation(DeviceObject deviceObject) {
    deviceObject.radialProgressAnimationController.dispose();
  }

  getSeconds(int seconds) {
    var f = new NumberFormat("00", "en_US");
    return f.format(seconds % 60);
  }

  getMinuets(int seconds) {
    var f = new NumberFormat("00", "en_US");
    return f.format((seconds / 60).floor());
  }
}
