import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class DeviceObject {
  Socket socket;
  String name;
  bool power;
  double linearProgressBarValue;
  AnimationController radialProgressAnimationController;
  Animation<double> progressAnimation;
  double progressDegrees;
  double time;
  Timer timer;
  bool isHeightSet;
  DeviceObject({
    this.name,
    this.socket,
    this.radialProgressAnimationController,
    this.timer,
    this.progressAnimation,
    this.linearProgressBarValue = 0,
    this.power = false,
    this.isHeightSet = false,
    this.time = 1,
    this.progressDegrees = 0,
  }) {
    socket.listen((onData) {
      print([socket.remotePort, onData]);
    });
  }
}
