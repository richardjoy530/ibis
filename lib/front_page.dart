import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:ibis/height_page.dart';
import 'package:ibis/main.dart';
import 'package:ibis/select_time.dart';
import 'package:ibis/show_history.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:excel/excel.dart';

import 'calender.dart';
import 'data.dart';
import 'show_rooms_workers.dart';
import 'height_page.dart';

double todayTotalTime, yesdayTotalTime, dayBeforeYesTotalTime, maxYAxis;

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
      if (val == true) {
        WiFiForIoTPlugin.disconnect();
        WiFiForIoTPlugin.connect(prefs.getString('SSID') ?? '',
            password: prefs.getString('password') ?? '',
            joinOnce: true,
            security: NetworkSecurity.WPA);
      }
      if (val != true) {
        WiFiForIoTPlugin.connect(prefs.getString('SSID') ?? '',
                password: prefs.getString('password') ?? '',
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
  Timer totalDayTime;
  TextEditingController nameController;
  TextEditingController ssidController;
  TextEditingController passwordController;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    todayTotalTime = 0;
    yesdayTotalTime = 0;
    dayBeforeYesTotalTime = 0;
    maxYAxis = 20;
    connect();
    nameController = TextEditingController();
    ssidController = TextEditingController();
    passwordController = TextEditingController();
    getIpList();

    timer = Timer.periodic(
      Duration(milliseconds: 100),
      (callback) {
        setState(
          () {
            if (topHit == true) {
              flare = 'idle';
              downArrowColor = Color(0xff5cbceb);
              downBGColor = Color(0xff02457a);
              upArrowColor = Color(0xff5cbceb);
              upBGColor = Color(0xff02457a);
            }
            if (bottumHit == true) {
              flare = 'idle';
              downArrowColor = Color(0xff5cbceb);
              downBGColor = Color(0xff02457a);
              upArrowColor = Color(0xff5cbceb);
              upBGColor = Color(0xff02457a);
            }
            for (var i = 0; i < deviceObjectList.length; i++) {
              if ((deviceObjectList[i].motionDetected == true ||
                      deviceObjectList[i].clientError == true) &&
                  deviceObjectList[i].power == true) {
                deviceObjectList[i].power = false;
                deviceObjectList[i].pause = false;
                deviceObjectList[i].resetingheight = true;

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
                  notification('Disinfection succusfully completed');
                  if (prefs.getString("new") == "yes") {
                    new Timer.periodic(Duration(seconds: 40), (timer) {
                      deviceObjectList[i].resetingheight = false;
                      timer.cancel();
                    });
                  }
                  deviceObjectList[i].power = false;
                  deviceObjectList[i].resetingheight = true;

                  deviceObjectList[i].completedStatus = true;
                  databaseHelper.insertTimeData(
                    TimeData(
                      roomName: room,
                      workerName: worker,
                      startTime: startTime,
                      endTime: DateTime.now(),
                      elapsedTime: deviceObjectList[i].elapsedTime,
                      time: deviceObjectList[i].time.inSeconds.toInt(),
                    ),
                  );
                  timeDataList.add(
                    TimeData(
                        roomName: room,
                        workerName: worker,
                        startTime: startTime,
                        endTime: DateTime.now(),
                        elapsedTime: deviceObjectList[i].elapsedTime,
                        time: deviceObjectList[i].time.inSeconds.toInt()),
                  );
                  deviceObjectList[i].linearProgressBarValue = 0.0;

                  deviceObjectList[i].pause = false;
                  deviceObjectList[i].flare = 'off';
                  print('state2');
                  conToday.add(Container(
                    margin: EdgeInsets.only(top: 25),
                    width: eachGraphSpace,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 60,
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
                            String dateTimeNow =
                                timeDataList[timeDataList.length - 1]
                                    .startTime
                                    .hour
                                    .toString();
                            dateTimeNow += ':';
                            dateTimeNow += timeDataList[timeDataList.length - 1]
                                .startTime
                                .minute
                                .toString();
                            return dateTimeNow;
                          },
                        ),
                        leftTitles: SideTitles(showTitles: false),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(
                              y: timeDataList[timeDataList.length - 1]
                                      .elapsedTime /
                                  60,
                              color: Colors.lightBlueAccent),
                        ], showingTooltipIndicators: [
                          0
                        ])
                      ],
                    )),
                  ));

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
    totalDayTime = Timer.periodic(Duration(seconds: 1), (callback) {
      todayTotalTime = 0;
      yesdayTotalTime = 0;
      dayBeforeYesTotalTime = 0;
      maxYAxis = 20;
      setState(() {
        for (int i = 0; i < timeDataList.length; i++) {
          if (timeDataList[i].startTime.day == DateTime.now().day &&
              timeDataList[i].startTime.month == DateTime.now().month &&
              timeDataList[i].startTime.year == DateTime.now().year) {
            todayTotalTime += timeDataList[i].elapsedTime.toDouble();
          }
          if (timeDataList[i].startTime.day ==
                  DateTime.now().subtract(Duration(days: 1)).day &&
              timeDataList[i].startTime.month ==
                  DateTime.now().subtract(Duration(days: 1)).month &&
              timeDataList[i].startTime.year ==
                  DateTime.now().subtract(Duration(days: 1)).year) {
            yesdayTotalTime += timeDataList[i].elapsedTime.toDouble();
          }
          if (timeDataList[i].startTime.day ==
                  DateTime.now().subtract(Duration(days: 2)).day &&
              timeDataList[i].startTime.month ==
                  DateTime.now().subtract(Duration(days: 2)).month &&
              timeDataList[i].startTime.year ==
                  DateTime.now().subtract(Duration(days: 2)).year) {
            dayBeforeYesTotalTime += timeDataList[i].elapsedTime.toDouble();
          }
          if (todayTotalTime > yesdayTotalTime) {
            maxYAxis = todayTotalTime;
            if (dayBeforeYesTotalTime > todayTotalTime) {
              maxYAxis = dayBeforeYesTotalTime;
            }
          } else {
            maxYAxis = yesdayTotalTime;
            if (dayBeforeYesTotalTime > yesdayTotalTime) {
              maxYAxis = dayBeforeYesTotalTime;
            }
          }
        }
      });
    });
    load();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    totalDayTime.cancel();
    timer.cancel();
    super.dispose();
  }

  load() {
    var old = prefs.getString('old');
    if (old == null) {
      Future.delayed(Duration(seconds: 1)).then((value) => scanIbis(context));
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            title: Text(
              'Are you sure?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff02457a),
                fontWeight: FontWeight.bold,
                //fontSize: 24,
              ),
            ),
            content: Text('Do you want to exit the App?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff02457a),
                    fontWeight: FontWeight.bold,
                    //fontSize: 24,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff02457a),
                    fontWeight: FontWeight.bold,
                    //fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 40),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    height: 30,
                    width: 30,
                    child: FlareActor(
                      'assets/status.flr',
                      animation: 'Connected',
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
                            margin: EdgeInsets.fromLTRB(10,
                                MediaQuery.of(context).size.height / 3, 10, 0),
                            child: FloatingActionButton.extended(
                              backgroundColor: Color(0xff02457a),
                              label: Text(
                                "Add device",
                                style: TextStyle(
                                    fontSize: 20, color: Color(0xffffffff)),
                              ),
                              icon: Icon(Icons.add_circle_outline_outlined,
                                  color: Color(0xffffffff)),
                              onPressed: () {
                                scanIbis(context);
                              },
                            ),
                          ),
                        )
                      : Expanded(child: fillerWidget(context))
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
      ),
      onWillPop: _onWillPop,
    );
  }

  void checkCredentials(String ssid, String password) {
    if (password == "razecov@1234" || password.length <= 8) {
      // ignore: unnecessary_statements
      null;
    } else if (int.parse(password[7] + password[8]) > 19 &&
        int.parse(password[7] + password[8]) < 29) {
      prefs.setString('new', 'yes');
    } else if (int.parse(password[7] + password[8]) > 28) {
      prefs.setString('new', 'yes');
    }
  }

  Future<void> scanIbis(BuildContext context) async {
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
                'Enter your device credentials',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff02457a),
                  fontWeight: FontWeight.bold,
                  //fontSize: 24,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: ssidController,
                  decoration: InputDecoration(hintText: 'WiFi name'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(hintText: 'password'),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SimpleDialogOption(
                    child: Text('OK'),
                    onPressed: () {
                      if (ssidController.text != "" &&
                          passwordController.text != "") {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        });
    WiFiForIoTPlugin.setEnabled(false);
    WiFiForIoTPlugin.setEnabled(true);
    String ssid = ssidController.text;
    String password = passwordController.text;
    WiFiForIoTPlugin.connect(ssid,
        password: password, joinOnce: true, security: NetworkSecurity.WPA);
    checkCredentials(ssid, password);
    prefs.setString('SSID', ssid);
    prefs.setString('password', password);
    prefs.setString('old', '1');
  }

  Widget fillerWidget(BuildContext context) {
    if (deviceObjectList[0].name == 'Device') {
      deviceObjectList[0].name = '';
      nameIt(context, deviceObjectList[0]);
    }
    if (deviceObjectList[0].earlyMotionDetection == true) {
      deviceObjectList[0].earlyMotionDetection = false;
      earlyMotionDetection(context, deviceObjectList[0]);
    }
    if (deviceObjectList[0].completedStatus == true) {
      deviceObjectList[0].completedStatus = false;
      completedPop(context, deviceObjectList[0]);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          //width: MediaQuery.of(context).size.width / 1.05,
          decoration: BoxDecoration(
            color: Color(0xffbddeee),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: ListTile(
            leading: Icon(
              deviceObjectList[0].offline == true
                  ? Icons.signal_wifi_off
                  : Icons.network_wifi,
              color: Color(0xff02457a),
            ),
            trailing: deviceObjectList[0].motionDetected == true
                ? Icon(
                    Icons.warning,
                    color: Color(0xff02457a),
                  )
                : IconButton(
                    icon: Icon(Icons.more_vert, color: Color(0xff02457a)),
                    onPressed: () {
                      info(context, deviceObjectList[0]);
                    },
                  ),
            title: Text(
              '${deviceObjectList[0].name}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: deviceObjectList[0].power == false
                ? Text(deviceObjectList[0].offline == true
                    ? 'Device not Connected'
                    : deviceObjectList[0].motionDetected == false
                        ? (deviceObjectList[0].resetingheight == false ||
                                prefs.getString('new') != 'yes')
                            ? 'Device Connected'
                            : 'Reseting height...'
                        : 'Motion Detected')
                : LinearPercentIndicator(
                    lineHeight: 5.0,
                    animation: false,
                    animationDuration: 0,
                    backgroundColor: Color(0xff9ad2ec),
                    percent: deviceObjectList[0].linearProgressBarValue,
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Color(0xff019ae6),
                  ),
            onTap: () {},
            onLongPress: () {
              setName(
                context,
                deviceObjectList[0],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 125,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xff02457a),
                    heroTag: 'hero1',
                    label: Text(
                      "Staff",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xffffffff),
                      ),
                    ),
                    icon: Icon(
                      Icons.perm_identity,
                      color: Color(0xffffffff),
                    ),
                    onPressed: () {
                      showWorkers(context, deviceObjectList[0]);
                    },
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xff02457a),
                    heroTag: 'hero2',
                    label: Text(
                      "Room",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xffffffff),
                      ),
                    ),
                    icon: Icon(
                      Icons.meeting_room_rounded,
                      color: Color(0xffffffff),
                    ),
                    onPressed: () {
                      showRooms(context, deviceObjectList[0]);
                    },
                  )
                ],
              ),
            ),
            Container(
              height: 200,
              // width: MediaQuery.of(context)
              //         .size
              //         .width /
              //     2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                //color: Color(0xffbddeee),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      //height: 160,
                      width: (MediaQuery.of(context).size.width / 2.5) / 2.1,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: FlareActor(
                          'assets/lift.flr',
                          animation:
                              (deviceObjectList[0].resetingheight == false ||
                                      prefs.getString('new') != 'yes')
                                  ? flare
                                  : 'down',
                        ),
                      )),
                  Container(
                    //height: 170,
                    width: (MediaQuery.of(context).size.width / 2.5) / 2.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          height: 85,
                          child: Listener(
                            child: Container(
                              height: 65,
                              width: 65,
                              child: Image.asset(
                                'images/up.png',
                                color: upBGColor,
                              ),
                            ),
                            onPointerDown: (data) {
                              if (deviceObjectList[0].offline == false &&
                                  topHit == false &&
                                  deviceObjectList[0].power == false &&
                                  (deviceObjectList[0].resetingheight ==
                                          false ||
                                      prefs.getString('new') != 'yes')) {
                                deviceObjectList[0].socket.write('-3\r');
                                upBGColor = upArrowColor;

                                setState(() {
                                  flare = 'up';
                                });
                                bottumHit = false;
                                upArrowColor = downBGColor;
                                indicator = 1;
                                if (deviceObjectList[0].height != 100) {
                                  tick(deviceObjectList[0]);
                                }
                              }
                            },
                            onPointerUp: (data) {
                              if (deviceObjectList[0].offline == false &&
                                  deviceObjectList[0].power == false &&
                                  (deviceObjectList[0].resetingheight ==
                                          false ||
                                      prefs.getString('new') != 'yes')) {
                                deviceObjectList[0].socket.write('-1\r');
                                setState(() {
                                  flare = 'idle';
                                  downArrowColor = Color(0xff5cbceb);
                                  downBGColor = Color(0xff02457a);
                                  upArrowColor = Color(0xff5cbceb);
                                  upBGColor = Color(0xff02457a);
                                });
                                if (timer != null) {
                                  timer.cancel();
                                }
                                if (indicator != 0) {
                                  prefs.setInt(
                                      '${deviceObjectList[0].ip}height',
                                      deviceObjectList[0].height.toInt());
                                  indicator = 0;
                                }
                              }
                            },
                          ),
                        ),
                        Container(
                          height: 85,
                          child: Listener(
                            child: Transform.rotate(
                              angle: 3.14,
                              child: Container(
                                height: 65,
                                width: 65,
                                child: Image.asset(
                                  'images/up.png',
                                  color: downBGColor,
                                ),
                              ),
                            ),
                            onPointerDown: (data) {
                              if (deviceObjectList[0].offline == false &&
                                  bottumHit == false &&
                                  deviceObjectList[0].power == false &&
                                  (deviceObjectList[0].resetingheight ==
                                          false ||
                                      prefs.getString('new') != 'yes')) {
                                downBGColor = downArrowColor;
                                downArrowColor = upBGColor;
                                topHit = false;
                                setState(() {
                                  flare = 'down';
                                });

                                indicator = -1;
                                deviceObjectList[0].socket.write('-2\r');
                                if (deviceObjectList[0].height != 0) {
                                  tick(deviceObjectList[0]);
                                }
                              }
                            },
                            onPointerUp: (data) {
                              if (deviceObjectList[0].offline == false &&
                                  deviceObjectList[0].power == false &&
                                  (deviceObjectList[0].resetingheight ==
                                          false ||
                                      prefs.getString('new') != 'yes')) {
                                deviceObjectList[0].socket.write('-1\r');
                                setState(() {
                                  flare = 'idle';
                                  downArrowColor = Color(0xff5cbceb);
                                  downBGColor = Color(0xff02457a);
                                  upArrowColor = Color(0xff5cbceb);
                                  upBGColor = Color(0xff02457a);
                                });
                                if (timer != null) {
                                  timer.cancel();
                                }
                                if (indicator != 0) {
                                  prefs.setInt(
                                      '${deviceObjectList[0].ip}height',
                                      deviceObjectList[0].height.toInt());
                                  indicator = 0;
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Container(
          child: Listener(
            onPointerDown:
                // ignore: non_constant_identifier_names
                (PointerDownEvent) {
              if (deviceObjectList[0].offline == false &&
                  (deviceObjectList[0].resetingheight == false ||
                      prefs.getString('new') != 'yes')) {
                if (deviceObjectList[0].power == true) {
                  deviceObjectList[0].clientError = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        deviceObjectList[0],
                      ),
                    ),
                  );
                } else {
                  deviceObjectList[0].motionDetected = false;
                  deviceObjectList[0].time = Duration(minutes: 0);
                  deviceObjectList[0].progressDegrees = 0;
                  if (rooms.length != 0) {
                    if (workers.length != 0) {
                      deviceObjectList[0].clientError = false;
                      deviceObjectList[0].socket.write('5\r');
                      if (worker == null) {
                        worker = workers[0];
                      }
                      if (room == null) {
                        room = rooms[0];
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectTime(deviceObjectList[0])),
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
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: 75,
              //margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xff02457a),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                // boxShadow: [
                //   BoxShadow(
                //       blurRadius: 50, spreadRadius: 2, color: Color(0xff02457a))
                // ],
              ),
              child: Center(
                child: Text(
                  deviceObjectList[0].power == false
                      ? 'Disinfect'
                      : deviceObjectList[0].pause == true
                          ? 'Paused'
                          : 'Disinfecting',
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xffffffff),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        )
      ],
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
                          rooms[index] == room
                              ? Icons.check
                              : Icons.meeting_room_rounded,
                          color: Color(0xff02457a),
                        ),
                        title: Text(rooms[index],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        room = rooms[index];
                        print(["selected room", room]);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                  child: Text(
                    "Add Rooms",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color(0xff02457a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    addRooms(context);
                  }),
            )
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
                        border: Border.all(color: Color(0xff02457a)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(
                          workers[index] == worker
                              ? Icons.check
                              : Icons.perm_identity,
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
                      setState(() {
                        worker = workers[index];
                        print(["selected worker", worker]);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            Center(
              child: RaisedButton(
                  child: Text(
                    "Add Staffs",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color(0xff02457a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    addWorker(context);
                  }),
            )
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
              Divider(
                thickness: 2,
                color: Colors.grey[500],
                indent: 2 * MediaQuery.of(context).size.width / 5,
                endIndent: 2 * MediaQuery.of(context).size.width / 5,
              ),
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
                  Icons.info_outline,
                  color: Color(0xff02457a),
                ),
                title: Text('History'),
                onTap: () {
                  //Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CalenderPage()),
                  );
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.import_export_sharp, color: Color(0xff02457a)),
                title: Text('Export'),
                onTap: () async{
                  var permissionResult = Permission.storage;
                  if (await permissionResult.isGranted) {
                    // code of read or write file in external storage (SD card)
                    var excel = Excel.createExcel();
                  List rowData = [];
                  Sheet sheetObject = excel['ibis'];
                  for (int i = 0; i < timeDataList.length; i++) {
                    exportRooms.add(timeDataList[i].roomName);
                    exportWorkers.add(timeDataList[i].workerName);
                    exportStartTime.add(timeDataList[i].startTime);
                    exportEndTime.add(timeDataList[i].endTime);
                    exportElapseTime.add(timeDataList[i].elapsedTime);
                    exportTime.add(timeDataList[i].time);
                  }
                  
                  for (int j = 0; j < historyList.length; j++) {
                    exportState.add(historyList[j].state);
                    exportTimeNow.add(historyList[j].time);
                  }

                  for (int i = 0; i < timeDataList.length; i++) {
                    rowData.add(exportRooms[i]);
                    rowData.add(exportWorkers[i]);
                    rowData.add(exportStartTime[i]);
                    rowData.add(exportEndTime[i]);
                    rowData.add(exportElapseTime[i]);
                    rowData.add(exportTime[i]);
                    rowData.add(exportState[i]);
                    rowData.add(exportTimeNow[i]);
                    sheetObject.insertRowIterables(rowData, i);
                    rowData.removeRange(0, rowData.length);
                  }

                  DownloadsPathProvider.downloadsDirectory.then((value) {                     
                    List<String> path1=value.toString().split("'");                    
                    String path2=path1[1].trim();
                    String path=path2 + '/ibis.xlsx';
                    print(path);
                    excel.encode().then((onValue) {                      
                      File('$path')
                        ..createSync(recursive: true)
                        ..writeAsBytesSync(onValue);
                    });
                    Fluttertoast.showToast(
                      msg: "Succesfully exported to $path",
                      gravity: ToastGravity.SNACKBAR,
                      toastLength: Toast.LENGTH_LONG,
                    );
                  });
                  }
                  else
                  {
                    permissionResult.request();
                  }
                },
              )
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

  Future<void> graph3Days(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowHistory(),
                          ),
                        );
                      },
                      child: Text(
                        'Detiled Hstory',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.lightBlue,
                    ),
                    BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxYAxis / 60,
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
                            switch (value.toInt()) {
                              case 0:
                                return 'DBY';
                              case 1:
                                return 'Yes';
                              case 2:
                                return 'Tod';

                              default:
                                return '';
                            }
                          },
                        ),
                        leftTitles: SideTitles(showTitles: false),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(
                              y: dayBeforeYesTotalTime / 60,
                              color: Colors.lightBlueAccent)
                        ], showingTooltipIndicators: [
                          0
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                              y: yesdayTotalTime / 60,
                              color: Colors.lightBlueAccent)
                        ], showingTooltipIndicators: [
                          0
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(
                              y: todayTotalTime / 60,
                              color: Colors.lightBlueAccent)
                        ], showingTooltipIndicators: [
                          0
                        ]),
                      ],
                    )),
                  ],
                ),
              )
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

  Future<void> resetingHeight(context) async {
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
                'Reseting height',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xff02457a),
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
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

  Future<void> tick(DeviceObject deviceObject) async {
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        if (indicator == 1) {
          deviceObject.height += 0.5;
        } else if (indicator == -1) {
          deviceObject.height -= 0.5;
        }
        if (deviceObject.height >= 100) {
          deviceObject.height = 100;
          indicator = 0;
          prefs.setInt('${deviceObject.ip}height', deviceObject.height.toInt());
          //widget.deviceObject.socket.write('-1\r');
        }
        if (deviceObject.height <= 0) {
          deviceObject.height = 0.0;
          indicator = 0;
          prefs.setInt('${deviceObject.ip}height', deviceObject.height.toInt());
          //widget.deviceObject.socket.write('-1\r');
        }
      });
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
                            borderSide: BorderSide(color: Color(0xff02457a)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff02457a)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff02457a)),
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
                                      : Color(0xff02457a))),
                          labelStyle: TextStyle(
                              fontSize: 20,
                              color: cText[index] == 'Enter Name'
                                  ? Colors.red
                                  : Color(0xff02457a)),
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
                      shape: CircleBorder(), color: Color(0xff02457a)),
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
                      shape: CircleBorder(), color: Color(0xff02457a)),
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
                          if (rooms.contains(roomNames[i].text)) {
                            check += 1;
                            cText[i] = 'Room already Present';
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
                            borderSide: BorderSide(color: Color(0xff02457a)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff02457a)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff02457a)),
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
                                      : Color(0xff02457a))),
                          labelText: 'Staff Name',
                          labelStyle: TextStyle(
                              fontSize: 20,
                              color: cText[index] == 'Enter Name'
                                  ? Colors.red
                                  : Color(0xff02457a)),
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
                      shape: CircleBorder(), color: Color(0xff02457a)),
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
                      shape: CircleBorder(), color: Color(0xff02457a)),
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
                          if (workers.contains(roomNames[i].text)) {
                            check += 1;
                            cText[i] = 'Name already Present';
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
