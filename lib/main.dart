import 'dart:async';
import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ibis/radial_painter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'data.dart';
import 'front_page.dart';
import 'test_screen.dart';

int displayTime;
SharedPreferences prefs;
String deviceName;
int deviceHeight;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final customColor = CustomSliderColors(
    progressBarColor: Color(0xffffe9ea),
    hideShadow: true,
    trackColor: Color(0xffffe9ea),
    progressBarColors: [
      Color(0xffa43dbd),
      Color(0xffe563a7),
      Color(0xfff7a4b2),
    ]);
var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
var initializationSettingsIOS = IOSInitializationSettings();
var initializationSettings = InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);
const platform = const MethodChannel("com.richard.ibis/ibis");
void main() {
  connect();
  return runApp(MyApp());
}

Future<void> getIpList() async {
  prefs = await SharedPreferences.getInstance();
  ipList = (prefs.getStringList('iplist')) ?? [];
  for (var eachIp in ipList) {
    deviceName = prefs.getString('${eachIp}name');
    deviceHeight = prefs.getInt('${eachIp}height') ?? 0;
    deviceObjectList.add(DeviceObject(
        offline: true,
        ip: eachIp,
        name: deviceName,
        height: deviceHeight.toDouble()));
  }
}

void test() async {
  String value;
  try {
    value = await platform.invokeMethod('test');
  } catch (e) {
    print(e);
  }

  print('Test : $value');
}

Future<void> notification(String message) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Default,
      priority: Priority.Default,
      ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, 'Alert', message, platformChannelSpecifics, payload: 'item x');
}

void connect() async {
  ServerSocket.bind('0.0.0.0', 4042)
    ..then((sock) {
      serverSocket = sock;
      serverOnline = true;
      print('Server Hosted');
      runZoned(() {}, onError: (e) {
        print('Server error 1: $e');
      });
      serverSocket.listen((sock) {}).onData((clientSocket) {
        if (!ipList.contains(clientSocket.remoteAddress.address)) {
          //New Devices
          deviceObjectList.add(DeviceObject(
              offline: false,
              socket: clientSocket,
              ip: clientSocket.remoteAddress.address,
              name: clientSocket.remotePort.toString(),
              time: Duration(minutes: 0)));
          DeviceObject temp = deviceObjectList.singleWhere(
              (element) => element.ip == clientSocket.remoteAddress.address);
          deviceObjectList[deviceObjectList.indexOf(temp)].run();
          ipList.add(clientSocket.remoteAddress.address);
          SharedPreferences.getInstance().then((prefs) {
            prefs.setStringList('iplist', ipList);
            prefs.setString('${clientSocket.remoteAddress.address}name',
                'Device${clientSocket.remotePort}');
          });

          print([
            clientSocket.remoteAddress,
            clientSocket.remotePort,
            'Not in ipList'
          ]);
        } else {
          //Registered Devices
          DeviceObject temp = deviceObjectList.singleWhere(
              (element) => element.ip == clientSocket.remoteAddress.address);
          deviceObjectList[deviceObjectList.indexOf(temp)].socket =
              clientSocket;
          deviceObjectList[deviceObjectList.indexOf(temp)].offline = false;
          deviceObjectList[deviceObjectList.indexOf(temp)].run();
          deviceObjectList[deviceObjectList.indexOf(temp)].time =
              Duration(minutes: 0);
          SharedPreferences.getInstance().then((prefs) =>
              deviceObjectList[deviceObjectList.indexOf(temp)].name =
                  prefs.getString('${clientSocket.remoteAddress.address}name'));
          print([
            clientSocket.remoteAddress,
            clientSocket.remotePort,
            'In ipList'
          ]);
        }
      });
    })
    ..catchError((onError) {
      print(['Server error 2: ', onError.toString()]);
    })
    ..whenComplete(() {
      print(['Complete']);
    });
}

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
  double temp;
  Timer mainTimer;
  bool errorRemover = false;
  @override
  void initState() {
    temp = 1;
    mainTick();
    if (widget.deviceObject.power == true) {
      runAnimation(
          begin: (360 / (widget.deviceObject.time.inMinutes * 60)) *
              widget.deviceObject.timer.tick,
          deviceObject: widget.deviceObject,
          end: 360);
      widget.deviceObject.radialProgressAnimationController.forward();
    }
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    super.initState();
  }

//  Future selectNotification(String payload) async {
//    if (payload != null) {
//      debugPrint('notification payload: ' + payload);
//    }
//    await Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => FrontPage()),
//    );
//  }

  @override
  void dispose() {
    print('Main Page Disposed');
    if (widget.deviceObject.power == true) {
      widget.deviceObject.radialProgressAnimationController.dispose();
    }
    mainTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffe9ea),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 30,
            width: 30,
            child: FlareActor(
              'assets/status.flr',
              animation: 'Connected',
            ),
          ),
        ),
        title: Text(
          widget.deviceObject.name,
          style: TextStyle(
            fontSize: 24,
            color: Color(0xff3b338b),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.phonelink_off),
            color: Color(0xff3b338b),
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
              colors: [Color(0xffffe9ea), Color(0xffffffff)]),
        ),
        child: widget.deviceObject.motionDetected == true
            ? AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Align(
                    alignment: Alignment.center,
                    child: Text('Motion Detected')),
                content: Icon(
                  Icons.warning,
                  color: Color(0xff725496),
                  size: 50,
                ),
                backgroundColor: Color(0xffdec3e4),
              )
            : tabView(context, widget.deviceObject),
      ),
    );
  }

  startTimer(DeviceObject deviceObject) {
    deviceObject.timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (serverOnline == true && widget.deviceObject.clientError == false) {}
    });
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
                            style: TextStyle(
                                fontSize: 20,
                                color: deviceObject.motionDetected == false
                                    ? Colors.black
                                    : Colors.red),
                          ),
                          Text(
                            '${getMinuets(((deviceObject.time.inMinutes * 60) - ((deviceObject.time.inMinutes * 60) / 360) * deviceObject.progressDegrees).round())}'
                            ':${getSeconds(((deviceObject.time.inMinutes * 60) - ((deviceObject.time.inMinutes * 60) / 360) * deviceObject.progressDegrees).round())}',
                            style: TextStyle(fontSize: 60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                painter: RadialPainter(deviceObject.progressDegrees),
              ),
              deviceObject.power == false
                  ? SleekCircularSlider(
                      min: 1,
                      max: 19,
                      initialValue: 1,
                      appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                              trackWidth: 50,
                              progressBarWidth: 50,
                              shadowWidth: 50),
                          size: (MediaQuery.of(context).size.width / 1.5) + 50,
                          customColors: customColor),
                      onChange: (double value) {
                        print(value);
                        displayTime = value.floor();

                        if (deviceObject.power == false &&
                            errorRemover == true) {
                          setState(() {
                            deviceObject.time = Duration(
                                minutes:
                                    mapValues(displayTime.toDouble()).toInt());
                          });
                        }
                        errorRemover = true;
                      },
                      innerWidget: (value) {
                        return null;
                      },
                    )
                  : SleekCircularSlider(
                      min: 0,
                      max: 3600,
                      initialValue: 3600 -
                          (3600 / deviceObject.time.inSeconds) *
                              deviceObject.timer.tick,
                      appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                              trackWidth: 50,
                              progressBarWidth: 50,
                              shadowWidth: 50),
                          size: (MediaQuery.of(context).size.width / 1.5) + 50,
                          customColors: customColor),
                      innerWidget: (value) {
                        return null;
                      },
                    )
            ],
          ),
        ),
//        Padding(
//          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//          child: Container(
//            decoration: BoxDecoration(
//                color: Color(0xffdae6eb),
//                borderRadius: BorderRadius.circular(50),
//                boxShadow: [
//                  BoxShadow(
//                    color: Color(0xffdae6eb),
//                    spreadRadius: 10.0, //extend the shadow
//                  )
//                ]),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(left: 8.0),
//                  child: Text(
//                    '1 min',
//                    style: TextStyle(color: Colors.blueGrey),
//                  ),
//                ),
////                Expanded(
////                  child: Slider(
////                    onChanged: (double value) {
////                      if (deviceObject.power == false) {
////                        setState(() {
////                          valueTemp = value;
////
////                          deviceObject.time =
////                              Duration(minutes: mapValues(value).toInt());
////                        });
////                      }
////                    },
////                    divisions: 18,
////                    label: deviceObject.time.inMinutes.round().toString(),
////                    min: 1,
////                    max: 19,
////                    value: valueTemp,
////                    activeColor: Color(0xff2eb8c9),
////                    inactiveColor: Color(0xffffffff),
////                  ),
////                ),
////                Padding(
////                  padding: const EdgeInsets.only(right: 8.0),
////                  child: Text(
////                    '60 mins',
////                    style: TextStyle(color: Colors.blueGrey),
////                  ),
////                ),
//              ],
//            ),
//          ),
//        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (deviceObject.power == false) {
                  deviceObject.socket
                      .writeln(deviceObject.time.inMinutes.round());

                  deviceObject.progressDegrees = 0;
                  deviceObject.power = !deviceObject.power;
                  startTimer(deviceObject);
                  runAnimation(deviceObject: deviceObject);
                  deviceObject.radialProgressAnimationController.forward();
                } else {
                  //time = 2;
                  destroyAnimation(deviceObject);
                  deviceObject.socket.write('stop');
                  deviceObject.power = !deviceObject.power;
                  deviceObject.timer.cancel();
//                  runAnimation(
//                      begin: deviceObject.progressDegrees,
//                      end: 0,
//                      deviceObject: deviceObject);
//                  deviceObject.radialProgressAnimationController.forward();
                  Navigator.pop(context);
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

  double mapValues(double value) {
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
      temp = 8;
    } else if (value == 8) {
      temp = 9;
    } else if (value == 9) {
      temp = 10;
    } else if (value == 10) {
      temp = 15;
    } else if (value == 11) {
      temp = 20;
    } else if (value == 12) {
      temp = 25;
    } else if (value == 13) {
      temp = 30;
    } else if (value == 14) {
      temp = 35;
    } else if (value == 15) {
      temp = 40;
    } else if (value == 16) {
      temp = 45;
    } else if (value == 17) {
      temp = 50;
    } else if (value == 18) {
      temp = 55;
    } else if (value == 19) {
      temp = 60;
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
            ? Duration(
                seconds: deviceObject.time.inSeconds - deviceObject.timer.tick)
            : Duration(milliseconds: 500));
    deviceObject.progressAnimation = Tween(begin: begin, end: end).animate(
        CurvedAnimation(
            parent: deviceObject.radialProgressAnimationController,
            curve: Curves.linear))
      ..addListener(() {
        setState(() {
          deviceObject.progressDegrees = deviceObject.progressAnimation.value;
          if (deviceObject.motionDetected == true) {
            deviceObject.power = false;
            deviceObject.radialProgressAnimationController.stop();
            deviceObject.timer.cancel();
            deviceObject.radialProgressAnimationController.dispose();
            Future.delayed(const Duration(seconds: 2), () {
              //deviceObject.motionDetected = false;
              Navigator.pop(context);
            });
          }
          if (deviceObject.progressDegrees == 360) {
            deviceObject.power = false;
            deviceObject.radialProgressAnimationController.stop();
            deviceObject.timer.cancel();
          }
        });
        if (deviceObject.progressDegrees == 360) {
          deviceObject.progressDegrees = 0;
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
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

  Future<void> mainTick() async {
    mainTimer = Timer.periodic(Duration(seconds: 1), (callback) {
      if (serverOnline == false || widget.deviceObject.clientError == true) {
        Navigator.pop(context);
      }
    });
  }
}
