import 'dart:async';
import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:ibis/height_page.dart';
import 'package:ibis/main.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'data.dart';
import 'test_screen.dart';

List<DeviceObject> deviceObjectList = [];
List<String> ipList = [];
List<Socket> sockets = [];
ServerSocket serverSocket;
bool serverOnline = false;

class FrontPage extends StatefulWidget {
  @override
  FrontPageState createState() => FrontPageState();
}

class FrontPageState extends State<FrontPage> with TickerProviderStateMixin {
  Timer timer;
  TextEditingController nameController;
  @override
  void initState() {
    nameController = TextEditingController();
    getIpList();
    test();
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        for (var i = 0; i < deviceObjectList.length; i++) {
          //print(prefs.getInt('${deviceObjectList[i].ip}totalDuration'));
          if (deviceObjectList[i].motionDetected == true &&
              deviceObjectList[i].power == true) {
            deviceObjectList[i].timer.cancel();
            deviceObjectList[i].power = false;
            //deviceObjectList[i].motionDetected = false;
          }

          if (deviceObjectList[i].power == true) {
            deviceObjectList[i].linearProgressBarValue =
                (1 / deviceObjectList[i].time.inSeconds) *
                    deviceObjectList[i].timer.tick;
            if (deviceObjectList[i].timer.tick >
                deviceObjectList[i].time.inSeconds) {
              deviceObjectList[i].power = false;
              deviceObjectList[i].timer.cancel();
              deviceObjectList[i].progressDegrees = 0;
            }
          }
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffffffff), Color(0xffffffff)]),
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 30,
                      width: 30,
                      child: FlareActor(
                        'assets/status.flr',
                        animation: 'Connected',
                      ),
                    ),
                  ),
                  Expanded(child: Image.asset('images/razecov.jfif')),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      color: Color(0xff02457a),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SocketScreen()),
                        );
                      },
                    ),
                  )
                ],
              ),
              serverOnline == true
                  ? deviceObjectList.length == 0
                      ? Center(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xffd6e7ee),
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              leading: Icon(Icons.wifi_tethering),
                              title: Text('Please connect your device!'),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                              itemCount: deviceObjectList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Color(0xff83caec),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ListTile(
                                    leading: Icon(
                                      deviceObjectList[index].offline == true
                                          ? Icons.signal_wifi_off
                                          : Icons.network_wifi,
                                      color: Color(0xff02457a),
                                    ),
                                    trailing:deviceObjectList[index].motionDetected==true?
                                    Icon(
                                        Icons.warning,
                                        color: Color(0xff02457a),
                                      )
                                    :Container(
                                      height: 70,
                                      width: 50,
                                      child: GestureDetector(
                                        child:Icon(
                                        Icons.info,
                                        color: Color(0xff02457a),
                                           ),
                                        onTap: ()
                                        {
                                          info(context, deviceObjectList[index]);
                                        },
                                      ),
                                    ),

                                    title:
                                        Text('${deviceObjectList[index].name}'),
                                    subtitle: deviceObjectList[index].power ==
                                            false
                                        ? Text(deviceObjectList[index]
                                                    .offline ==
                                                true
                                            ? 'Device is Offline'
                                            : deviceObjectList[index]
                                                        .motionDetected ==
                                                    false
                                                ? 'Device Idle'
                                                : 'Motion Detected : Tap to start again')
                                        : LinearPercentIndicator(
                                            lineHeight: 5.0,
                                            animation: false,
                                            animationDuration: 0,
                                            backgroundColor: Color(0xffd6e7ee),
                                            percent: deviceObjectList[index]
                                                .linearProgressBarValue,
                                            linearStrokeCap:
                                                LinearStrokeCap.roundAll,
                                            progressColor: Color(0xff018abe),
                                          ),
                                    onTap: () {
                                      if (deviceObjectList[index].offline ==
                                          false) {
                                        if (deviceObjectList[index].power ==
                                            true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                    deviceObjectList[index])),
                                          );
                                        } else {
                                          deviceObjectList[index]
                                              .motionDetected = false;
                                          deviceObjectList[index].time =
                                              Duration(minutes: 1);
                                          deviceObjectList[index]
                                              .progressDegrees = 0;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HeightPage(deviceObjectList[
                                                        index])),
                                          );
                                        }
                                      }
                                    },
                                    onLongPress: () {
                                      setName(context, deviceObjectList[index]);
                                    },
                                  ),
                                );
                              }),
                        )
                  : AlertDialog(
                      backgroundColor: Color(0xff83caec),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      title: Text('Server is Offline'),
                      content: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          connect();
                        },
                      ),
                    ),
            ],
          )),
    );
  }

  Future<void> info(context,DeviceObject deviceObject)async
  {
    await showDialog(context: context,
    builder: (BuildContext context){
      return SimpleDialog(
        title: Column(
          children: <Widget>[
            Text(deviceObject.name),
            Row(
              children: <Widget>[
                Text('Total Duration'),
                Text(((prefs.getInt('${deviceObject.ip}totalDuration')/(60*60)).floor()).toString()+':'),
                Text(((prefs.getInt('${deviceObject.ip}totalDuration')/60).floor()).toString()+':'),

              ],
            ),
          ],
        ),

      );
    }

    );
  }

  Future<void> setName(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xff83caec),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Give a name for your device',
              style: TextStyle(
                  color: Color(0xff02457a), fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Enter name'),
                  onSubmitted: (name) {
                    deviceObject.name = nameController.text;
                    prefs.setString('${deviceObject.ip}name', name);
                    nameController.text = '';
                    Navigator.pop(context);
                  },
                ),
              ),
              SimpleDialogOption(
                child: Text('OK'),
                onPressed: () {
                  deviceObject.name = nameController.text;
                  prefs.setString(
                      '${deviceObject.ip}name', nameController.text);
                  nameController.text = '';
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> setHeightYN(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffdec3e4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Do you want height?',
              style: TextStyle(
                  color: Color(0xff83caec), fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Yes'),
                onPressed: () {
                  deviceObject.motionDetected = false;
                  deviceObject.socket.write('2\r');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HeightPage(deviceObject)),
                  );
                },
              ),
              SimpleDialogOption(
                  child: Text('No'),
                  onPressed: () {
                    deviceObject.motionDetected = false;
                    deviceObject.socket.write('-2\r');
                    deviceObject.time = Duration(minutes: 1);
                    deviceObject.progressDegrees = 0;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(deviceObject)),
                    );
                  })
            ],
          );
        });
  }
}
