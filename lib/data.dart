import 'dart:async';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'front_page.dart';

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
  bool isMotion;
  bool wantHeight;
  //bool isHeightSet;
  DeviceObject({
    this.name,
    this.socket,
    this.radialProgressAnimationController,
    this.timer,
    this.isMotion = false,
    this.wantHeight,
    this.progressAnimation,
    this.linearProgressBarValue = 0,
    this.power = false,
    //this.isHeightSet = false,
    this.time = 1,
    this.progressDegrees = 0,
  }) {
    socket.listen((onData) {
      print([socket.remotePort, onData]);
      if(String.fromCharCodes(onData).trim()=='motion')
        {
           isMotion=true;
           print('motion dected');

        }
    }).onDone((){
      devno=devno-1;
      deviceObjectList.remove(deviceObjectList.singleWhere((test){
        return this.socket==test.socket?true:false;
      }));
    });

  }
}



