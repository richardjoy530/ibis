import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibis/data.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
//import 'data.dart';

class CalenderPage extends StatefulWidget {
  @override
  _CalenderPageState createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  Map<DateTime, List> _events;
  List _selectedEvents;
  //AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
      _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
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
              child: _buildEventList()
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
        print(historyList.length);
        setState(() {
         // _selectedEvents=_events[date];
        });
     },
    //  onVisibleDaysChanged: _onVisibleDaysChanged,
     // onCalendarCreated: _onCalendarCreated,
    );
  }
  Widget _buildEventList() {
    return Container(
      padding: EdgeInsets.all(8.0),
      height:MediaQuery.of(context).size.height/2,
      width: MediaQuery.of(context).size.width/1,
      child: BarChart(

      ),
    );
  }
}

