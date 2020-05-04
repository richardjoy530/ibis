import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool power = false;
  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;
  final Duration fillDuration = Duration(seconds: 5);
  double progressDegrees = 0;
  double time = 270;
  double val = 0.5;

  @override
  void initState() {
    super.initState();
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: fillDuration);
    _progressAnimation = Tween(begin: 0.0, end: time).animate(CurvedAnimation(
        parent: _radialProgressAnimationController, curve: Curves.linear))
        ..addListener(() {
        setState(() {
          progressDegrees = _progressAnimation.value;
        });
      });
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
                      animation: power == true ? 'Connected' : 'off',
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
                                    'Time Remaining',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    '05:${progressDegrees.toString().substring(0, 2)}',
                                    style: TextStyle(fontSize: 60),
                                  )
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
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffdae6eb),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffdae6eb),
                          //blurRadius: 5.0, // soften the shadow
                          spreadRadius: 10.0, //extend the shadow
//                      offset: Offset(
//                        15.0, // Move to right 10  horizontally
//                        15.0, // Move to bottom 10 Vertically
//                      ),
                        )
                      ]),
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Slider(
                    onChanged: (double value) {
                      print(time);
                      setState(() {
                        time = value;
                      });
                    },
                    max: 360,
                    value: time,
                    activeColor: Color(0xff2eb8c9),
                    inactiveColor: Color(0xffffffff),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (power == false) {
                          _radialProgressAnimationController.forward();
                        } else {
                          _radialProgressAnimationController.reverse();
                        }
                        power = !power;
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
  String serverIP = '192.168.18.10';
  int port = 4041;
  String incomingMessages = '';
  bool isConnected = false;
  bool fetching = false;

  @override
  void initState() {
    textEditingController = TextEditingController();
    ipEditingController = TextEditingController();
    ipEditingController.text = '192.168.18.10';
    portEditingController = TextEditingController();
    portEditingController.text = '4041';
    super.initState();
  }

  @override
  void dispose() {
    socket.close();
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
                    socket.write(textEditingController.text);
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
        //fetch();
      }).onData((sock) {
        socket = sock;
        sock.listen((onData) {
          setState(() {
            incomingMessages = incomingMessages + String.fromCharCodes(onData);
          });
        });
      });
    });
  }
}
