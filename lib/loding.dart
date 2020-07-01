import 'package:qrscan/qrscan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import 'data.dart';
import 'front_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Loding extends StatefulWidget {
  @override
  _LodingState createState() => _LodingState();
}

class _LodingState extends State<Loding> {
  @override
  void initState() {
    Wakelock.enable();
    load();
    String fetchSsid=prefs.getString('SSID')??' ';
    //print('fetchssid:'+fetchSsid);
    if(fetchSsid==' ')
      {
        Scan();
      }
    else
      {
      wifi();

    }
    wifiTimer = Timer.periodic(
      Duration(seconds: 3),
      (data) {
        if (serverOnline == false) {
          wifi();
        }
      },
    );
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
        }
      },
    );
    databaseHelper.getWorkerMapList().then((value) {
      for (var map in value) {
        workers.add(map['workerName']);
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
