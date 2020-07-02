import 'dart:async';
import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:ibis/height_page.dart';
import 'package:ibis/main.dart';
import 'package:ibis/show_history.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'calender.dart';
import 'data.dart';
import 'show_rooms_workers.dart';
Future<void> scanIbis() async
{
  String cameraScanResult = await scanner.scan();
  var data=cameraScanResult.split(',');
  String ssid=data[1];
  String password=data[3];
  WiFiForIoTPlugin.connect(ssid,
      password: password,
      joinOnce: true,
      security: NetworkSecurity.WPA);
  WiFiForIoTPlugin.isConnected().then((value) => isConnected=value );
  if(isConnected==true)
  {
    prefs.setString('SSID', ssid);
    prefs.setString('password', password);
  }
}

Future<void> wifi() async {
  WiFiForIoTPlugin.isEnabled().then(
    (val) {
      if (val != null) {
        isEnabled = val;
        print('Wifi Status:$isEnabled');
        if (isEnabled == false) {
          WiFiForIoTPlugin.setEnabled(true);
          print('Wifi turned on');
        }
      }
    },
  );
  WiFiForIoTPlugin.isConnected().then(
    (val) {
      if (val != null) {
        isConnected = val;
        print('Connected:$isConnected');
      }
      if(val==true)
        {
          WiFiForIoTPlugin.disconnect();
          WiFiForIoTPlugin.connect(prefs.getString('SSID'),
              password: prefs.getString('password'),
              joinOnce: true,
              security: NetworkSecurity.WPA);
        }
      if (val != true) {
        WiFiForIoTPlugin.connect(prefs.getString('SSID'),
                password: prefs.getString('password'),
                joinOnce: true,
                security: NetworkSecurity.WPA)
            .then(
          (value) {},
        );
      }
    },
  );

  serverIp = await WiFiForIoTPlugin.getIP();
}

class FrontPage extends StatefulWidget {
  @override
  FrontPageState createState() => FrontPageState();
}

class FrontPageState extends State<FrontPage> with TickerProviderStateMixin {
  Timer timer;
  TextEditingController nameController;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    connect();
    nameController = TextEditingController();
    getIpList();
    timer = Timer.periodic(
      Duration(milliseconds: 100),
      (callback) {
        setState(
          () {
            for (var i = 0; i < deviceObjectList.length; i++) {
              if ((deviceObjectList[i].motionDetected == true ||
                      deviceObjectList[i].clientError == true) &&
                  deviceObjectList[i].power == true) {
                deviceObjectList[i].power = false;
                deviceObjectList[i].pause = false;

                prefs.setInt('${deviceObjectList[i].ip}totalDuration',
                    deviceObjectList[i].totalDuration.inSeconds);
                prefs.setInt('${deviceObjectList[i].ip}secondDuration',
                    deviceObjectList[i].secondDuration.inSeconds);
                print('state1');
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
                if ((deviceObjectList[i].elapsedTime >
                    deviceObjectList[i].time.inSeconds)) {
                  prefs.setInt('${deviceObjectList[i].ip}totalDuration',
                      deviceObjectList[i].totalDuration.inSeconds);
                  prefs.setInt('${deviceObjectList[i].ip}secondDuration',
                      deviceObjectList[i].secondDuration.inSeconds);

                  deviceObjectList[i].power = false;
                  deviceObjectList[i].completedStatus = true;
                  deviceObjectList[i].linearProgressBarValue = 0.0;

                  deviceObjectList[i].pause = false;
                  deviceObjectList[i].flare = 'off';
                  print('state2');

                  deviceObjectList[i].timer.cancel();
                  deviceObjectList[i].elapsedTime = 0;
                  deviceObjectList[i].time = Duration(minutes: 0);
                  deviceObjectList[i].mainTime = Duration(minutes: 0);
                  deviceObjectList[i].progressDegrees = 0;
                }
              }
            }
          },
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    timer.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit the App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 30,
                    width: 30,
                    child: FlareActor(
                      'assets/status.flr',
                      animation: 'off',
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
                            physics: BouncingScrollPhysics(),
                            controller: scrollController,
                            itemCount: deviceObjectList.length,
                            itemBuilder: (context, index) {
                              if (deviceObjectList[index].name == 'Device') {
                                deviceObjectList[index].name = '';
                                nameIt(context, deviceObjectList[index]);
                              }
                              if (deviceObjectList[index]
                                      .earlyMotionDetection ==
                                  true) {
                                deviceObjectList[index].earlyMotionDetection =
                                    false;
                                earlyMotionDetection(
                                    context, deviceObjectList[index]);
                              }
                              if (deviceObjectList[index].completedStatus ==
                                  true) {
                                deviceObjectList[index].completedStatus = false;
                                completedPop(context, deviceObjectList[index]);
                              }
                              return Column(
                                children: <Widget>[
                                  Container(
                                    //margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xffbddeee),
                                      //borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        deviceObjectList[index].offline == true
                                            ? Icons.signal_wifi_off
                                            : Icons.network_wifi,
                                        color: Color(0xff02457a),
                                      ),
                                      trailing: deviceObjectList[index]
                                                  .motionDetected ==
                                              true
                                          ? Icon(
                                              Icons.warning,
                                              color: Color(0xff02457a),
                                            )
                                          : IconButton(
                                              icon: Icon(Icons.more_vert,
                                                  color: Color(0xff02457a)),
                                              onPressed: () {
                                                info(context,
                                                    deviceObjectList[index]);
                                              },
                                            ),
                                      title: Text(
                                          '${deviceObjectList[index].name}'),
                                      subtitle: deviceObjectList[index].power ==
                                              false
                                          ? Text(
                                              deviceObjectList[index].offline ==
                                                      true
                                                  ? 'Device not Connected'
                                                  : deviceObjectList[index]
                                                              .motionDetected ==
                                                          false
                                                      ? 'Device Connected'
                                                      : 'Motion Detected')
                                          : LinearPercentIndicator(
                                              lineHeight: 5.0,
                                              animation: false,
                                              animationDuration: 0,
                                              backgroundColor:
                                                  Color(0xff9ad2ec),
                                              percent: deviceObjectList[index]
                                                  .linearProgressBarValue,
                                              linearStrokeCap:
                                                  LinearStrokeCap.roundAll,
                                              progressColor: Color(0xff019ae6),
                                            ),
                                      onTap: () {},
                                      onLongPress: () {
                                        setName(
                                          context,
                                          deviceObjectList[index],
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0xff9ad2ec),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.lightbulb_outline,
                                        color: Color(0xff02457a),
                                      ),
                                      title: Text(
                                          deviceObjectList[index].power == false
                                              ? 'Disinfect'
                                              : deviceObjectList[index].pause ==
                                                      true
                                                  ? 'Paused'
                                                  : 'Disinfecting'),
                                      subtitle: Text(
                                          'Device: ${deviceObjectList[index].offline == true ? 'Not connected' : deviceObjectList[index].name}'),
                                      onTap: () {
                                        if (deviceObjectList[index].offline ==
                                            false) {
                                          if (deviceObjectList[index].power ==
                                              true) {
                                            deviceObjectList[index]
                                                .clientError = false;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                  deviceObjectList[index],
                                                ),
                                              ),
                                            );
                                          } else {
                                            deviceObjectList[index]
                                                .motionDetected = false;
                                            deviceObjectList[index].time =
                                                Duration(minutes: 0);
                                            deviceObjectList[index]
                                                .progressDegrees = 0;
                                            if (rooms.length != 0) {
                                              if (workers.length != 0) {
                                                showRooms(
                                                  context,
                                                  deviceObjectList[index],
                                                );
                                              } else {
                                                addWorker(context);
                                              }
                                            } else {
                                              addRooms(context);
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0xff9ad2ec),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: ListTile(
                                      leading: Image.asset('images/sort.png',color: Color(0xff02457a),width: 25,),
                                      title: Text('Adjust Height'),
                                      subtitle: Text(
                                          'Device: ${deviceObjectList[index].offline == true ? 'Not connected' : deviceObjectList[index].name}'),
                                      onTap: () {
                                        if (deviceObjectList[index].offline ==
                                            false) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HeightPage(
                                                deviceObjectList[index],
                                                justHeight: true,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0xff9ad2ec),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.history,
                                        color: Color(0xff02457a),
                                      ),
                                      title: Text('Show History'),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ShowHistory(),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
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
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton.extended(
              backgroundColor: Color(0xff02457a),
              heroTag: 'hero1',
              label: Text(
                'Staff',
                style: TextStyle(fontSize: 20, color: Color(0xffffffff)),
              ),
              icon: Icon(Icons.add, color: Color(0xffffffff)),
              onPressed: () {
                addWorker(context);
              },
            ),
            FloatingActionButton.extended(
              backgroundColor: Color(0xff02457a),
              heroTag: 'hero2',
              label: Text('Room',
                  style: TextStyle(fontSize: 20, color: Color(0xffffffff))),
              icon: Icon(Icons.add, color: Color(0xffffffff)),
              onPressed: () {
                addRooms(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> addRooms(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Rooms();
        });
  }

  Future<void> addWorker(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Workers();
        });
  }

  Future<void> showRooms(context, DeviceObject deviceObject) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Select a Room',
            style: TextStyle(
                color: Color(0xff02457a), fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                rooms.length,
                (index) {
                  return SimpleDialogOption(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.label_outline,
                          color: Color(0xff02457a),
                        ),
                        title: Text(rooms[index],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    onPressed: () {
                      room = rooms[index];
                      Navigator.pop(context);
                      showWorkers(context, deviceObject);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showWorkers(context, DeviceObject deviceObject) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Select a Staff',
            style: TextStyle(
                color: Color(0xff02457a), fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                workers.length,
                (index) {
                  return SimpleDialogOption(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.label_outline,
                          color: Color(0xff02457a),
                        ),
                        title: Text(workers[index],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    onPressed: () {
                      deviceObject.clientError = false;
                      worker = workers[index];
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HeightPage(deviceObject)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
              //  ListTile(
              //     leading: Icon(
              //       Icons.settings_input_composite,
              //       color: Color(0xff02457a),
              //     ),
              //     title: Text(
              //       'Server Ip: $serverIp',
              //     ),
              //     subtitle: FutureBuilder(
              //         future: WiFiForIoTPlugin.getSSID(),
              //         initialData: "Loading..",
              //         builder:
              //             (BuildContext context, AsyncSnapshot<String> bssid) {
              //           return Text("BSSID: ${bssid.data}");
              //         }),
              //     onTap: () {
              //       setState(() {
              //         WiFiForIoTPlugin.getIP().then((value) => serverIp = value);
              //       });
              //       Navigator.pop(context);
              //     },
              //   ),
              ListTile(
                leading: Icon(
                  Icons.view_list,
                  color: Color(0xff02457a),
                ),
                title: Text('Show Rooms/Staffs'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowRoomsStaffs()));
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
                title: Text('History'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CalenderPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.scatter_plot
                ),
                title: Text('QR Scanner'),
                onTap: ()
                {
                  scanIbis();
                },
              ),
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
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Total Runtime',
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff02457a),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                    "${deviceObject.totalDuration.inDays} Days, ${deviceObject.totalDuration.inHours.remainder(24)} Hours, ${deviceObject.totalDuration.inMinutes.remainder(60)} Minutes"),
              ),
              Center(
                child: Text(
                  "Health",
                  style: TextStyle(
                      color: Color(0xff02457a),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: LinearPercentIndicator(
                  leading: Text("Upper",
                      style: TextStyle(
                          color: Color(0xff02457a),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  lineHeight: 5.0,
                  trailing: Text(
                      "${(100 - ((deviceObject.secondDuration.inHours / 9000) * 100)).floor()}%"),
                  percent: 1 - deviceObject.secondDuration.inHours / 9000,
                  backgroundColor: Colors.grey[300],
                  progressColor: deviceObject.secondDuration.inHours / 9000 > .5
                      ? deviceObject.secondDuration.inHours / 9000 > .2
                          ? Colors.red
                          : Colors.orange
                      : Colors.green,
                  curve: Curves.bounceInOut,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: LinearPercentIndicator(
                  leading: Text("Lower",
                      style: TextStyle(
                          color: Color(0xff02457a),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  trailing: Text(
                      "${(100 - ((deviceObject.totalDuration.inHours / 9000) * 100)).floor()}%"),
                  lineHeight: 5.0,
                  percent: 1 - (deviceObject.totalDuration.inHours) / 9000,
                  backgroundColor: Colors.grey[300],
                  progressColor: deviceObject.totalDuration.inHours / 9000 > .5
                      ? deviceObject.totalDuration.inHours / 9000 > .8
                          ? Colors.red
                          : Colors.orange
                      : Colors.green,
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
                  if (nameController.text != '') {
                    deviceObject.name = nameController.text;
                    prefs.setString(
                        '${deviceObject.ip}name', nameController.text);
                    nameController.text = '';
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> showingMotion(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titlePadding: EdgeInsets.all(25),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Motion detected while disconnected ',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '${deviceObject.earlyMotionDetectionTime} mins completed',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                Icon(Icons.warning, color: Color(0xff02457a))
              ],
            ),
          );
        });
  }

  Future<void> overOver(context, DeviceObject deviceObject) async {
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
                deviceObject.clientError = false;
                deviceObject.time = Duration(minutes: 0);
                //deviceObject.temp = true;
                deviceObject.elapsedTime = 0;
                deviceObject.clientError = false;
                isConnected = true;

                deviceObject.socket.write('y\r');
                //errorRemover = true;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(deviceObject)),
                );
              },
            ),
            SimpleDialogOption(
              child: Center(child: Text('No')),
              onPressed: () {
                deviceObject.clientError = false;

                deviceObject.socket.write('n\r');
                Navigator.pop(context);
                //Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showingCompletedPop(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            titlePadding: EdgeInsets.all(25),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${deviceObject.name} Completed disinfecting',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
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

  Future<void> earlyMotionDetection(
      BuildContext context, DeviceObject deviceObject) async {
    Future.delayed(Duration(milliseconds: 300), () {
      showingMotion(context, deviceObject);
    });
  }

  Future<void> completedPop(
      BuildContext context, DeviceObject deviceObject) async {
    Future.delayed(Duration(milliseconds: 300), () {
      overOver(context, deviceObject);
    });
  }

  Future<void> nameIt(BuildContext context, DeviceObject deviceObject) async {
    Future.delayed(Duration(milliseconds: 300), () {
      setName(context, deviceObject);
    });
  }
}

class Rooms extends StatefulWidget {
  @override
  _RoomsState createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
  List<String> cText = [];
  List<TextEditingController> roomNames = [];
  @override
  void initState() {
    nameNumber = 1;
    roomNames.add(TextEditingController());
    cText.add('');
    super.initState();
  }

  @override
  void dispose() {
    for (var j = 0; j < roomNames.length; j++) {
      roomNames[j].dispose();
    }
    cText = [];
    roomNames = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          title: Center(
            child: Text(
              'Add Room',
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff02457a),
                  fontWeight: FontWeight.bold),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Container(
                height: MediaQuery.of(context).size.height /
                    (7 - nameNumber + screenLengthConstant),
                width: MediaQuery.of(context).size.width * 0.7,
                child: ListView.builder(
                  itemCount: nameNumber,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: TextField(
                        controller: roomNames[index],
                        onChanged: (data) {
                          setState(() {
                            if (roomNames[index].text.length == 0) {
                              cText[index] = 'Enter Name';
                            } else {
                              cText[index] = '';
                            }
                          });
                        },
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: 'Room Name',
                          counterText: cText[index],
                          counterStyle:
                              TextStyle(color: Colors.red, fontSize: 15),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: cText[index] == ''
                                      ? Colors.red
                                      : Colors.blue)),
                          labelStyle: TextStyle(
                              fontSize: 20,
                              color: cText[index] == 'Enter Name'
                                  ? Colors.red
                                  : Colors.blue),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SimpleDialogOption(
              child: ListTile(
                leading: Container(
                  decoration: ShapeDecoration(
                      shape: CircleBorder(), color: Colors.blue),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      setState(
                        () {
                          cText.add('');
                          roomNames.add(TextEditingController());
                          nameNumber += 1;
                          if (nameNumber > 4) {
                            screenLengthConstant += 1;
                          }
                        },
                      );

                      print(nameNumber);
                    },
                  ),
                ),
                trailing: Container(
                  decoration: ShapeDecoration(
                      shape: CircleBorder(), color: Colors.blue),
                  child: IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        int check = 0, i;
                        for (i = 0; i < nameNumber; i++) {
                          if (roomNames[i].text.length < 1) {
                            check += 1;
                            cText[i] = 'Enter Name';
                          }
                        }
                        if (check == 0) {
                          for (i = 0; i < nameNumber; i++) {
                            if (roomNames[i].text.length > 0) {
                              databaseHelper.insertRoom(roomNames[i].text);
                              rooms.add(roomNames[i].text);
                            }
                          }
                          nameNumber = 1;
                          Fluttertoast.showToast(
                            msg: 'Successfully Added',
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class Workers extends StatefulWidget {
  @override
  _WorkersState createState() => _WorkersState();
}

class _WorkersState extends State<Workers> {
  List<String> cText = [];
  List<TextEditingController> roomNames = [];
  @override
  void initState() {
    nameNumber = 1;
    roomNames.add(TextEditingController());
    cText.add('');
    super.initState();
  }

  @override
  void dispose() {
    for (var j = 0; j < roomNames.length; j++) {
      roomNames[j].dispose();
    }
    cText = [];
    roomNames = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          title: Center(
            child: Text(
              'Add Staff',
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff02457a),
                  fontWeight: FontWeight.bold),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Container(
                height: MediaQuery.of(context).size.height /
                    (7 - nameNumber + screenLengthConstant),
                width: MediaQuery.of(context).size.width * 0.7,
                child: ListView.builder(
                  itemCount: nameNumber,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: TextField(
                        controller: roomNames[index],
                        onChanged: (stafData) {
                          setState(() {
                            if (roomNames[index].text.length == 0) {
                              cText[index] = 'Enter Name';
                            } else {
                              cText[index] = '';
                            }
                          });
                        },
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          counterText: cText[index],
                          counterStyle:
                              TextStyle(color: Colors.red, fontSize: 15),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: cText[index] == ''
                                      ? Colors.red
                                      : Colors.blue)),
                          labelText: 'Staff Name',
                          labelStyle: TextStyle(
                              fontSize: 20,
                              color: cText[index] == 'Enter Name'
                                  ? Colors.red
                                  : Colors.blue),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SimpleDialogOption(
              child: ListTile(
                leading: Container(
                  decoration: ShapeDecoration(
                      shape: CircleBorder(), color: Colors.blue),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      setState(
                        () {
                          cText.add('');
                          roomNames.add(TextEditingController());
                          nameNumber += 1;
                          if (nameNumber > 4) {
                            screenLengthConstant += 1;
                          }
                        },
                      );

                      print(nameNumber);
                    },
                  ),
                ),
                trailing: Container(
                  decoration: ShapeDecoration(
                      shape: CircleBorder(), color: Colors.blue),
                  child: IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        int check = 0, i;
                        for (i = 0; i < nameNumber; i++) {
                          if (roomNames[i].text.length < 1) {
                            check += 1;
                            cText[i] = 'Enter Name';
                          }
                        }
                        if (check == 0) {
                          for (i = 0; i < nameNumber; i++) {
                            if (roomNames[i].text.length > 0) {
                              databaseHelper.insertWorker(roomNames[i].text);
                              workers.add(roomNames[i].text);
                            }
                          }
                          nameNumber = 1;
                          Fluttertoast.showToast(
                            msg: 'Successfully Added',
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
