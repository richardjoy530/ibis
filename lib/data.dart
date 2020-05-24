import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


import 'front_page.dart';
import 'main.dart' as main;

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
        }
        this.power = false;
      });
  }
}


class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String colId = 'id';

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
        'CREATE TABLE Rooms (id INTEGER NOT NULL , roomName TEXT)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getRoomMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query('Rooms', orderBy: '$colId ASC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertRoom(String room) async {
    Database db = await this.database;
    var result = await db.insert('Rooms',{'id':1,'roomName':room});
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  // Future<int> updateNote(Note note) async {
  //   var db = await this.database;
  //   var result = await db.update(noteTable, note.toMap(),
  //       where: '$colId = ?', whereArgs: [note.id]);
  //   return result;
  // }

  // Delete Operation: Delete a Note object from database
  // Future<int> deleteNote(int id) async {
  //   var db = await this.database;
  //   int result =
  //   await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
  //   return result;
  // }

  // Future<int> deleteAllNote() async {
  //   var db = await this.database;
  //   return await db.rawDelete('DELETE FROM $noteTable');
  // }

  // Get number of Note objects in database
  // Future<int> getCount() async {
  //   Database db = await this.database;
  //   List<Map<String, dynamic>> x =
  //   await db.rawQuery('SELECT COUNT (*) from $noteTable');
  //   int result = Sqflite.firstIntValue(x);
  //   return result;
  // }


}
