import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data.dart';

int graphDisplayTemp = 0;
List<Container> selectedDay = [];
DateTime defaultTime = DateTime.now();
String dropdownValue = rooms.length == 0 ? 'No rooms' : rooms[0];
double elapseTimeFunction() {
  if (timeDataList.length != 0) {
    var max = timeDataList[0];
    timeDataList.forEach((e) {
      if (e.elapsedTime > max.elapsedTime) max = e;
    });
    String roomNameTemp = max.roomName;
    double maxElaspedTime = 0;
    for (int i = 0; i < timeDataList.length; i++) {
      if (timeDataList[i].roomName == roomNameTemp) {
        maxElaspedTime += timeDataList[i].elapsedTime;
      }
    }
    return maxElaspedTime / 60;
  } else {
    return 20.0;
  }
}


class CalenderPage extends StatefulWidget {
  @override
  _CalenderPageState createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  CalendarController _calendarController;
  Timer graphTempTimer;

  @override
  void initState() {
    super.initState();
    graphDisplayTemp = 0;
    graphTempTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (graphDisplayTemp == 0 ) {
        setState(() {
          var date = DateTime.now();
          selectedDay = [];
          for (int i = 0; i < timeDataList.length; i++) {
            if (timeDataList[i].startTime.day == date.day &&
                timeDataList[i].startTime.month == date.month &&
                timeDataList[i].startTime.year == date.year &&
                dropdownValue == timeDataList[i].roomName) {
              selectedDay.add(Container(
                margin: EdgeInsets.only(top: 25),
                width: 45,
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
                        dateTimeNow +=
                            timeDataList[i].startTime.minute.toString();
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
        graphDisplayTemp = 1;
      }
      if (graphDisplayTemp == 1) {
        graphTempTimer.cancel();
        print('timer canceled');
      }
    });
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    graphTempTimer.cancel();
    super.dispose();
  }

  Future<void> showHistoryGraph(context) async{
    await showDialog(context: context,
    builder: (BuildContext context)
    {
      return SimpleDialog(
         shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Selected Day Graph',
            style: TextStyle(
                color: Color(0xff02457a), fontWeight: FontWeight.bold),
          ),
          children: [
            Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 1,
                padding: EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: selectedDay,
                  ),
                ))
          ],
      );
    });
  }

  Future<void> showRooms(context) async {
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
                        border: Border.all(color: Color(0xff02457a)),
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
                      setState(() {
                        dropdownValue = room;
                        var date = defaultTime;
                        selectedDay = [];
                        for (int i = 0; i < timeDataList.length; i++) {
                          if (timeDataList[i].startTime.day == date.day &&
                              timeDataList[i].startTime.month == date.month &&
                              timeDataList[i].startTime.year == date.year &&
                              dropdownValue == timeDataList[i].roomName) {
                            selectedDay.add(Container(
                              margin: EdgeInsets.only(top: 25),
                              width: 45,
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
                                      String dateTimeNow = timeDataList[i]
                                          .startTime
                                          .hour
                                          .toString();
                                      dateTimeNow += ':';
                                      dateTimeNow += timeDataList[i]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff02457a),
        title: Text(
          'History',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Row(
            children: [
              Listener(
                  onPointerUp: (data) {
                    showRooms(context);
                  },
                  child: timeDataList.length>0?Text(room,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),):Text('No Room',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
              IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    showRooms(context);
                  })
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Divider(thickness: 2,color: Colors.blueAccent,),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            child: _buildTableCalendar(),
          ),
          
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.blue,
        todayColor: Color(0xff02457a),
        markersColor: Color(0xff02457a),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Color(0xff02457a),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (date, events) {
        graphDisplayTemp = 1;
        setState(() {
          defaultTime = date;
          print('date selected');
          print(dropdownValue);
          selectedDay = [];
          for (int i = 0; i < timeDataList.length; i++) {
            if (timeDataList[i].startTime.day == date.day &&
                timeDataList[i].startTime.month == date.month &&
                timeDataList[i].startTime.year == date.year &&
                dropdownValue == timeDataList[i].roomName) {
              selectedDay.add(Container(
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
                        dateTimeNow +=
                            timeDataList[i].startTime.minute.toString();
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
          showHistoryGraph(context);
        });
      },
    );
  }
}
