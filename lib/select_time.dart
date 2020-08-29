import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'data.dart';
import 'front_page.dart';
import 'main.dart';
import 'show_history.dart';

String dropdownValueRoom = rooms.length == 0 ? 'No rooms' : rooms[0];
String dropdownValueStaff = rooms.length == 0 ? 'No Staff' : workers[0];

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
  @override
  void initState() {
    super.initState();
    dropdownValueRoom = rooms[0];
    dropdownValueStaff = workers[0];
    room = dropdownValueRoom;
    worker = dropdownValueStaff;
  }

  @override
  void dispose() {
    widget.deviceObject.socket.write(65);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //       colors: [Color(0xffffffff), Color(0xffffffff)]),
        // ),
        child: Column(
          children: <Widget>[
            Text(
              widget.deviceObject.name,
              style: TextStyle(
                fontSize: 30,
                color: Color(0xff02457a),
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xff02457a),
                    heroTag: 'staff1',
                    label: Text(room),
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      showRooms(context, widget.deviceObject);
                    },
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: Color(0xff02457a),
                    elevation: 4,
                    heroTag: 'room1',
                    label: Text(worker),
                    icon: Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      showWorkers(context, widget.deviceObject);
                    },
                  )
                ],
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      graph3Days(context, deviceObjectList[0]);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.only(top: 25),
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      color: Color(0xff9ad2ec),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 40,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color(0xffbddeee),
                                ),
                                height: 125,
                                width: MediaQuery.of(context).size.width - 120,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: conToday,
                                  ),
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
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color(0xffbddeee),
                                ),
                                height: 125,
                                width: MediaQuery.of(context).size.width - 120,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: conYesday,
                                  ),
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
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color(0xffbddeee),
                                ),
                                height: 125,
                                width: MediaQuery.of(context).size.width - 120,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: con2DayBefore,
                                  ),
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
                  ),
                ),
                SizedBox(
                  height: 50,
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
                            startAngle: 140,
                            angleRange: 270,
                            customWidths: CustomSliderWidths(
                              handlerSize: 20,
                              trackWidth: 20,
                              progressBarWidth: 20,
                            ),
                            size:
                                (MediaQuery.of(context).size.width / 1.5) + 50,
                            customColors: selectorColor),
                        onChange: (double value) {
                          print(value);
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
                          //print([widget.deviceObject.time.inSeconds,widget.deviceObject.elapsedTime]);
                          return Container(
                            // height: min(
                            //     MediaQuery.of(context).size.height / 1.5,
                            //     MediaQuery.of(context).size.width / 1.5),
                            // width: min(MediaQuery.of(context).size.height / 1.5,
                            //     MediaQuery.of(context).size.width / 1.5),
                            child: Center(
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width / 1.5) -
                                        50,
                                width:
                                    (MediaQuery.of(context).size.width / 1.5) -
                                        50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
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
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      color: Color(0xff02457a),
                                      child: Text(
                                        "Start",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        if (widget
                                                .deviceObject.time.inMinutes >=
                                            1) {
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
                ),
              ],
            ))
          ],
        ),
      ),
      // floatingActionButton: Container(
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(0.0, 100.0, 30.0, 0.0),
      //     child: ,
      //   ),
      // ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
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
                    Listener(
                      onPointerUp: (pointerUpEvent) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowHistory(),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                          color: Color(0xff02457a),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Detiled Hstory',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
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
}
