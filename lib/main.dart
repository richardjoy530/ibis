import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' as math;

void main() => runApp(MyApp());
Socket socket;

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
  bool power = false;
  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;
  double progressDegrees = 0;
  double time = 1;
  String height = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _radialProgressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffb9dfe6), Color(0xffffffff)]),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.all(8),
                  trailing: IconButton(
                    icon: Icon(Icons.phonelink_off),
                    color: Color(0xff3d84a7),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SocketScreen()),
                      );
                    },
                  ),
                  title: Text(
                    'Ibis Sterilyzer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Not Connected',
                    style: TextStyle(color: Color(0xff47466d)),
                  ),
                  leading: Container(
                    height: 30,
                    width: 30,
                    child: FlareActor(
                      'assets/status.flr',
                      animation: power == true ? 'Connected' : 'Connected',
                    ),
                  ),
                ),
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
                                      height == ''
                                          ? 'Height not set'
                                          : 'Height: $height',
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (power == false && time != 0) {
                          if (height == '') {
                            setHeight(context);
                          }
                          if (height != '') {
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
            ListTile(
              leading: Icon(
                Icons.settings_input_composite,
              ),
              title: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Height',
                    disabledBorder: InputBorder.none),
                onChanged: (text) {
                  height = text;
                },
                onSubmitted: (text) {
                  height = text;
                  Navigator.pop(context);
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        );
      },
    );
  }

  runAnimation(Duration time, {double begin = 0.0, double end = 360.0}) {
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: time);
    _progressAnimation = Tween(begin: begin, end: end).animate(CurvedAnimation(
        parent: _radialProgressAnimationController, curve: Curves.linear))
      ..addListener(() {
        setState(() {
          progressDegrees = _progressAnimation.value;
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

class RadialPainter extends CustomPainter {
  double progressInDegrees;

  RadialPainter(this.progressInDegrees);

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    Paint paint = Paint()
      ..shader = RadialGradient(
              colors: [Color(0xff2eb8c9), Color(0xff95dcdb), Color(0xffd1e6ea)])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0;

    canvas.drawCircle(center, size.width / 2, paint);

    Paint progressPaint = Paint()
      ..shader = SweepGradient(
              colors: [Color(0xff2eb8c9), Color(0xff95dcdb), Color(0xffb9dfe6)])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(0),
        math.radians(-progressInDegrees),
        false,
        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SocketScreen extends StatefulWidget {
  @override
  _SocketScreenState createState() => _SocketScreenState();
}

class _SocketScreenState extends State<SocketScreen> {
  TextEditingController textEditingController;
  TextEditingController ipEditingController;
  TextEditingController portEditingController;
  String serverIP = '0.0.0.0';
  int port = 4041;
  String incomingMessages = '';
  bool isConnected = false;
  bool fetching = false;
  List<Socket> socketList = [];

  @override
  void initState() {
    textEditingController = TextEditingController();
    ipEditingController = TextEditingController();
    ipEditingController.text = serverIP;
    portEditingController = TextEditingController();
    portEditingController.text = '4041';
    super.initState();
  }

  @override
  void dispose() {
    for (var s in socketList) {
      s.close();
      s.destroy();
    }
    socketList = [];
    textEditingController.dispose();
    ipEditingController.dispose();
    portEditingController.dispose();
    super.dispose();
  }

  @override
  //Testing
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                onTap: () {
                  setServerIP(context);
                },
                leading: Icon(Icons.computer),
                title: Text('Create a TCP server'),
                subtitle: Text(
                    'Hosted TCP server on : ${isConnected == false ? 'None' : serverIP}'),
              ),
              ListTile(
                title: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: 'Type text to send',
                      disabledBorder: InputBorder.none),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    for (var s in socketList) {
                      s.write(textEditingController.text);
                    }
                    textEditingController.text = '';
                  },
                ),
              ),
              Container(
                child: ListTile(
                    trailing: IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: () {
                        setState(() {
                          incomingMessages = '';
                        });
                      },
                    ),
                    title: Text('Recived data'),
                    subtitle: Text(incomingMessages)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setServerIP(context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Set your server IP',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.computer,
              ),
              title: TextField(
                keyboardType: TextInputType.number,
                controller: ipEditingController,
                decoration: InputDecoration(
                    hintText: 'Server IP', disabledBorder: InputBorder.none),
              ),
//              trailing: IconButton(
//                  icon: Icon(Icons.check),
//                  onPressed: () {
//                    serverIP = ipEditingController.text;
//                    connect();
//                    Navigator.pop(context);
//                  }),
            ),
            ListTile(
              title: TextField(
                keyboardType: TextInputType.number,
                controller: portEditingController,
                decoration: InputDecoration(
                    hintText: 'Port', disabledBorder: InputBorder.none),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    port = int.parse(portEditingController.text);
                    serverIP = ipEditingController.text;
                    connect();
                    Navigator.pop(context);
                  }),
            )
          ],
        );
      },
    );
  }

  void connect() async {
    ServerSocket.bind(serverIP, port).then((serverSocket) {
      setState(() {
        isConnected = true;
      });
      serverSocket.listen((sock) {
        // print([sock.address, sock.remoteAddress]);
        //fetch();
      }).onData((sock) {
        socket = sock;
        socketList.add(socket);
        print([sock.remoteAddress, sock.remotePort, socketList.length]);
        sock.listen((onData) {
          setState(() {
            incomingMessages = incomingMessages + String.fromCharCodes(onData);
          });
        });
      });
    });
  }
}
