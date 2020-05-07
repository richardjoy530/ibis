import 'dart:async';
import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:ibis/main.dart';

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
    connect();
    timer = Timer.periodic(Duration(seconds: 1), (callback) {
      setState(() {});
    });
    super.initState();
  }

  void connect() async {
    ServerSocket.bind('0.0.0.0', 4042).then((sock) {
      serverSocket = sock;
      serverOnline = true;
      print('Server Hosted');
    }).then((sock) {
      serverSocket.listen((sock) {}).onData((clientSocket) {
        setState(() {
          print([clientSocket.remoteAddress, clientSocket.remotePort]);
          deviceObjectList.add(DeviceObject(
              socket: clientSocket, name: clientSocket.remotePort.toString()));
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
        title: Text(
          'Ibis Sterilyzer',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.phonelink_off),
            color: Color(0xff3d84a7),
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
                    value: (1 / 360) * deviceObjectList[index].progressDegrees,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage(deviceObjectList[index])),
                  );
                },
              );
            }),
      ),
    );
  }
}
