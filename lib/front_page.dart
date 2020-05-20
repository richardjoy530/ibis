import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_friendly_name/flutter_device_friendly_name.dart';
import 'package:ibis/height_page.dart';
import 'package:ibis/main.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'data.dart';

List<DeviceObject> deviceObjectList = [];
List<String> ipList = [];
List<Socket> sockets = [];
ServerSocket serverSocket;
bool serverOnline = false;
bool isEnabled = false;
bool isConnected = false;
String serverIp;

final List<bool> isSelected = [false];
Future<void> wifi() async {
  WiFiForIoTPlugin.isEnabled().then((val) {
    if (val != null) {
      isEnabled = val;
      print('Wifi Status:$isEnabled');
      if (isEnabled == false) {
        WiFiForIoTPlugin.setEnabled(true);
        print('Wifi turned on');
      }
    }
  });
  WiFiForIoTPlugin.isConnected().then((val) {
    if (val != null) {
      isConnected = val;
      print('Connected:$isConnected');
    }
  });
  serverIp = await WiFiForIoTPlugin.getIP();
  //WiFiForIoTPlugin.setWiFiAPEnabled(true);
  //WiFiForIoTPlugin.isWiFiAPEnabled().then((value) => print('hotspot status:$value')).catchError((error)=>print('error:$error'));


  /*WiFiForIoTPlugin.setWiFiAPSSIDHidden(true);
  WiFiForIoTPlugin.isWiFiAPSSIDHidden().then((val) {
    if (val != null) {
      print('hidden network:$val');
    }
  }).catchError((val) => print('error hidden:$val'));*/
}

class FrontPage extends StatefulWidget {
  @override
  FrontPageState createState() => FrontPageState();
}

class FrontPageState extends State<FrontPage> with TickerProviderStateMixin {
  Timer timer;
  TextEditingController nameController;
  String _friendlyName = 'Loading...';

  @override
  void initState() {
    FlutterDeviceFriendlyName.friendlyName.then((x) {
      setState(() {
        _friendlyName = x;
      });
    });
    connect();
    nameController = TextEditingController();
    wifi();
    getIpList();
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        for (var i = 0; i < deviceObjectList.length; i++) {
          if (deviceObjectList[i].motionDetected == true &&
              deviceObjectList[i].power == true) {
            deviceObjectList[i].power = false;
            deviceObjectList[i].flare = 'off';
            deviceObjectList[i].timer.cancel();
            deviceObjectList[i].elapsedTime = 0;
            deviceObjectList[i].time = Duration(minutes: 0);
            deviceObjectList[i].mainTime = Duration(minutes: 0);
            deviceObjectList[i].progressDegrees = 0;
          }

          if (deviceObjectList[i].power == true &&
              deviceObjectList[i].pause == false) {
            deviceObjectList[i].linearProgressBarValue =
                (1 / deviceObjectList[i].time.inSeconds) *
                    deviceObjectList[i].elapsedTime;
            if (deviceObjectList[i].elapsedTime >
                deviceObjectList[i].time.inSeconds) {
              deviceObjectList[i].power = false;
              deviceObjectList[i].flare = 'off';
              deviceObjectList[i].timer.cancel();
              deviceObjectList[i].elapsedTime = 0;
              deviceObjectList[i].time = Duration(minutes: 0);
              deviceObjectList[i].mainTime = Duration(minutes: 0);
              deviceObjectList[i].progressDegrees = 0;
            }
          }
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      endDrawer: Drawer(
//        child: Column(
//          children: <Widget>[
//            Container(
//                padding: EdgeInsets.only(top: 140),
//                height: 200,
//                width: 400,
//                color: Colors.lightBlue,
//                child: Column(
//                  children: <Widget>[
//                    FutureBuilder(
//                        future: WiFiForIoTPlugin.getIP(),
//                        initialData: "Loading..",
//                        builder:
//                            (BuildContext context, AsyncSnapshot<String> ip) {
//                          return Text("IP : ${ip.data}",
//                              style: TextStyle(fontSize: 25));
//                        }),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        FutureBuilder(
//                            future: WiFiForIoTPlugin.getBSSID(),
//                            initialData: "Loading..",
//                            builder: (BuildContext context,
//                                AsyncSnapshot<String> bssId) {
//                              return Text("BSSID: ${bssId.data}");
//                            }),
//                        FutureBuilder(
//                            future: WiFiForIoTPlugin.getCurrentSignalStrength(),
//                            initialData: 0,
//                            builder: (BuildContext context,
//                                AsyncSnapshot<int> signal) {
//                              return Text("\t\t\tSignal: ${signal.data}");
//                            }),
//                      ],
//                    ),
//                  ],
//                )),
//            ClayContainer(
//                color: Color(0xffd6e7ee),
//                borderRadius: 20,
//                curveType: CurveType.convex,
//                spread: 2,
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    ListTile(
//                      title: Center(
//                        child: Text(
//                          'Wifi',
//                          style: TextStyle(fontSize: 30),
//                        ),
//                      ),
//                      trailing: ToggleButtons(
//                          children: <Widget>[Icon(Icons.wifi)],
//                          onPressed: (int index) {
//                            setState(() {
//                              isSelected[index] = !isSelected[index];
//                              WiFiForIoTPlugin.setEnabled(isSelected[index]);
//                            });
//                          },
//                          isSelected: isSelected),
//                    )
//                  ],
//                ))
//          ],
//        ),
//      ),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 30,
                      width: 30,
                      child: FlareActor(
                        'assets/status.flr',
                        animation: 'Connected',
                      ),
                    ),
                  ),
                  Expanded(child: Image.asset('images/razecov.jfif')),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      color: Color(0xff019ae6),
                      onPressed: () {
                        onMenuPressed(context);
                      },
                    ),
                  )
                ],
              ),
              serverOnline == true
                  ? deviceObjectList.length == 0
                      ? Center(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xffd6e7ee),
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              leading: Icon(Icons.wifi_tethering),
                              title: Text('Please connect your device!'),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                              itemCount: deviceObjectList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Color(0xffa9d5ea),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ListTile(
                                    leading: Icon(
                                      deviceObjectList[index].offline == true
                                          ? Icons.signal_wifi_off
                                          : Icons.network_wifi,
                                      color: Color(0xff019ae6),
                                    ),
                                    trailing: deviceObjectList[index]
                                                .motionDetected ==
                                            true
                                        ? Icon(
                                            Icons.warning,
                                            color: Color(0xff019ae6),
                                          )
                                        : Visibility(
                                            visible: deviceObjectList[index]
                                                        .offline ==
                                                    false
                                                ? true
                                                : false,
                                            child: IconButton(
                                              icon: Icon(Icons.more_vert,
                                                  color: Color(0xff019ae6)),
                                              onPressed: () {
                                                info(context,
                                                    deviceObjectList[index]);
                                              },
                                            ),
                                          ),
                                    title:
                                        Text('${deviceObjectList[index].name}'),
                                    subtitle: deviceObjectList[index].power ==
                                            false
                                        ? Text(deviceObjectList[index]
                                                    .offline ==
                                                true
                                            ? 'Device is Offline'
                                            : deviceObjectList[index]
                                                        .motionDetected ==
                                                    false
                                                ? 'Device Idle'
                                                : 'Motion Detected : Tap to start again')
                                        : LinearPercentIndicator(
                                            lineHeight: 5.0,
                                            animation: false,
                                            animationDuration: 0,
                                            backgroundColor: Color(0xffd6e7ee),
                                            percent: deviceObjectList[index]
                                                .linearProgressBarValue,
                                            linearStrokeCap:
                                                LinearStrokeCap.roundAll,
                                            progressColor: Color(0xff019ae6),
                                          ),
                                    onTap: () {
                                      if (deviceObjectList[index].offline ==
                                          false) {
                                        if (deviceObjectList[index].power ==
                                            true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                    deviceObjectList[index])),
                                          );
                                        } else {
                                          deviceObjectList[index]
                                              .motionDetected = false;
                                          deviceObjectList[index].time =
                                              Duration(minutes: 0);
                                          deviceObjectList[index]
                                              .progressDegrees = 0;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HeightPage(deviceObjectList[
                                                        index])),
                                          );
                                        }
                                      }
                                    },
                                    onLongPress: () {
                                      setName(context, deviceObjectList[index]);
                                    },
                                  ),
                                );
                              }),
                        )
                  : Align(
                      alignment: Alignment.center,
                      child: AlertDialog(
                        backgroundColor: Color(0xffffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        title: Text(
                          'Server is Offline',
                          style: TextStyle(
                              color: Color(0xff02457a),
                              fontWeight: FontWeight.bold),
                        ),
                        content: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Color(0xff019ae6),
                          ),
                          onPressed: () {
                            connect();
                          },
                        ),
                      ),
                    ),
            ],
          )),
    );
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
              ListTile(
                leading: Icon(
                  Icons.settings_input_composite,
                  color: Color(0xff02457a),
                ),
                title: Text(
                  'Server Ip: $serverIp',
                ),
                subtitle: Text(_friendlyName),
                onTap: () {
                  setState(() {
                    WiFiForIoTPlugin.getIP().then((value) => serverIp = value);
                  });
                  Navigator.pop(context);
                },
              ),
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
              ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Color(0xff02457a),
                  ),
                  title: Text('About')),
            ],
          );
        });
  }

  Future<void> info(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Align(
              alignment: Alignment.center,
              child: Text(
                'Total Runtime',
                style: TextStyle(
                    color: Color(0xff02457a), fontWeight: FontWeight.bold),
              ),
            ),
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                    "${deviceObject.totalDuration.inDays} Days, ${(deviceObject.totalDuration.inSeconds / 3600).floor()} Hours, ${(deviceObject.totalDuration.inSeconds / 60).floor()} Minutes"),
              ),
              Center(
                  child: Text(
                "Health",
                style: TextStyle(
                    color: Color(0xff02457a),
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearPercentIndicator(
                  leading: Text("Lower\t",
                      style: TextStyle(
                          color: Color(0xff02457a),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  center: Text(
                      "${100 - ((deviceObject.totalDuration.inHours / 9000) * 100)}%"),
                  lineHeight: 15.0,
                  percent: 1 - ((deviceObject.totalDuration.inHours) / 9000),
                  progressColor:
                      (deviceObject.totalDuration.inHours / 9000) > .5
                          ? ((deviceObject.totalDuration.inHours / 9000) > .8
                              ? Colors.red
                              : Colors.orange)
                          : Colors.green,
                  curve: Curves.bounceInOut,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearPercentIndicator(
                  leading: Text("Upper\t",
                      style: TextStyle(
                          color: Color(0xff02457a),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  lineHeight: 15.0,
                  center: Text(
                      "${(100 - (((prefs.getInt('${deviceObject.ip}secondDuration') / 3600).floor() / 9000) * 100))}%"),
                  percent: 1 -
                      ((prefs.getInt('${deviceObject.ip}secondDuration') / 3600)
                              .floor() /
                          9000),
                  progressColor:
                      ((prefs.getInt('${deviceObject.ip}secondDuration') / 3600)
                                      .floor() /
                                  9000) >
                              .5
                          ? ((prefs.getInt('${deviceObject.ip}secondDuration') /
                                              3600)
                                          .floor() /
                                      9000) >
                                  .2
                              ? Colors.red
                              : Colors.orange
                          : Colors.green,
                  curve: Curves.bounceInOut,
                ),
              ),
            ],
          );
        });
  }

  Future<void> setName(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Give a name for your device',
              style: TextStyle(
                  color: Color(0xff02457a), fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Enter name'),
                  onSubmitted: (name) {
                    deviceObject.name = nameController.text;
                    prefs.setString('${deviceObject.ip}name', name);
                    nameController.text = '';
                    Navigator.pop(context);
                  },
                ),
              ),
              SimpleDialogOption(
                child: Text('OK'),
                onPressed: () {
                  deviceObject.name = nameController.text;
                  prefs.setString(
                      '${deviceObject.ip}name', nameController.text);
                  nameController.text = '';
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> setHeightYN(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffdec3e4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Do you want height?',
              style: TextStyle(
                  color: Color(0xff83caec), fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Yes'),
                onPressed: () {
                  deviceObject.motionDetected = false;
                  deviceObject.socket.write('2\r');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HeightPage(deviceObject)),
                  );
                },
              ),
              SimpleDialogOption(
                  child: Text('No'),
                  onPressed: () {
                    deviceObject.motionDetected = false;
                    deviceObject.socket.write('-2\r');
                    deviceObject.time = Duration(minutes: 0);
                    deviceObject.progressDegrees = 0;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(deviceObject)),
                    );
                  })
            ],
          );
        });
  }
}
