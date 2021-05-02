import 'dart:async';
import 'dart:math';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'data.dart';
import 'main.dart';

List<BarChartGroupData> barYAxis = [];
List<String> barTime = [];

final selectorColor = CustomSliderColors(
  dotColor: Color(0xff02457a),
  progressBarColor: Color(0xffd6e7ee),
  hideShadow: true,
  trackColor: Colors.lightBlue[50],
  progressBarColors: [
    Color(0xff00477d),
    Color(0xff008bc0),
    Color(0xff97cadb),
  ],
);

class SelectTime extends StatefulWidget {
  final DeviceObject deviceObject;

  SelectTime(this.deviceObject);

  @override
  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  ScrollController mainController;
  ScrollController todayController;
  ScrollController yesterdayController;
  ScrollController dayBeforeYesterdayController;
  double pos;

  @override
  void initState() {
    pos = 1;
    mainController = ScrollController();
    todayController = ScrollController();
    yesterdayController = ScrollController();
    dayBeforeYesterdayController = ScrollController();
    super.initState();
    mainController.addListener(() {
      setState(() {
        pos = ((2 * mainController.offset) /
            (mainController.position.viewportDimension * 2));
      });
    });
  }

  @override
  void dispose() {
    mainController.dispose();
    yesterdayController.dispose();
    todayController.dispose();
    dayBeforeYesterdayController.dispose();
    if (widget.deviceObject.power == false) {
      widget.deviceObject.socket.write(65);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xff02457a),
                    heroTag: 'staff1',
                    label: Text(worker.length > 7
                        ? "${worker.substring(0, 6)}..."
                        : worker),
                    icon: Icon(Icons.perm_identity),
                    onPressed: null,
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xff02457a),
                    elevation: 4,
                    heroTag: 'room1',
                    label: Text(
                        room.length > 7 ? "${room.substring(0, 6)}..." : room),
                    icon: Icon(Icons.meeting_room_rounded),
                    onPressed: null,
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.only(top: 25),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                color: Color(0xff9ad2ec),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    controller: mainController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  graphTDays(context, deviceObjectList[0]);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color(0xffbddeee),
                                ),
                                height: 125,
                                width: MediaQuery.of(context).size.width - 120,
                                child: TodayGraph(
                                    todayController: todayController),
                              ),
                            ),
                            Text(
                              'Today',
                              style: TextStyle(
                                  color: Color(0xff02457a),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  graphYDays(context, deviceObjectList[0]);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color(0xffbddeee),
                                ),
                                height: 125,
                                width: MediaQuery.of(context).size.width - 120,
                                child: YesterdayGraph(
                                    yesterdayController: yesterdayController),
                              ),
                            ),
                            Text(
                              'Yesterday',
                              style: TextStyle(
                                  color: Color(0xff02457a),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  graph2Days(context, deviceObjectList[0]);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color(0xffbddeee),
                                ),
                                height: 125,
                                width: MediaQuery.of(context).size.width - 120,
                                child: TwoDaysAgoGraph(
                                    dayBeforeYesterdayController:
                                        dayBeforeYesterdayController),
                              ),
                            ),
                            Text(
                              '2 Days ago',
                              style: TextStyle(
                                  color: Color(0xff02457a),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  DotsIndicator(
                    dotsCount: 3,
                    position: pos,
                  )
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: min(MediaQuery.of(context).size.height / 3,
                      MediaQuery.of(context).size.width / 1),
                  width: min(MediaQuery.of(context).size.height / 3,
                      MediaQuery.of(context).size.width / 1),
                  child: FlareActor(
                    'assets/breathing.flr',
                    animation: widget.deviceObject.power == true &&
                            widget.deviceObject.pause == false
                        ? 'breath'
                        : 'breath',
                  ),
                ),
                Container(
                  width: 300,
                  height: 300,
                  child: SleekCircularSlider(
                    min: 0,
                    max: 21,
                    initialValue: 0,
                    appearance: CircularSliderAppearance(
                        animationEnabled: false,
                        startAngle: 180,
                        angleRange: 350,
                        customWidths: CustomSliderWidths(
                          handlerSize: 20,
                          trackWidth: 20,
                          progressBarWidth: 20,
                        ),
                        size: (MediaQuery.of(context).size.width / 1.5) + 50,
                        customColors: selectorColor),
                    onChange: (double value) {
                      displayTime = value.floor();
                      if (widget.deviceObject.power == false &&
                          widget.deviceObject.clientError == false) {
                        setState(() {
                          widget.deviceObject.mainTime = Duration(
                              minutes: HomePageState()
                                  .mapValues(displayTime.toDouble())
                                  .toInt());
                          widget.deviceObject.time = Duration(
                              minutes: HomePageState()
                                  .mapValues(displayTime.toDouble())
                                  .toInt());
                          print([
                            widget.deviceObject.time.inSeconds,
                            widget.deviceObject.elapsedTime
                          ]);
                        });
                      }
                    },
                    innerWidget: (value) {
                      return Container(
                        child: Center(
                          child: Container(
                            height:
                                (MediaQuery.of(context).size.width / 1.5) - 50,
                            width:
                                (MediaQuery.of(context).size.width / 1.5) - 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${HomePageState().getMinuets(((widget.deviceObject.time.inSeconds) - widget.deviceObject.elapsedTime).round())}'
                                  ':${HomePageState().getSeconds(((widget.deviceObject.time.inSeconds) - widget.deviceObject.elapsedTime).round())}',
                                  style: TextStyle(fontSize: 40),
                                ),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  color: Color(0xff02457a),
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    if (widget.deviceObject.time.inMinutes >=
                                        1) {
                                      widget.deviceObject.socket.writeln(widget
                                          .deviceObject.time.inMinutes
                                          .round());
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(
                                            widget.deviceObject,
                                            status: 'start',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
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
                      setState(() {
                        room = rooms[index];
                      });
                      Navigator.pop(context);
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
                      setState(() {
                        worker = workers[index];
                      });
                      Navigator.pop(context);
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

  Future<void> graphTDays(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Today"),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    color: Color(0xffbddeee),
                  ),
                  height: 125,
                  width: MediaQuery.of(context).size.width - 120,
                  child: TodayGraph(todayController: ScrollController()),
                ),
              ),
            ],
          );
        });
  }

  Future<void> graphYDays(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Yesderday"),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    color: Color(0xffbddeee),
                  ),
                  height: 125,
                  width: MediaQuery.of(context).size.width - 120,
                  child:
                      YesterdayGraph(yesterdayController: ScrollController()),
                ),
              ),
            ],
          );
        });
  }

  Future<void> graph2Days(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("2 Days Before"),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    color: Color(0xffbddeee),
                  ),
                  height: 125,
                  width: MediaQuery.of(context).size.width - 120,
                  child: TwoDaysAgoGraph(
                      dayBeforeYesterdayController: ScrollController()),
                ),
              ),
            ],
          );
        });
  }
}

class TenSeconds extends StatefulWidget {
  @override
  _TenSecondsState createState() => _TenSecondsState();
}

class _TenSecondsState extends State<TenSeconds> {
  int temp = 20;

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (temp <= 1) {
        Navigator.pop(context);
        timer.cancel();
      }
      setState(() {
        temp--;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, snapshot) {
      return SimpleDialog(
        backgroundColor: Color(0xffffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Center(
          child: Text(
            'The device is setting up',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xff02457a),
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
        ),
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Please wait...   ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff02457a),
                    ),
                  ),
                ),
                Stack(alignment: Alignment.center, children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  Text("$temp"),
                ])
              ],
            ),
          ),
        ],
      );
    });
  }
}

class TwoDaysAgoGraph extends StatelessWidget {
  const TwoDaysAgoGraph({
    Key key,
    @required this.dayBeforeYesterdayController,
  }) : super(key: key);

  final ScrollController dayBeforeYesterdayController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: dayBeforeYesterdayController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          controller: dayBeforeYesterdayController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: con2DayBefore,
          ),
        ),
      ),
    );
  }
}

class YesterdayGraph extends StatelessWidget {
  const YesterdayGraph({
    Key key,
    @required this.yesterdayController,
  }) : super(key: key);

  final ScrollController yesterdayController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: yesterdayController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          controller: yesterdayController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: conYesday,
          ),
        ),
      ),
    );
  }
}

class TodayGraph extends StatelessWidget {
  const TodayGraph({
    Key key,
    @required this.todayController,
  }) : super(key: key);

  final ScrollController todayController;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: todayController,
      isAlwaysShown: true,
      radius: Radius.circular(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          controller: todayController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: conToday,
          ),
        ),
      ),
    );
  }
}
