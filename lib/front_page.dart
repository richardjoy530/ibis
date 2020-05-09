import 'dart:async';
import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:ibis/height_page.dart';
import 'package:ibis/main.dart';

import 'data.dart';

var port = 'no port', ip = 'not hosted';
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
    connect();
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        for (var i = 0; i < deviceObjectList.length; i++) {
          if (deviceObjectList[i].motionDetected == true) {
            deviceObjectList[i].timer.cancel();
            deviceObjectList[i].power = false;
            deviceObjectList[i].motionDetected = false;
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

  void connect() async {
    ServerSocket.bind('0.0.0.0', 4042).then((sock) {
      serverSocket = sock;
      serverOnline = true;
      print('Server Hosted');
      ip = '0.0.0.0';
      port = '4042';
    }).then((sock) {
      serverSocket.listen((sock) {}).onData((clientSocket) {
        setState(() {
          print([clientSocket.remoteAddress, clientSocket.remotePort]);
          deviceObjectList.add(DeviceObject(
              socket: clientSocket,
              name: clientSocket.remotePort.toString(),
              time: Duration(minutes: 0)));
        });
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffb9dfe6),
        leading: Container(
          height: 30,
          width: 30,
          child: FlareActor(
            'assets/status.flr',
            animation: 'Connected',
          ),
        ),
        title: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 200),
              child: Text(
                'Ibis Sterilyzer',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  'Connected Devices:${deviceObjectList.length}',
                  style: TextStyle(fontSize: 15),
                ),
                Text('\t\t\t\t\tHost ip:$ip', style: TextStyle(fontSize: 15)),
                Text('\t\t\t\t\tPort:$port', style: TextStyle(fontSize: 15))
              ],
            )
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffb9dfe6), Color(0xffffffff)]),
        ),
        child: ListView.builder(
            itemCount: deviceObjectList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.power),
                title: Text(
                    '${deviceObjectList[index].socket.remoteAddress.address.toString()} : ${deviceObjectList[index].socket.remotePort}'),
                subtitle: Visibility(
                  visible: deviceObjectList[index].power,
                  child: LinearProgressIndicator(
                    value: deviceObjectList[index].linearProgressBarValue,
                    backgroundColor: Colors.white,
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        deviceObjectList[index].motionDetected == false
                            ? Colors.green
                            : Colors.red),
                  ),
                ),
                trailing: Visibility(
                  visible: deviceObjectList[index].motionDetected,
                  child: Icon(
                    Icons.add_alert,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            deviceObjectList[index].power == false
                                ? HeightPage(deviceObjectList[index])
                                : HomePage(deviceObjectList[index])),
                  );
                },
              );
            }),
      ),
    );
  }
}
