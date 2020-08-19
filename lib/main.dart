import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ibis/select_time.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'data.dart';
import 'loding.dart';
List<Container> con=[];
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
String dropdownValueRoom = rooms.length == 0 ? 'No rooms' : rooms[0];
String dropdownValueStaff = rooms.length == 0 ? 'No Staff' : workers[0];

final customColor = CustomSliderColors(
  progressBarColor: Color(0xffd6e7ee),
  hideShadow: true,
  trackColor: Color(0xff00477d),
  progressBarColors: [
    Color(0xff00477d),
    Color(0xff008bc0),
    Color(0xff97cadb),
  ],
);
var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
var initializationSettingsIOS = IOSInitializationSettings();
var initializationSettings = InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);
void main() {
  return runApp(MyApp());
}

Future<void> getIpList() async {
  ipList = (prefs.getStringList('iplist')) ?? [];
  for (var eachIp in ipList) {
    deviceName = prefs.getString('${eachIp}name');
    deviceHeight = prefs.getInt('${eachIp}height') ?? 0;
    deviceObjectList.add(DeviceObject(
        offline: true,
        ip: eachIp,
        name: deviceName,
        totalDuration:
            Duration(seconds: prefs.getInt('${eachIp}totalDuration')),
        secondDuration:
            Duration(seconds: prefs.getInt('${eachIp}secondDuration')),
        height: deviceHeight.toDouble()));
  }
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
              totalDuration: Duration(seconds: 0),
              secondDuration: Duration(seconds: 0),
              offline: false,
              socket: clientSocket,
              ip: clientSocket.remoteAddress.address,
              name: 'Device',
              mainTime: Duration(minutes: 0),
              time: Duration(minutes: 0)));

          DeviceObject temp = deviceObjectList.singleWhere(
              (element) => element.ip == clientSocket.remoteAddress.address);

          deviceObjectList[deviceObjectList.indexOf(temp)].run();
          ipList.add(clientSocket.remoteAddress.address);
          SharedPreferences.getInstance().then((prefs) {
            prefs.setStringList('iplist', ipList);
            prefs.setString(
                '${clientSocket.remoteAddress.address}name', 'Device');
            prefs.setInt(
                '${clientSocket.remoteAddress.address}totalDuration', 0);
            prefs.setInt(
                '${clientSocket.remoteAddress.address}secondDuration', 0);
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
          deviceObjectList[deviceObjectList.indexOf(temp)].clientError = false;
          deviceObjectList[deviceObjectList.indexOf(temp)].offline = false;
          deviceObjectList[deviceObjectList.indexOf(temp)].clientError = false;
          deviceObjectList[deviceObjectList.indexOf(temp)].run();
          deviceObjectList[deviceObjectList.indexOf(temp)].time =
              Duration(minutes: 0);
          deviceObjectList[deviceObjectList.indexOf(temp)].mainTime =
              Duration(minutes: 0);
          SharedPreferences.getInstance().then((prefs) {
            deviceObjectList[deviceObjectList.indexOf(temp)].name =
                prefs.getString('${clientSocket.remoteAddress.address}name');
            deviceObjectList[deviceObjectList.indexOf(temp)].totalDuration =
                Duration(
                    seconds: prefs.getInt(
                        '${clientSocket.remoteAddress.address}totalDuration'));
            deviceObjectList[deviceObjectList.indexOf(temp)].secondDuration =
                Duration(
                    seconds: prefs.getInt(
                        '${clientSocket.remoteAddress.address}secondDuration'));
          });
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
      home: Loding(),
    );
  }
}

class HomePage extends StatefulWidget {
  final DeviceObject deviceObject;
  final String status;
  HomePage(this.deviceObject, {this.status = "null"});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double temp;
  Timer mainTimer;
  bool play = false;
  bool errorRemover = false;
  Timer animationTimer;
  @override
  void initState() {
    room = dropdownValueRoom;
    worker = dropdownValueStaff;
    errorRemover = false;
    connectionError = true;
    stopPressed = false;

    temp = 1;
    mainTick();
    if (widget.deviceObject.power == true) {
      runAnimation(
          begin: (360 / (widget.deviceObject.time.inMinutes * 60)) *
              widget.deviceObject.elapsedTime,
          deviceObject: widget.deviceObject,
          end: 360);

      if (widget.deviceObject.pause == false) {
        widget.deviceObject.radialProgressAnimationController.forward();
      }
    }

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    animationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      dotTimer += 1;
      setState(() {
        if (dotTimer % 10 == 0) {
          dotTimer = 0;
          if (dot > 1) {
            dot = 0;
          } else {
            dot += 1;
          }
        }
        if (widget.deviceObject.power == true &&
            widget.deviceObject.pause == false) {
          animationChecking = true;
          animationText = 'Disinfecting';
        } else if (widget.deviceObject.pause == true) {
          animationText = 'Paused';
          animationChecking = false;
        } else if (widget.deviceObject.power == false &&
            widget.deviceObject.pause == false) {
          animationText = 'Ready to Disinfect';
          animationChecking = false;
        }
      });
    });
    super.initState();

    if (widget.status == 'start') {
      start(widget.deviceObject);
    }
  }

  @override
  void dispose() {
    destroyAnimation(widget.deviceObject);
    mainTimer.cancel();
    if (widget.deviceObject.power == false &&
        widget.deviceObject.clientError == false &&
        stopPressed == false) {
      widget.deviceObject.socket.write(65);
    }
    animationTimer.cancel();
    connectionError = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.deviceObject.motionDetected == true) {
    //   motionDetected(context);
    // }
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffffffff), Color(0xffffffff)]),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xff02457a),
                    ),
                    onPressed: () {
                      if (widget.deviceObject.power == false &&
                          widget.deviceObject.clientError == false) {
                        //widget.deviceObject.socket.write(65);
                      }
                      Navigator.pop(context);
                    }),
                Text(
                  widget.deviceObject.name,
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xff02457a),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 30,
                    width: 30,
                    child: FlareActor(
                      'assets/status.flr',
                      animation: widget.deviceObject.power == true &&
                              widget.deviceObject.pause == false
                          ? 'Connected'
                          : 'off',
                    ),
                  ),
                ),
              ],
            ),
            // widget.deviceObject.motionDetected == true
            //     ? Center(
            //       child: AlertDialog(
            //           shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
            //           title: Align(
            //               alignment: Alignment.center,
            //               child: Text('Motion Detected')),
            //           content: Column(
            //             children: <Widget>[
            //               Icon(
            //                 Icons.warning,
            //                 color: Color(0xff02457a),
            //                 size: 50,
            //               ),
            //               Center(
            //                 child: RaisedButton(
            //                   color: Color(0xffd6e7ee),
            //                   child: Center(
            //                     child: Text('OK'),
            //                   ),
            //                   onPressed: () {
            //                     widget.deviceObject.motionDetected = false;
            //                     Navigator.pop(context);
            //                   },
            //                 ),
            //               )
            //             ],
            //           ),
            //         ),
            //     ):
            Expanded(child: tabView(context, widget.deviceObject))
          ],
        ),
      ),
      // floatingActionButton: Container(
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(0.0,250.0,30.0,0.0),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: <Widget>[

      //         FloatingActionButton.extended(
      //           backgroundColor: Color(0xff02457a),
      //           heroTag: 'staff1',
      //           label: DropdownButton<String>(
      //             value: rooms.length == 0 ? 'No rooms' : dropdownValueRoom,
      //             icon: Icon(
      //               Icons.arrow_drop_down,
      //               color: Colors.white,
      //             ),
      //             iconSize: 30,
      //             elevation: 26,
      //             dropdownColor: Color(0xff02457a),
      //             style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 20.0,
      //                 fontWeight: FontWeight.bold),
      //             underline: Container(
      //               height: 0,
      //               color: Colors.deepPurpleAccent,
      //             ),
      //             onChanged: (String newValue) {
      //               setState(() {
      //                 if(widget.deviceObject.power==false)
      //                   {
      //                     dropdownValueRoom = newValue;
      //                     room=dropdownValueRoom;
      //                   }
      //                 else
      //                   {
      //                     Fluttertoast.showToast(
      //                       msg: 'Please Turn off the Machine to change Room',
      //                       gravity: ToastGravity.CENTER,
      //                       toastLength: Toast.LENGTH_SHORT,
      //                       backgroundColor: Colors.blue,
      //                       textColor: Colors.white,
      //                       fontSize: 16.0,
      //                     );
      //                   }

      //               });
      //             },
      //             items: rooms.length == 0
      //                 ? <String>['No rooms']
      //                 .map<DropdownMenuItem<String>>((String value) {
      //               return DropdownMenuItem<String>(
      //                 value: value,
      //                 child: Text(value),
      //               );
      //             }).toList()
      //                 : rooms.map<DropdownMenuItem<String>>((String value) {
      //               return DropdownMenuItem<String>(
      //                 value: value,
      //                 child: Text(value),
      //               );
      //             }).toList(),
      //           ),
      //           onPressed: ()
      //           {

      //           },

      //         ),
      //         FloatingActionButton.extended(
      //           backgroundColor: Color(0xff02457a),
      //           heroTag: 'room1',
      //           label:DropdownButton<String>(
      //             value: workers.length == 0 ? 'No Staff' : dropdownValueStaff,
      //             icon: Icon(
      //               Icons.arrow_drop_down,
      //               color: Colors.white,
      //             ),
      //             iconSize: 30,
      //             elevation: 26,
      //             dropdownColor: Color(0xff02457a),
      //             style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 20.0,
      //                 fontWeight: FontWeight.bold),
      //             underline: Container(
      //               height: 0,
      //               color: Colors.deepPurpleAccent,
      //             ),
      //             onChanged: (String newValue) {
      //               setState(() {
      //                 if(widget.deviceObject.power==false)
      //                   {
      //                     dropdownValueStaff = newValue;
      //                     worker=dropdownValueStaff;

      //                   }
      //                 else{
      //                   Fluttertoast.showToast(
      //                     msg: 'Please Turn off the Machine to change Staff',
      //                     gravity: ToastGravity.CENTER,
      //                     toastLength: Toast.LENGTH_SHORT,
      //                     backgroundColor: Colors.blue,
      //                     textColor: Colors.white,
      //                     fontSize: 16.0,
      //                   );
      //                 }

      //               });
      //             },
      //             items: workers.length == 0
      //                 ? <String>['No Staff']
      //                 .map<DropdownMenuItem<String>>((String value) {
      //               return DropdownMenuItem<String>(
      //                 value: value,
      //                 child: Text(value),
      //               );
      //             }).toList()
      //                 : workers.map<DropdownMenuItem<String>>((String value) {
      //               return DropdownMenuItem<String>(
      //                 value: value,
      //                 child: Text(value),
      //               );
      //             }).toList(),
      //           ),
      //           onPressed: ()
      //           {

      //           },
      //         )

      //       ],
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  startTimer(DeviceObject deviceObject) {
    deviceObject.timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (deviceObject.pause == false) {
        deviceObject.elapsedTime++;
        deviceObject.totalDuration =
            Duration(seconds: deviceObject.totalDuration.inSeconds + 1);
        if (deviceObject.timer.tick.remainder(10) == 0) {
          prefs.setInt('${deviceObject.ip}totalDuration',
              deviceObject.totalDuration.inSeconds);
        }

        if (deviceObject.height > 0) {
          deviceObject.secondDuration =
              Duration(seconds: deviceObject.secondDuration.inSeconds + 1);
          if (deviceObject.timer.tick.remainder(10) == 0) {
            prefs.setInt('${deviceObject.ip}secondDuration',
                deviceObject.secondDuration.inSeconds);
          }
        }
      }
    });
  }

  void onMenuPressed(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        builder: (context) {
          return Wrap(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(200.0, 10, 200, 10),
                  child: Divider(thickness: 2, color: Colors.grey[500])),
              // ListTile(
              //   leading: Icon(
              //     Icons.settings_input_composite,
              //     color: Color(0xff02457a),
              //   ),
              //   title: Text(
              //     'Server Ip: $serverIp',
              //   ),
              //   subtitle: Text('Refresh'),
              //   onTap: () {
              //     setState(() {
              //       WiFiForIoTPlugin.getIP().then((value) => serverIp = value);
              //     });
              //     Navigator.pop(context);
              //   },
              // ),
              ListTile(
                leading: Icon(
                  isEnabled == true
                      ? Icons.signal_wifi_4_bar
                      : Icons.signal_wifi_off,
                  color: Color(0xff02457a),
                ),
                title: Text(
                  isEnabled == true ? 'Tap to disconnect' : 'Tap to connect',
                ),
                onTap: () {
                  setState(() {
                    WiFiForIoTPlugin.setEnabled(!isEnabled);
                    isEnabled = !isEnabled;
                    Navigator.pop(context);
                  });
                },
              ),
              // ListTile(
              //     leading: Icon(
              //       Icons.info_outline,
              //       color: Color(0xff02457a),
              //     ),
              //     title: Text('About')),
            ],
          );
        });
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
                animation:
                    deviceObject.power == true && deviceObject.pause == false
                        ? 'off'
                        : 'breath',
              ),
              CustomPaint(
                child: Container(
                  height: min(MediaQuery.of(context).size.height / 1.5,
                      MediaQuery.of(context).size.width / 1.5),
                  width: min(MediaQuery.of(context).size.height / 1.5,
                      MediaQuery.of(context).size.width / 1.5),
                  child: Center(
                    child: Container(
                      height: (MediaQuery.of(context).size.width / 1.5) - 50,
                      width: (MediaQuery.of(context).size.width / 1.5) - 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  '$animationText',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          deviceObject.motionDetected == false
                                              ? Colors.black
                                              : Colors.red),
                                ),
                                Visibility(
                                  visible: animationChecking,
                                  child: new DotsIndicator(
                                    dotsCount: 3,
                                    position: dot,
                                    decorator: DotsDecorator(
                                      size: const Size.square(9.0),
                                      activeSize: const Size(18.0, 9.0),
                                      activeShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            '${getMinuets(((deviceObject.time.inSeconds) - deviceObject.elapsedTime).round())}'
                            ':${getSeconds(((deviceObject.time.inSeconds) - deviceObject.elapsedTime).round())}',
                            style: TextStyle(fontSize: 40),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              deviceObject.power == false
                  ? SleekCircularSlider(
                      min: 0,
                      max: 21,
                      initialValue: 0,
                      appearance: CircularSliderAppearance(
                          animationEnabled: false,
                          startAngle: 270,
                          angleRange: 359,
                          customWidths: CustomSliderWidths(
                            handlerSize: 20,
                            trackWidth: 5,
                            progressBarWidth: 20,
                          ),
                          size: (MediaQuery.of(context).size.width / 1.5) + 50,
                          customColors: customColor),
                      onChange: (double value) {
                        displayTime = value.floor();
                        if (deviceObject.power == false &&
                            errorRemover == true &&
                            isConnected == true &&
                            widget.deviceObject.clientError == false) {
                          setState(() {
                            deviceObject.mainTime = Duration(
                                minutes:
                                    mapValues(displayTime.toDouble()).toInt());
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
                      max: 360,
                      initialValue: 360 - deviceObject.progressDegrees,
                      appearance: CircularSliderAppearance(
                          animationEnabled: false,
                          startAngle: 270,
                          angleRange: 360,
                          customWidths: CustomSliderWidths(
                            trackWidth: 5,
                            progressBarWidth: 20,
                          ),
                          size: (MediaQuery.of(context).size.width / 1.5) + 50,
                          customColors: customColor),
                      innerWidget: (value) {
                        return null;
                      },
                    )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 50),
          height: 100,
          child: deviceObject.power == false
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Container(
                          margin: EdgeInsets.all(20),
                          child: Text(
                            'Start',
                            style: TextStyle(
                                fontSize: 20, color: Color(0xff02457a)),
                          )),
                      onPressed: () {
                        if (deviceObject.time.inMinutes != 0) {
                          start(deviceObject);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Color(0xff5cbceb),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Stop ',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xffffffff)),
                        ),
                      ),
                      onPressed: () {
                        confirmStop(context, deviceObject);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Color(0xff02457a),
                    ),
                    RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          deviceObject.pause == true ? 'Play ' : 'Pause',
                          style: TextStyle(
                              fontSize: 20, color: Color(0xffffffff)),
                        ),
                      ),
                      onPressed: () {
                        playPause(deviceObject);
                      },
                      color: Color(0xff02457a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    )
                  ],
                ),
        )
      ],
    );
  }

  void start(DeviceObject deviceObject) {
    // Start
    deviceObject.flare = 'on';
    //deviceObject.temp = false;
    startTime = DateTime.now();
    deviceObject.socket.writeln(deviceObject.time.inMinutes.round());
    deviceObject.elapsedTime = 0;
    deviceObject.progressDegrees = 0;
    deviceObject.power = true;
    startTimer(deviceObject);
    runAnimation(deviceObject: deviceObject);
    deviceObject.radialProgressAnimationController.forward();
    databaseHelper.insertHistory(History(
        roomName: room,
        workerName: worker,
        state: 'Started with ${deviceObject.time.inMinutes} mins',
        time: DateTime.now()));
    historyList.add(
      History(
        roomName: room,
        workerName: worker,
        state: 'Started with ${deviceObject.time.inMinutes} mins',
        time: DateTime.now(),
      ),
    );
  }

  void playPause(DeviceObject deviceObject) {
    print('Pause/Play');
    if (deviceObject.pause == false) {
      //Pause
      databaseHelper.insertHistory(History(
          roomName: room,
          workerName: worker,
          state: 'Paused',
          time: DateTime.now()));
      historyList.add(
        History(
          roomName: room,
          workerName: worker,
          state: 'Paused',
          time: DateTime.now(),
        ),
      );

      prefs.setInt('${deviceObject.ip}totalDuration',
          deviceObject.totalDuration.inSeconds);
      prefs.setInt('${deviceObject.ip}secondDuration',
          deviceObject.secondDuration.inSeconds);
      deviceObject.flare = 'pause';
      deviceObject.pause = true;
      deviceObject.timer.cancel();
      deviceObject.socket.write('h');
      deviceObject.radialProgressAnimationController.stop();
    } else {
      //Play
      databaseHelper.insertHistory(History(
          roomName: room,
          workerName: worker,
          state: 'Resumed',
          time: DateTime.now()));
      historyList.add(
        History(
          roomName: room,
          workerName: worker,
          state: 'Resumed',
          time: DateTime.now(),
        ),
      );

      deviceObject.pause = false;
      startTimer(deviceObject);
      deviceObject.flare = 'play';
      deviceObject.socket.write('p');
      deviceObject.radialProgressAnimationController.forward();
    }
  }

  double mapValues(double value) {
    if (value == 0) {
      temp = 0;
    } else if (value == 1) {
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
      temp = 6;
    } else if (value == 7) {
      temp = 7;
    } else if (value == 8) {
      temp = 8;
    } else if (value == 9) {
      temp = 9;
    } else if (value == 10) {
      temp = 10;
    } else if (value == 11) {
      temp = 15;
    } else if (value == 12) {
      temp = 20;
    } else if (value == 13) {
      temp = 25;
    } else if (value == 14) {
      temp = 30;
    } else if (value == 15) {
      temp = 35;
    } else if (value == 16) {
      temp = 40;
    } else if (value == 17) {
      temp = 45;
    } else if (value == 18) {
      temp = 50;
    } else if (value == 19) {
      temp = 55;
    } else if (value == 20) {
      temp = 60;
    } else if (value == 21) {
      temp = 60;
    }
    return temp;
  }

  runAnimation(
      {double begin = 0.0, double end = 360.0, DeviceObject deviceObject}) {
    deviceObject.radialProgressAnimationController = AnimationController(
        vsync: this,
        duration: Duration(
            seconds: deviceObject.time.inSeconds -
                (deviceObject.timer != null ? deviceObject.timer.tick : 0)));
    animationRunning = true;

    deviceObject.progressAnimation = Tween(begin: begin, end: end).animate(
      CurvedAnimation(
          parent: deviceObject.radialProgressAnimationController,
          curve: Curves.linear),
    )..addListener(
        () {
          setState(
            () {
              deviceObject.progressDegrees =
                  deviceObject.progressAnimation.value;
              if (deviceObject.motionDetected == true) {
                motionDetected(context);
                prefs.setInt('${deviceObject.ip}totalDuration',
                    deviceObject.totalDuration.inSeconds);
                prefs.setInt('${deviceObject.ip}secondDuration',
                    deviceObject.secondDuration.inSeconds);
                errorRemover = false;
                deviceObject.flare = 'off';
                print('state3');
                deviceObject.resetingheight = true;
                deviceObject.elapsedTime = 0;
                deviceObject.radialProgressAnimationController.stop();
                deviceObject.timer.cancel();
                deviceObject.pause = false;
                deviceObject.time = Duration(minutes: 0);
                deviceObject.mainTime = Duration(minutes: 0);
                deviceObject.power = false;
              }
              if (deviceObject.progressDegrees == 360) {
                databaseHelper.insertTimeData(
                  TimeData(
                      roomName: room,
                      workerName: worker,
                      startTime: startTime,
                      endTime: DateTime.now(),
                      elapsedTime: deviceObject.elapsedTime,
                      time: deviceObject.time.inSeconds.toInt()),
                );
                timeDataList.add(
                  TimeData(
                      roomName: room,
                      workerName: worker,
                      startTime: startTime,
                      endTime: DateTime.now(),
                      elapsedTime: deviceObject.elapsedTime,
                      time: deviceObject.time.inSeconds.toInt()),
                );
                databaseHelper.insertHistory(
                  History(
                    roomName: room,
                    workerName: worker,
                    state: 'Finished',
                    time: DateTime.now(),
                  ),
                );
                historyList.add(
                  History(
                    roomName: room,
                    workerName: worker,
                    state: 'Finished',
                    time: DateTime.now(),
                  ),
                );

                prefs.setInt('${deviceObject.ip}totalDuration',
                    deviceObject.totalDuration.inSeconds);
                prefs.setInt('${deviceObject.ip}secondDuration',
                    deviceObject.secondDuration.inSeconds);
                deviceObject.power = false;
                errorRemover = false;
                deviceObject.radialProgressAnimationController.stop();
                deviceObject.timer.cancel();
                deviceObject.pause = false;
                deviceObject.flare = 'off';
                print('state4');

                deviceObject.elapsedTime = 0;
                deviceObject.time = Duration(minutes: 0);
                deviceObject.mainTime = Duration(minutes: 0);
              }
            },
          );
          if (deviceObject.progressDegrees == 360) {
            deviceObject.progressDegrees = 0;
            overOver(context);
          }
        },
      );
  }

  destroyAnimation(DeviceObject deviceObject) {
    if (animationRunning == true) {
      deviceObject.radialProgressAnimationController.dispose();
      animationRunning = false;
    }
  }

  getSeconds(int seconds) {
    var f = new NumberFormat("00", "en_US");
    return f.format(seconds % 60);
  }

  getMinuets(int seconds) {
    var f = new NumberFormat("00", "en_US");
    return f.format(
      (seconds / 60).floor(),
    );
  }

  Future<void> motionDetected(context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Color(0xffffffff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          children: <Widget>[
            Center(
              child: Text(
                'Motion Detected',
                style: TextStyle(
                    color: Color(0xff02457a),
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
            Icon(
              Icons.warning,
              color: Color(0xff02457a),
              size: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleDialogOption(
                child: Center(
                  child: Text(
                    'OK',
                  ),
                ),
                onPressed: () {
                  widget.deviceObject.motionDetected = false;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> overOver(context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Color(0xffffffff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
            child: Text(
              'Succesfully completed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff02457a),
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
          ),
          children: <Widget>[
            Center(
              child: Text(
                'Continue disinfecting ?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 20),
              ),
            ),
            SimpleDialogOption(
              child: Center(child: Text('yes', textAlign: TextAlign.center)),
              onPressed: () {
                widget.deviceObject.clientError = false;

                widget.deviceObject.socket.write('y\r');
                errorRemover = true;
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Center(child: Text('No')),
              onPressed: () {
                widget.deviceObject.clientError = false;
                widget.deviceObject.resetingheight = true;
                widget.deviceObject.socket.write('n\r');
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmStop(context, DeviceObject deviceObject) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Color(0xffffffff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
            child: Text(
              'Turn off ?',
              style: TextStyle(
                  color: Color(0xff02457a), fontWeight: FontWeight.bold),
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Center(
                child: Text('YES'),
              ),
              onPressed: () {
                print('stop');
                databaseHelper.insertTimeData(
                  TimeData(
                      roomName: room,
                      workerName: worker,
                      startTime: startTime,
                      endTime: DateTime.now(),
                      elapsedTime: deviceObject.elapsedTime,
                      time: deviceObject.time.inSeconds.toInt()),
                );
                timeDataList.add(
                  TimeData(
                      roomName: room,
                      workerName: worker,
                      startTime: startTime,
                      endTime: DateTime.now(),
                      elapsedTime: deviceObject.elapsedTime,
                      time: deviceObject.time.inSeconds.toInt()),
                );
                databaseHelper.insertHistory(
                  History(
                    roomName: room,
                    workerName: worker,
                    state: 'Stopped',
                    time: DateTime.now(),
                  ),
                );
                historyList.add(
                  History(
                    roomName: room,
                    workerName: worker,
                    state: 'Stopped',
                    time: DateTime.now(),
                  ),
                );
                con.add(Container(
                  width: 45,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: widget.deviceObject.elapsedTime/60,
                    groupsSpace: 40,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: const EdgeInsets.all(0),
                        tooltipBottomMargin: 8,
                        getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                            ) {
                          return BarTooltipItem(
                            rod.y.round().toString(),
                            TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: const Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 20,
                        getTitles: (double value) {
                          String dateTimeNow=DateTime.now().hour.toString();
                          dateTimeNow+=':';
                          dateTimeNow+=DateTime.now().minute.toString();
                          return dateTimeNow;
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: [BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          y: widget.deviceObject.elapsedTime/60,
                          color: Colors.lightBlueAccent),
                    ], showingTooltipIndicators: [
                      0
                    ])],
                  )),
                ));
                stopPressed = true;
                prefs.setInt('${deviceObject.ip}totalDuration',
                    deviceObject.totalDuration.inSeconds);
                prefs.setInt('${deviceObject.ip}secondDuration',
                    deviceObject.secondDuration.inSeconds);
                deviceObject.pause = false;
                errorRemover = false;
                deviceObject.elapsedTime = 0;
                deviceObject.flare = 'off';
                print('state5');
                destroyAnimation(deviceObject);
                deviceObject.resetingheight = true;
                deviceObject.socket.write('s');
                deviceObject.power = false;
                deviceObject.time = Duration(minutes: 0);
                deviceObject.mainTime = Duration(minutes: 0);
                deviceObject.timer.cancel();
                deviceObject.progressDegrees = 0;
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Center(
                child: Text('NO'),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> mainTick() async {
    mainTimer = Timer.periodic(
      Duration(seconds: 1),
      (callback) {
        WiFiForIoTPlugin.getIP().then(
          (value) {
            if (value != serverIp && connectionError == false) {
              connectionError = true;
              widget.deviceObject.motionDetected = false;
              widget.deviceObject.flare = 'off';
              print('state6');

              widget.deviceObject.offline = true;
              widget.deviceObject.pause = false;
              widget.deviceObject.power = false;

              widget.deviceObject.progressDegrees = 0;
              widget.deviceObject.elapsedTime = 0;
              print('off1');
              widget.deviceObject.timer.cancel();
              destroyAnimation(widget.deviceObject);
              errorRemover = false;
              Navigator.pop(context);
            }
          },
        );
        if (widget.deviceObject.socket == null) {
          Navigator.pop(context);
        }
        if ((serverOnline == false ||
                widget.deviceObject.clientError == true) &&
            connectionError == false) {
          connectionError = true;
          widget.deviceObject.motionDetected = false;
          widget.deviceObject.flare = 'off';
          print('state7');
          widget.deviceObject.offline = true;
          widget.deviceObject.pause = false;
          widget.deviceObject.progressDegrees = 0;
          widget.deviceObject.elapsedTime = 0;
          print('off2');
          if (widget.deviceObject.timer != null) {
            widget.deviceObject.timer.cancel();
          }
          destroyAnimation(widget.deviceObject);
          widget.deviceObject.power = false;

          errorRemover = false;
          Navigator.pop(context);
        }
      },
    );
  }
}
