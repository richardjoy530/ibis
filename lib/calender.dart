import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data.dart';

//import 'data.dart';

class CalenderPage extends StatefulWidget {
  @override
  _CalenderPageState createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  double elapseTimeFunction(){
    var max = timeDataList[0];
    timeDataList.forEach((e) {
    if (e.elapsedTime > max.elapsedTime) max = e;
  });
  return max.elapsedTime.toDouble();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: _buildTableCalendar(),
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: elapseTimeFunction(),
                barTouchData: BarTouchData(
                  enabled: false,
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
                        color: const Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
                    margin: 20,
                    getTitles: (double value) {
                      switch (value.toInt()) {
                        case 0:
                          return '12 am';
                        case 1:
                          return '3 am';
                        case 2:
                          return '6 am';
                        case 3:
                          return '9 am';
                        case 4:
                          return '12 pm';
                        case 5:
                          return '3 pm';
                        case 6:
                          return '6 pm';
                        case 7:
                          return '9 pm';
                        default:
                          return '';
                      }
                    },
                  ),
                  leftTitles: SideTitles(showTitles: true),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: [
                  BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(y: time12am, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(y: time3am, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 2,
                      barRods: [BarChartRodData(y: time6am, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 3,
                      barRods: [BarChartRodData(y: time9am, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 4,
                      barRods: [BarChartRodData(y: time12pm, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 5,
                      barRods: [BarChartRodData(y: time3pm, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 6,
                      barRods: [BarChartRodData(y: time6pm, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),
                  BarChartGroupData(
                      x: 7,
                      barRods: [BarChartRodData(y: time9pm, color: Colors.lightBlueAccent)],
                      showingTooltipIndicators: [0]),

                ],
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
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (date,events){

        setState(() {
          for(int i=0;i<timeDataList.length;i++)
          {
            if(date.day==timeDataList[i].startTime.day && date.month==timeDataList[i].startTime.month && date.year==timeDataList[i].startTime.year)
            {
              if(timeDataList[i].startTime.hour>=0 &&timeDataList[i].startTime.hour<3)
              {
                time3am=timeDataList[i].elapsedTime.toDouble();
                time3am=20-(time3am%20);
              }
              if(timeDataList[i].startTime.hour>=3 &&timeDataList[i].startTime.hour<6)
              {
                time6am=timeDataList[i].elapsedTime.toDouble();
                time6am=20-(time6am%20);
              }
              if(timeDataList[i].startTime.hour>=6 &&timeDataList[i].startTime.hour<9)
              {
                time9am=timeDataList[i].elapsedTime.toDouble();
                time9am=20-(time9am%20);
              }
              if(timeDataList[i].startTime.hour>=9 &&timeDataList[i].startTime.hour<12)
              {
                time12pm=timeDataList[i].elapsedTime.toDouble();
                time12pm=20-(time12pm%20);
              }
              if(timeDataList[i].startTime.hour>=12 &&timeDataList[i].startTime.hour<15)
              {
                time3pm=timeDataList[i].elapsedTime.toDouble();
                time3pm=20-(time3pm%20);
              }
              if(timeDataList[i].startTime.hour>=15 &&timeDataList[i].startTime.hour<18)
              {
                time6pm=timeDataList[i].elapsedTime.toDouble();
                time6pm=20-(time6pm%20);
              }
              if(timeDataList[i].startTime.hour>=18 &&timeDataList[i].startTime.hour<21)
              {
                time9pm=timeDataList[i].elapsedTime.toDouble();
                time9pm=20-(time9pm%20);
              }
              if(timeDataList[i].startTime.hour>=21 &&timeDataList[i].startTime.hour<24)
              {
                time12am=timeDataList[i].elapsedTime.toDouble();
                time12am=20-(time12am%20);
              }
            }
            else
              {
                time12am=0;
                time3am=0;
                time6am=0;
                time9am=0;
                time12pm=0;
                time3pm=0;
                time6pm=0;
                time9pm=0;
              }
          }
        });
      },
    );
  }
}

