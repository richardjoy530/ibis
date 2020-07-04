import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data.dart';

int graphDisplayTemp = 0;
DateTime defaultTime=DateTime.now();
String dropdownValue = rooms.length==0?'No rooms':rooms[0];
double elapseTimeFunction() {
  if (timeDataList.length != 0) {
    var max = timeDataList[0];
    timeDataList.forEach((e) {
      if (e.elapsedTime > max.elapsedTime) max = e;
    });
    String roomNameTemp=max.roomName;
    double maxElaspedTime=0;
    for(int i=0;i<timeDataList.length;i++)
      {
        if(timeDataList[i].roomName==roomNameTemp)
          {
            maxElaspedTime+=timeDataList[i].elapsedTime;
          }
      }
    return maxElaspedTime/ 60;
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
      if (graphDisplayTemp == 0) {
        setState(() {
          var date = DateTime.now();
          time12am = 0;
          time3am = 0;
          time6am = 0;
          time9am = 0;
          time12pm = 0;
          time3pm = 0;
          time6pm = 0;
          time9pm = 0;
          for (int i = 0; i < timeDataList.length; i++) {
            if (date.day == timeDataList[i].startTime.day &&
                date.month == timeDataList[i].startTime.month &&
                date.year == timeDataList[i].startTime.year &&
                dropdownValue == timeDataList[i].roomName) {
              if (timeDataList[i].startTime.hour >= 0 &&
                  timeDataList[i].startTime.hour < 3) {
                time3am += timeDataList[i].elapsedTime.toDouble();
                //time3am=20-(time3am%20);
              }
              if (timeDataList[i].startTime.hour >= 3 &&
                  timeDataList[i].startTime.hour < 6) {
                time6am += timeDataList[i].elapsedTime.toDouble();
                //time6am=20-(time6am%20);
              }
              if (timeDataList[i].startTime.hour >= 6 &&
                  timeDataList[i].startTime.hour < 9) {
                time9am += timeDataList[i].elapsedTime.toDouble();
                // time9am=20-(time9am%20);
              }
              if (timeDataList[i].startTime.hour >= 9 &&
                  timeDataList[i].startTime.hour < 12) {
                time12pm += timeDataList[i].elapsedTime.toDouble();
                //time12pm=20-(time12pm%20);
              }
              if (timeDataList[i].startTime.hour >= 12 &&
                  timeDataList[i].startTime.hour < 15) {
                time3pm += timeDataList[i].elapsedTime.toDouble();
                //time3pm=20-(time3pm%20);
              }
              if (timeDataList[i].startTime.hour >= 15 &&
                  timeDataList[i].startTime.hour < 18) {
                time6pm += timeDataList[i].elapsedTime.toDouble();
                //time6pm=20-(time6pm%20);
              }
              if (timeDataList[i].startTime.hour >= 18 &&
                  timeDataList[i].startTime.hour < 21) {
                time9pm = timeDataList[i].elapsedTime.toDouble();
                //time9pm=20-(time9pm%20);
              }
              if (timeDataList[i].startTime.hour >= 21 &&
                  timeDataList[i].startTime.hour < 24) {
                time12am += timeDataList[i].elapsedTime.toDouble();
                //time12am=20-(time12am%20);
              }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 6.0, 20.0, 0.0),
                    child: Text(
                      'Select Room',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  DropdownButton<String>(
                    value: rooms.length == 0 ? 'No rooms' : dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 26,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        var date = defaultTime;
                        time12am = 0;
                        time3am = 0;
                        time6am = 0;
                        time9am = 0;
                        time12pm = 0;
                        time3pm = 0;
                        time6pm = 0;
                        time9pm = 0;
                        for (int i = 0; i < timeDataList.length; i++) {
                          if (date.day == timeDataList[i].startTime.day &&
                              date.month == timeDataList[i].startTime.month &&
                              date.year == timeDataList[i].startTime.year &&
                              dropdownValue == timeDataList[i].roomName) {
                            if (timeDataList[i].startTime.hour >= 0 &&
                                timeDataList[i].startTime.hour < 3) {
                              time3am += timeDataList[i].elapsedTime.toDouble();
                              //time3am=20-(time3am%20);
                            }
                            if (timeDataList[i].startTime.hour >= 3 &&
                                timeDataList[i].startTime.hour < 6) {
                              time6am += timeDataList[i].elapsedTime.toDouble();
                              //time6am=20-(time6am%20);
                            }
                            if (timeDataList[i].startTime.hour >= 6 &&
                                timeDataList[i].startTime.hour < 9) {
                              time9am += timeDataList[i].elapsedTime.toDouble();
                              // time9am=20-(time9am%20);
                            }
                            if (timeDataList[i].startTime.hour >= 9 &&
                                timeDataList[i].startTime.hour < 12) {
                              time12pm += timeDataList[i].elapsedTime.toDouble();
                              //time12pm=20-(time12pm%20);
                            }
                            if (timeDataList[i].startTime.hour >= 12 &&
                                timeDataList[i].startTime.hour < 15) {
                              time3pm += timeDataList[i].elapsedTime.toDouble();
                              //time3pm=20-(time3pm%20);
                            }
                            if (timeDataList[i].startTime.hour >= 15 &&
                                timeDataList[i].startTime.hour < 18) {
                              time6pm += timeDataList[i].elapsedTime.toDouble();
                              //time6pm=20-(time6pm%20);
                            }
                            if (timeDataList[i].startTime.hour >= 18 &&
                                timeDataList[i].startTime.hour < 21) {
                              time9pm = timeDataList[i].elapsedTime.toDouble();
                              //time9pm=20-(time9pm%20);
                            }
                            if (timeDataList[i].startTime.hour >= 21 &&
                                timeDataList[i].startTime.hour < 24) {
                              time12am += timeDataList[i].elapsedTime.toDouble();
                              //time12am=20-(time12am%20);
                            }
                          }
                        }
                      });
                    },
                    items: rooms.length == 0
                        ? <String>['No rooms']
                            .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : rooms.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            child: _buildTableCalendar(),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 1,
              padding: EdgeInsets.all(8.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: elapseTimeFunction(),
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
                            return '12AM';
                          case 1:
                            return '3AM';
                          case 2:
                            return '6AM';
                          case 3:
                            return '9AM';
                          case 4:
                            return '12PM';
                          case 5:
                            return '3PM';
                          case 6:
                            return '6PM';
                          case 7:
                            return '9PM';
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
                          y: time12am / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          y: time3am / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                          y: time6am / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(
                          y: time9am / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(
                          y: time12pm / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 5, barRods: [
                      BarChartRodData(
                          y: time3pm / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 6, barRods: [
                      BarChartRodData(
                          y: time6pm / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                    BarChartGroupData(x: 7, barRods: [
                      BarChartRodData(
                          y: time9pm / 60, color: Colors.lightBlueAccent)
                    ], showingTooltipIndicators: [
                      0
                    ]),
                  ],
                ),
              ),
            ),
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
        todayColor: Colors.lightBlue,
        markersColor: Colors.blue,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (date, events) {
        graphDisplayTemp = 1;
        setState(() {
          defaultTime=date;
          print('date selected');
          print(dropdownValue);
          time12am = 0;
          time3am = 0;
          time6am = 0;
          time9am = 0;
          time12pm = 0;
          time3pm = 0;
          time6pm = 0;
          time9pm = 0;
          for (int i = 0; i < timeDataList.length; i++) {
            if (date.day == timeDataList[i].startTime.day &&
                date.month == timeDataList[i].startTime.month &&
                date.year == timeDataList[i].startTime.year &&
                dropdownValue == timeDataList[i].roomName) {
              if (timeDataList[i].startTime.hour >= 0 &&
                  timeDataList[i].startTime.hour < 3) {
                time3am += timeDataList[i].elapsedTime.toDouble();
                //time3am=20-(time3am%20);
              }
              if (timeDataList[i].startTime.hour >= 3 &&
                  timeDataList[i].startTime.hour < 6) {
                time6am += timeDataList[i].elapsedTime.toDouble();
                //time6am=20-(time6am%20);
              }
              if (timeDataList[i].startTime.hour >= 6 &&
                  timeDataList[i].startTime.hour < 9) {
                time9am += timeDataList[i].elapsedTime.toDouble();
                // time9am=20-(time9am%20);
              }
              if (timeDataList[i].startTime.hour >= 9 &&
                  timeDataList[i].startTime.hour < 12) {
                time12pm += timeDataList[i].elapsedTime.toDouble();
                //time12pm=20-(time12pm%20);
              }
              if (timeDataList[i].startTime.hour >= 12 &&
                  timeDataList[i].startTime.hour < 15) {
                time3pm += timeDataList[i].elapsedTime.toDouble();
                //time3pm=20-(time3pm%20);
              }
              if (timeDataList[i].startTime.hour >= 15 &&
                  timeDataList[i].startTime.hour < 18) {
                time6pm += timeDataList[i].elapsedTime.toDouble();
                //time6pm=20-(time6pm%20);
              }
              if (timeDataList[i].startTime.hour >= 18 &&
                  timeDataList[i].startTime.hour < 21) {
                time9pm += timeDataList[i].elapsedTime.toDouble();
                //time9pm=20-(time9pm%20);
              }
              if (timeDataList[i].startTime.hour >= 21 &&
                  timeDataList[i].startTime.hour < 24) {
                time12am += timeDataList[i].elapsedTime.toDouble();
                //time12am=20-(time12am%20);
              }
            }
          }
        });
      },
    );
  }
}
