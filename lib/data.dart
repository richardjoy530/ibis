import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'height_page.dart';
import 'main.dart';

int displayTime;
int doubleTapDown = 0;
int doubleTapUp = 0;
bool topHit = false;
bool bottumHit = false;
int maxTime = 0;
double eachGraphSpace = 47;
double time12am = 0,
    time3am = 0,
    time6am = 0,
    time9am = 0,
    time12pm = 0,
    time3pm = 0,
    time6pm = 0,
    time9pm = 0;
DateTime startTime;
bool stopPressed = false;
//CalendarController _calendarController;
bool connectionError = false;
SharedPreferences prefs;
String deviceName;
int deviceHeight;
List<String> exportRooms = [], exportWorkers = [], exportState = [];
List<String> exportStartTime = [], exportEndTime = [], exportTimeNow = [];
List<String> exportElapseTime = [], exportTime = [];
DatabaseHelper databaseHelper;
String room;
String worker;
List<History> historyList = [];
List<TimeData> timeDataList = [];
List<String> rooms = [];
List<String> workers = [];
bool animationChecking = false;
String animationText = '';
int dotTimer = 0;
double dot = 0.0;
List<DeviceObject> deviceObjectList = [];
List<String> ipList = [];
List<Socket> sockets = [];
ServerSocket serverSocket;
bool serverOnline = false;
bool animationRunning = false;
bool isEnabled = false;
Timer wifiTimer;
bool isConnected = false;
String serverIp;
int screenLengthConstant = 0;
int nameNumber = 1;
List<TextEditingController> roomNames = [];
final List<bool> isSelected = [false];

class DeviceObject {
  Duration remainingTime;
  DateTime startTime;
  bool temp;
  bool completedStatus;
  int elapsedTime;
  Duration mainTime;
  bool offline;
  String flare;
  Duration totalDuration;
  Duration secondDuration;
  String ip;
  bool pause;
  Socket socket;
  bool clientError = false;
  String name;
  bool power;
  double linearProgressBarValue;
  AnimationController radialProgressAnimationController;
  Animation<double> progressAnimation;
  double progressDegrees;
  Duration time;
  Timer timer;
  bool motionDetected;
  bool earlyMotionDetection;
  double height;
  String earlyMotionDetectionTime;

  DeviceObject({
    this.temp,
    this.flare = 'off',
    this.elapsedTime = 0,
    this.ip,
    this.offline,
    this.name,
    this.socket,
    this.radialProgressAnimationController,
    this.timer,
    this.clientError,
    this.height = 0,
    this.mainTime,
    this.motionDetected = false,
    this.progressAnimation,
    this.linearProgressBarValue = 0,
    this.power = false,
    this.time,
    this.progressDegrees = 0,
    this.pause = false,
    this.totalDuration,
    this.secondDuration,
    this.earlyMotionDetection = false,
    this.earlyMotionDetectionTime = '',
    this.completedStatus = false,
  });

  void run() {
    socket.listen((onData) {
      print([socket.remotePort, onData]);
      if (onData.length == 5) {
        String chData = String.fromCharCode(onData[0]);
        if (chData == 'm') {
          String data1 = String.fromCharCode(onData[1]);
          String data2 = String.fromCharCode(onData[2]);
          String com = data1 + data2;
          this.earlyMotionDetectionTime = com;
          this.earlyMotionDetection = true;
        }
      }
      if (String.fromCharCode(onData[0]) == 'c') {
        this.completedStatus = true;
      }
      if (String.fromCharCode(onData[0]) == 't') {
        flare = 'idle';
        downArrowColor = Color(0xff5cbceb);
        downBGColor = Color(0xff02457a);
        upArrowColor = Color(0xff5cbceb);
        upBGColor = Color(0xff02457a);
        topHit = true;
      }
      if (String.fromCharCode(onData[0]) == 'b') {
        flare = 'idle';
        downArrowColor = Color(0xff5cbceb);
        downBGColor = Color(0xff02457a);
        upArrowColor = Color(0xff5cbceb);
        upBGColor = Color(0xff02457a);
        bottumHit = true;
      }

      if (String.fromCharCode(onData[0]) == 'd') {
        flare = 'idle';
        downArrowColor = Color(0xff5cbceb);
        downBGColor = Color(0xff02457a);
        upArrowColor = Color(0xff5cbceb);
        upBGColor = Color(0xff02457a);
      }

      if (this.offline == false) {
        if (onData[0] == 50) {
          print(
            [socket.remotePort, onData],
          );

          this.motionDetected = true;
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
                    String dateTimeNow = timeDataList[timeDataList.length - 1]
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
                      y: timeDataList[timeDataList.length - 1].elapsedTime / 60,
                      color: Colors.lightBlueAccent),
                ], showingTooltipIndicators: [
                  0
                ])
              ],
            )),
          ));

          databaseHelper.insertTimeData(
            TimeData(
                roomName: room,
                status: 'Motion Detected',
                workerName: worker,
                startTime: this.startTime,
                endTime: DateTime.now(),
                elapsedTime: this.elapsedTime,
                time: this.remainingTime.inSeconds.toInt()),
          );
          timeDataList.add(
            TimeData(
                roomName: room,
                status: 'Motion Detected',
                workerName: worker,
                startTime: this.startTime,
                endTime: DateTime.now(),
                elapsedTime: this.elapsedTime,
                time: this.remainingTime.inSeconds.toInt()),
          );
          databaseHelper.insertHistory(History(
              roomName: room,
              workerName: worker,
              state: 'Motion Detected',
              time: DateTime.now()));
          historyList.add(
            History(
              roomName: room,
              workerName: worker,
              state: 'Motion Detected',
              time: DateTime.now(),
            ),
          );


          notification('Motion was detected');
        }
      }
    })
      ..onError(
        (handleError) {
          print('Client Error : ${handleError.toString()}');
          serverOnline = false;
          this.linearProgressBarValue = 0.0;
          serverSocket.close();
          this.clientError = true;
          this.socket.close();
        },
      )
      ..onDone(
        () {
          print('Client onDone');

          this.linearProgressBarValue = 0.0;
          this.socket.close();
          this.clientError = true;
          this.offline = true;
          if (this.power == true) {
            this.timer.cancel();
            databaseHelper.insertHistory(
              History(
                roomName: room,
                workerName: worker,
                state: 'Error : Device disconnected',
                time: DateTime.now(),
              ),
            );
            historyList.add(
              History(
                roomName: room,
                workerName: worker,
                state: 'Error : Device disconnected',
                time: DateTime.now(),
              ),
            );
          }
        },
      );
  }
}

class History {
  String roomName;
  String workerName;
  String state;
  DateTime time;

  History({this.roomName, this.state, this.time, this.workerName});
}

class TimeData {
  DateTime startTime;
  DateTime endTime;
  String roomName;
  String workerName;
  int elapsedTime;
  int time;
  String status;

  TimeData(
      {this.startTime,
      this.elapsedTime,
      this.endTime,
      this.time,
      this.status,
      this.roomName,
      this.workerName});
}

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'ibis.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE TimeData (id INTEGER PRIMARY KEY AUTOINCREMENT , roomName TEXT, workerName TEXT, status TEXT, startTime TEXT, endTime TEXT, elapsedTime INTEGER, time INTEGER)');
    await db.execute(
        'CREATE TABLE Rooms (id INTEGER PRIMARY KEY AUTOINCREMENT , roomName TEXT)');
    await db.execute(
        'CREATE TABLE Workers (id INTEGER PRIMARY KEY AUTOINCREMENT , workerName TEXT)');
    await db.execute(
        'CREATE TABLE History (id INTEGER PRIMARY KEY AUTOINCREMENT , workerName TEXT , roomName TEXT , time TEXT, state TEXT)');
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertRoom(String room) async {
    Database db = await this.database;
    var result = await db.insert('Rooms', {'roomName': room});
    return result;
  }

  Future<int> insertWorker(String worker) async {
    Database db = await this.database;
    var result = await db.insert('Workers', {'workerName': worker});
    return result;
  }

  Future<int> insertHistory(History history) async {
    Database db = await this.database;
    var result = await db.insert('History', {
      'workerName': history.workerName,
      'roomName': history.roomName,
      'time': history.time.toIso8601String(),
      'state': history.state
    });
    return result;
  }

  Future<int> insertTimeData(TimeData timeData) async {
    Database db = await this.database;
    var result = await db.insert('TimeData', {
      'workerName': timeData.workerName,
      'roomName': timeData.roomName,
      'status': timeData.status,
      'startTime': timeData.startTime.toIso8601String(),
      'endTime': timeData.endTime.toIso8601String(),
      'time': timeData.time,
      'elapsedTime': timeData.elapsedTime
    });
    return result;
  }

  Future<List<Map<String, dynamic>>> getRoomMapList() async {
    Database db = await this.database;
    var result = await db.query('Rooms');
    return result;
  }

  Future<List<Map<String, dynamic>>> getWorkerMapList() async {
    Database db = await this.database;
    var result = await db.query('Workers');
    return result;
  }

  Future<List<Map<String, dynamic>>> getHistoryMapList() async {
    Database db = await this.database;
    var result = await db.query('History');
    return result;
  }

  Future<List<Map<String, dynamic>>> getTimeDataMapList() async {
    Database db = await this.database;
    var result = await db.query('TimeData');
    return result;
  }

  Future<int> deleteRoom(String room) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM Rooms WHERE roomName = "$room"');
    return result;
  }

  Future<int> deleteWorker(String worker) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM Workers WHERE workerName = "$worker"');
    return result;
  }
}
