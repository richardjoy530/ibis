import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

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
                      return 'Mn';
                    case 1:
                      return 'Te';
                    case 2:
                      return 'Wd';
                    case 3:
                      return 'Tu';
                    case 4:
                      return 'Fr';
                    case 5:
                      return 'St';
                    case 6:
                      return 'Sn';
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
                  barRods: [BarChartRodData(y: 8, color: Colors.lightBlueAccent)],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(y: 10, color: Colors.lightBlueAccent)],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 2,
                  barRods: [BarChartRodData(y: 14, color: Colors.lightBlueAccent)],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 3,
                  barRods: [BarChartRodData(y: 15, color: Colors.lightBlueAccent)],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 3,
                  barRods: [BarChartRodData(y: 13, color: Colors.lightBlueAccent)],
                  showingTooltipIndicators: [0]),
              BarChartGroupData(
                  x: 3,
                  barRods: [BarChartRodData(y: 10, color: Colors.lightBlueAccent)],
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
        print(date);
        setState(() {
         // _selectedEvents=_events[date];
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

