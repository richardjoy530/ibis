import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'front_page.dart';
import 'main.dart' as main;

class DeviceObject {
  bool offline;
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
  bool pause;
  int totalDuration;
  DeviceObject({
    this.pause,
    this.ip,
    this.offline,
    this.name,
    this.socket,
    this.radialProgressAnimationController,
    this.timer,
    this.clientError,
    this.height = 0,
    this.motionDetected = false,
    this.progressAnimation,
    this.linearProgressBarValue = 0,
    this.power = false,
    this.time,
    this.progressDegrees = 0,
    this.pause=false,
    this.totalDuration=0,
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
        this.timer.cancel();
        this.power = false;
      });
  }
}
