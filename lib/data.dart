import 'dart:io';

import 'package:flutter/animation.dart';

class DeviceObject {
  // ignore: close_sinks
  Socket socket;
  String name;
  bool power;
  AnimationController radialProgressAnimationController;
  Animation<double> progressAnimation;
  double progressDegrees;
  double time;
  bool isHeightSet;
  DeviceObject({
    this.name,
    this.socket,
    this.radialProgressAnimationController,
    this.progressAnimation,
    this.power = false,
    this.isHeightSet = false,
    this.time = 1,
    this.progressDegrees = 0,
  });
}
