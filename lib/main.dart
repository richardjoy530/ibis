import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' as math;


void main() => runApp(MyApp());
Socket socket;
var clientip;
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
  double time = 2;
  String height = '20';

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
                                    '${getMinuets(((time * 60) - ((time * 60) / 360) * progressDegrees).round())}:${getSeconds(((time * 60) - ((time * 60) / 360) * progressDegrees).round())}',
                                    style: TextStyle(fontSize: 60),
                                  ),
//                                  Text(
//                                    power == true ? 'ON' : 'OFF',
//                                    style: TextStyle(fontSize: 15),
//                                  ),
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
                    child: Slider(
                      onChanged: (double value) {
                        if (power == false) {
                          print(time);
                          setState(() {
                            time = value;
                          });
                        }
                      },
                      divisions: 29,
                      label: time.round().toString(),
                      min: 1,
                      max: 30,
                      value: time,
                      activeColor: Color(0xff2eb8c9),
                      inactiveColor: Color(0xffffffff),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (power == false && time != 0) {
                          progressDegrees = 0;
                          runAnimation(Duration(minutes: time.round()));
                          _radialProgressAnimationController.forward();
                        } else {
                          //time = 2;
                          destroyAnimation();
                          //progressDegrees = 0;
                          runAnimation(Duration(milliseconds: 500),
                              begin: progressDegrees, end: 0);
                          _radialProgressAnimationController.forward();
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
                Icons.computer,
              ),
              title: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: 'Server IP', disabledBorder: InputBorder.none),
                onSubmitted: (text) {
                  setState(() {
                    height = text;
                  });
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
  String serverIP = '192.168.18.10';
  int port = 4041;
  String incomingMessages = '';
  bool isConnected = false;
  bool fetching = false;


  @override
  void initState() {
    connect();
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
                title: Text('Connected Devices'),
                leading: Icon(Icons.wifi_tethering),                
              ),
              ListTile(
                title: Text(clientip==null?'':clientip),
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


  void connect() async {
    var ip='0.0.0.0';
    var port=4041;
    ServerSocket.bind(ip, port).then((serverSocket) {
      setState(() {
        isConnected = true;
      });
      serverSocket.listen((sock) {
        //fetch();
      }).onData((sock) {
        socket = sock;
        sock.listen((onData) {
          setState(() {
            var data=socket.remoteAddress;
            var port=socket.remotePort;
            var ip=data.address;
            clientip=ip;
            print(clientip);
            print(port);
            incomingMessages = incomingMessages + String.fromCharCodes(onData);
          });
        });
      });
    });
  }
}
