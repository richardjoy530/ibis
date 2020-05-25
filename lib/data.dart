import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'front_page.dart';
import 'main.dart' as main;
import 'main.dart';

class DeviceObject {
  bool temp;
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
  double height;
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
  });
  void run() {
    socket.listen((onData) {
      print([socket.remotePort, onData]);
      if (this.offline == false) {
        if (String.fromCharCodes(onData).trim() == '1') {
          this.motionDetected = true;
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

          main.notification('Motion was detected');
        }
      }
    })
      ..onError((handleError) {
        print('Client Error : ${handleError.toString()}');
        serverOnline = false;
        serverSocket.close();
        this.clientError = true;
        this.socket.close();
      })
      ..onDone(() {
        this.socket.close();
        this.clientError = true;
        this.offline = true;
        if (this.power == true) {
          this.timer.cancel();
          databaseHelper.insertHistory(History(
              roomName: room,
              workerName: worker,
              state: 'Error : Device disconnected',
              time: DateTime.now()));
          historyList.add(
            History(
              roomName: room,
              workerName: worker,
              state: 'Error : Device disconnected',
              time: DateTime.now(),
            ),
          );
        }
        this.power = false;
      });
  }
}

class History {
  String roomName;
  String workerName;
  String state;
  DateTime time;
  History({this.roomName, this.state, this.time, this.workerName});
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

}
