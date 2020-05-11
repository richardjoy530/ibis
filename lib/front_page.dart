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
List<Socket> sockets = [];
ServerSocket serverSocket;
bool serverOnline = false;

class FrontPage extends StatefulWidget {
  @override
  FrontPageState createState() => FrontPageState();
}

class FrontPageState extends State<FrontPage> with TickerProviderStateMixin {
  Timer timer;
  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        for (var i = 0; i < deviceObjectList.length; i++) {
          if (deviceObjectList[i].motionDetected == true) {
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
    print('Front Page Disposed');
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffe9ea),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 30,
            width: 30,
            child: FlareActor(
              'assets/status.flr',
              animation: 'Connected',
            ),
          ),
        ),
        title: Text(
          'Ibis Sterilyzer',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xff3b338b),
            //fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            color: Color(0xff725496),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SocketScreen()),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffffe9ea), Color(0xffffffff)]),
        ),
        child: serverOnline == true
            ? deviceObjectList.length == 0
                ? Center(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Color(0xffdec3e4),
                          borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        leading: Icon(Icons.wifi_tethering),
                        title: Text('Please connect your device!'),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: deviceObjectList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Color(0xffdec3e4),
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: Icon(
                            Icons.network_wifi,
                            color: Color(0xff725496),
                          ),
                          trailing: Visibility(
                            visible: deviceObjectList[index].motionDetected,
                            child: Icon(
                              Icons.warning,
                              color: Color(0xff725496),
                            ),
                          ),
                          title: Text(
                              '${deviceObjectList[index].socket.remoteAddress.address.toString()} : ${deviceObjectList[index].socket.remotePort}'),
                          subtitle: deviceObjectList[index].power == false
                              ? Text(deviceObjectList[index].motionDetected ==
                                      false
                                  ? 'Device Idle'
                                  : 'Motion Detected : Tap to start again')
                              : LinearPercentIndicator(
                                  lineHeight: 5.0,
                                  animation: false,
                                  animationDuration: 0,
                                  backgroundColor: Color(0xffffe9ea),
                                  percent: deviceObjectList[index]
                                      .linearProgressBarValue,
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  progressColor: Color(0xff9a6c9f),
                                ),
                          onTap: () {
                            if (deviceObjectList[index].power == true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(deviceObjectList[index])),
                              );
                            } else {
                              deviceObjectList[index].motionDetected = false;
                              deviceObjectList[index].time =
                                  Duration(minutes: 1);
                              deviceObjectList[index].progressDegrees = 0;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HeightPage(deviceObjectList[index])),
                              );
                            }
                          },
                        ),
                      );
                    })
            : AlertDialog(
                backgroundColor: Color(0xffdec3e4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text('Server is Offline'),
                content: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    connect();
                  },
                ),
              ),
      ),
    );
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
                  color: Colors.blueGrey, fontWeight: FontWeight.bold),
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
