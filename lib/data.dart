import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibis/front_page.dart';

class DeviceObject {
  Socket socket;
  String name;
  bool power;
  bool isBackground;
  double linearProgressBarValue;
  AnimationController radialProgressAnimationController;
  Animation<double> progressAnimation;
  double progressDegrees;
  Duration time;
  Timer timer;
  bool wantHeight;
  bool motionDetected;
  double height;
  //bool isHeightSet;
  DeviceObject({
    this.name,
    this.socket,
    this.isBackground = true,
    this.radialProgressAnimationController,
    this.timer,
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
        //this.power = false;
        this.motionDetected = true;
        //this.timer.cancel();
        //this.time = Duration(minutes: 0);
      }
    }).onDone(() {
      deviceObjectList.remove(deviceObjectList.singleWhere((test) {
        return this.socket == test.socket ? true : false;
      }));
    });
  }
}
