import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'front_page.dart';
import 'main.dart' as main;

class DeviceObject {
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
  }) {
    socket.listen((onData) {
      print([socket.remotePort, onData]);
      if (String.fromCharCodes(onData).trim() == '1') {
        this.motionDetected = true;
        main.notification('Motion was detected');
      }
    })
      ..onError((handleError) {
        print('Client Error : ${handleError.toString()}');
        deviceObjectList = [];
        serverOnline = false;
        serverSocket.close();
        this.clientError = true;
        this.socket.close();
      })
      ..onDone(() {
        this.socket.close();
        this.clientError = true;
        if (serverOnline == true) {
          deviceObjectList.remove(deviceObjectList.singleWhere((test) {
            return this.socket == test.socket ? true : false;
          }));
        }
      });
  }
}
