import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:fl_chart/fl_chart.dart';

import 'data.dart';
import 'front_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart';

class Loding extends StatefulWidget {
  @override
  _LodingState createState() => _LodingState();
}

class _LodingState extends State<Loding> {
  @override
  void initState() {
    load();
    Wakelock.enable();
    wifiTimer = Timer.periodic(
      Duration(seconds: 3),
      (data) {
        if (serverOnline == false) {
          wifi();
        }
      },
    );
    wifi();
    redirect();
    super.initState();
  }

  load() async {
    prefs = await SharedPreferences.getInstance();
    databaseHelper = DatabaseHelper();
    databaseHelper.getRoomMapList().then(
      (value) {
        for (var map in value) {
          rooms.add(map['roomName']);
          room = rooms[0];
        }
      },
    );
    databaseHelper.getWorkerMapList().then((value) {
      for (var map in value) {
        workers.add(map['workerName']);
          worker = workers[0];
      }
    });
    databaseHelper.getHistoryMapList().then((value) {
      for (var map in value) {
        historyList.add(
          History(
              roomName: map['roomName'],
              workerName: map['workerName'],
              time: DateTime.parse(map['time']),
              state: map['state']),
        );
      }
    });

    databaseHelper.getTimeDataMapList().then((value) {
      for (var map in value) {
        timeDataList.add(TimeData(
            roomName: map['roomName'],
            workerName: map['workerName'],
            startTime: DateTime.parse(map['startTime']),
            endTime: DateTime.parse(map['endTime']),
            time: map['time'],
            elapsedTime: map['elapsedTime']));
      }
    }).whenComplete(() {
      for (int i = 0; i < timeDataList.length; i++) {
        if (timeDataList[i].startTime.day == DateTime.now().day &&
            timeDataList[i].startTime.year == DateTime.now().year &&
            timeDataList[i].startTime.month == DateTime.now().month) {
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
                        timeDataList[i].startTime.hour.toString();
                    dateTimeNow += ':';
                    dateTimeNow += timeDataList[i].startTime.minute.toString();
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
                      y: timeDataList[i].elapsedTime / 60,
                      color: Colors.lightBlueAccent),
                ], showingTooltipIndicators: [
                  0
                ])
              ],
            )),
          ));
        }
        if (timeDataList[i].startTime.day ==
                DateTime.now().subtract(Duration(days: 1)).day &&
            timeDataList[i].startTime.month ==
                DateTime.now().subtract(Duration(days: 1)).month &&
            timeDataList[i].startTime.year ==
                DateTime.now().subtract(Duration(days: 1)).year) {
          conYesday.add(Container(
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
                        timeDataList[i].startTime.hour.toString();
                    dateTimeNow += ':';
                    dateTimeNow += timeDataList[i].startTime.minute.toString();
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
                      y: timeDataList[i].elapsedTime / 60,
                      color: Colors.lightBlueAccent),
                ], showingTooltipIndicators: [
                  0
                ])
              ],
            )),
          ));
        }
        if (timeDataList[i].startTime.day ==
                DateTime.now().subtract(Duration(days: 2)).day &&
            timeDataList[i].startTime.month ==
                DateTime.now().subtract(Duration(days: 2)).month &&
            timeDataList[i].startTime.year ==
                DateTime.now().subtract(Duration(days: 2)).year) {
          con2DayBefore.add(Container(
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
                        timeDataList[i].startTime.hour.toString();
                    dateTimeNow += ':';
                    dateTimeNow += timeDataList[i].startTime.minute.toString();
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
                      y: timeDataList[i].elapsedTime / 60,
                      color: Colors.lightBlueAccent),
                ], showingTooltipIndicators: [
                  0
                ])
              ],
            )),
          ));
        }
      }
    });
  }

  void redirect() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FrontPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset('images/razecov.jfif'),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(50),
              child: LinearProgressIndicator(),
            ),
          )
        ],
      )),
    );
  }
}
