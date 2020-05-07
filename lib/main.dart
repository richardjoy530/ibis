import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibis/data.dart';
import 'package:ibis/radial_painter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
void main() => runApp(MyApp());
Socket socket;
bool isConnected;
var devno=0;
var serverIP='no server',port='no';
List<Socket> socketList = [];
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BalooTamma2',
      ),
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<DeviceObject> deviceObjectList = [];

  bool power = false;
  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;
  double progressDegrees = 0;
  double time = 1;
  bool isHeightSet = false;


  void connect() async {

    ServerSocket.bind('0.0.0.0', 4041).then((serverSocket) {
      setState(() {
        isConnected = true;
        serverIP='0.0.0.0';
        port='4041';
      });
      serverSocket.listen((sock) {

      }).onData((sock) {
        socket = sock;
        socketList.add(socket);
        print(socketList);
        print([sock.remoteAddress, sock.remotePort, socketList.length]);
        setState(() {
          devno=socketList.length;
        });
        sock.listen((onData) {
          setState(() {

           // incomingMessages = incomingMessages + String.fromCharCodes(onData);
          });
        }).onDone((){
          setState(() {
            devno=devno-1;
          });
        });
      });

    });
  }


  @override
  void initState() {
    connect();
    super.initState();
  }

  @override
  void dispose() {
    //_radialProgressAnimationController.dispose();
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
            animation: power == true ? 'Connected' : 'Connected',
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 200),
              child: Text(
                'Ibis Sterilyzer',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),

              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Connected devices:$devno',
                style: TextStyle(
                  fontSize: 15,
                ),),
                Text('\t\t\t\t\t\t\tHost ip:$serverIP',
                style: TextStyle(
                  fontSize: 15,
                ),
                ),

                Text('\t\t\t\t\t\tPort:$port',
                style: TextStyle(
                  fontSize: 15,
                ),),
              ],
            ),
          ],
        ),


      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffb9dfe6), Color(0xffffffff)]),
        ),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Flexible(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      FlareActor(
                        'assets/breathing.flr',
                        animation: power == true ? 'breath' : 'off',
                      ),
                      CustomPaint(
                        child: Container(
                          height: MediaQuery.of(context).size.width / 1.5,
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Center(
                            child: Container(
                              height:
                                  (MediaQuery.of(context).size.width / 1.5) -
                                      50,
                              width: (MediaQuery.of(context).size.width / 1.5) -
                                  50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    power == true
                                        ? 'Time Remaining'
                                        : 'Sterilizer Idle',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    '${getMinuets(((mapValues(time) * 60) - ((mapValues(time) * 60) / 360) * progressDegrees).round())}:${getSeconds(((mapValues(time) * 60) - ((mapValues(time) * 60) / 360) * progressDegrees).round())}',
                                    style: TextStyle(fontSize: 60),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (power == false) {
                                        setHeight(context);
                                      }
                                    },
                                    child: Text(
                                      isHeightSet == false
                                          ? 'Tap to set Height'
                                          : 'Height is set',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        painter: RadialPainter(progressDegrees),
                      ),
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
                              if (power == false) {
                                setState(() {
                                  time = value;
                                });
                              }
                            },
                            divisions: 12,
                            label: mapValues(time).round().toString(),
                            min: 1,
                            max: 13,
                            value: time,
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
                        if (power == false && time != 0) {
                          if (isHeightSet == false) {
                            setHeight(context);
                          }
                          if (isHeightSet == true) {
                            progressDegrees = 0;
                            runAnimation(
                                Duration(minutes: mapValues(time).round()));
                            _radialProgressAnimationController.forward();
                            power = !power;
                          }
                        } else {
                          //time = 2;
                          destroyAnimation();
                          //progressDegrees = 0;
                          runAnimation(Duration(milliseconds: 500),
                              begin: progressDegrees, end: 0);
                          _radialProgressAnimationController.forward();
                          power = !power;
                          isHeightSet = false;
                        }
                      });
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      child: FlareActor('assets/powerButton.flr',
                          animation: power == true ? "on" : "off"),
                    ),
                  ),
                )
              ],
            ),


      ),
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

  Future<void> setHeight(context) async {
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
                    setState(() {
                      isHeightSet = true;
                    });
                    Navigator.pop(context);
                  }),
            )
          ],
        );
      },
    );
  }

  runAnimation(Duration time,
      {double begin = 0.0, double end = 360.0, DeviceObject deviceObject}) {
    deviceObject.radialProgressAnimationController =
        AnimationController(vsync: this, duration: time);
    deviceObject.progressAnimation = Tween(begin: begin, end: end).animate(
        CurvedAnimation(
            parent: deviceObject.radialProgressAnimationController,
            curve: Curves.linear))
      ..addListener(() {
        setState(() {
          progressDegrees = deviceObject.progressAnimation.value;
          if (progressDegrees == 360) {
            power = false;
          }
        });
        if (progressDegrees == 360) {
          progressDegrees = 0;
        }
      });
  }

  destroyAnimation() {
    _radialProgressAnimationController.dispose();
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
