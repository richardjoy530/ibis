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
  //Map<DateTime, List> _events;
  //List _selectedEvents;
  //AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    //final _selectedDay = DateTime.now();

    // _events = {
    //   _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
    //   _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
    //   _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
    //   _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
    //   _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
    //   _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
    //   _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //   _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
    //   _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
    //   _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
    //   _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
    //   _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
    //   _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
    //   _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
    //   _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
    // };

    //_selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

   // _animationController = AnimationController(
    //  vsync: this,
   //   duration: const Duration(milliseconds: 400),
  //  );

    //_animationController.forward();
  }

  @override
  void dispose() {
   // _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0,20.0,0.0,0.0),
            child: _buildTableCalendar(),
          ),
          // _buildTableCalendarWithBuilders(),
          //const SizedBox(height: 8.0),
          //_buildButtons(),
          //const SizedBox(height: 8.0),
          Expanded(
              child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
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
                    color: const Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
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
                      return '9AM';
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
      //events: _events,
     // holidays: _holidays,
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
                     time3am=time3am+timeDataList[i].elapsedTime.toDouble();
                     time3am=20-(time3am%20);
                   }
                 if(timeDataList[i].startTime.hour>=3 &&timeDataList[i].startTime.hour<6)
                 {
                   time6am=time6am+timeDataList[i].elapsedTime.toDouble();
                   time6am=20-(time6am%20);
                 }
                 if(timeDataList[i].startTime.hour>=6 &&timeDataList[i].startTime.hour<9)
                 {
                   time9am=time9am+timeDataList[i].elapsedTime.toDouble();
                   time9am=20-(time9am%20);
                 }
                 if(timeDataList[i].startTime.hour>=9 &&timeDataList[i].startTime.hour<12)
                 {
                   time12pm=time12pm+timeDataList[i].elapsedTime.toDouble();
                   time12pm=20-(time12pm%20);
                 }
                 if(timeDataList[i].startTime.hour>=12 &&timeDataList[i].startTime.hour<15)
                 {
                   time3pm=time3pm+timeDataList[i].elapsedTime.toDouble();
                   time3pm=20-(time3pm%20);
                 }
                 if(timeDataList[i].startTime.hour>=15 &&timeDataList[i].startTime.hour<18)
                 {
                   time6pm=time3am+timeDataList[i].elapsedTime.toDouble();
                   time6pm=20-(time6pm%20);
                 }
                 if(timeDataList[i].startTime.hour>=18 &&timeDataList[i].startTime.hour<21)
                 {
                   time9pm=time9pm+timeDataList[i].elapsedTime.toDouble();
                   time9pm=20-(time9pm%20);
                 }
                 if(timeDataList[i].startTime.hour>=21 &&timeDataList[i].startTime.hour<24)
                 {
                   time12am=time12am+timeDataList[i].elapsedTime.toDouble();
                   time12am=20-(time12am%20);
                 }
               }
           }
        });
     },
    //  onVisibleDaysChanged: _onVisibleDaysChanged,
     // onCalendarCreated: _onCalendarCreated,
    );
  }
  // Widget _buildEventList() {
  //   return ListView(
  //     children: _selectedEvents
  //         .map((event) => Container(
  //       decoration: BoxDecoration(
  //         border: Border.all(width: 0.8),
  //         borderRadius: BorderRadius.circular(12.0),
  //       ),
  //       margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  //       child: ListTile(
  //         title: Text(event.toString()),
  //         onTap: () => print('$event tapped!'),
  //       ),
  //     ))
  //         .toList(),
  //   );
  // }
}

