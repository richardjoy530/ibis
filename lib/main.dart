import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BalooTamma2',
      ),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool power = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffb9dfe6), Color(0xffffffff)]),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.all(8),
                  leading: IconButton(
                    icon: Icon(Icons.wifi),
                    color: Color(0xff3d84a7),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SocketScreen()),
                      );
                    },
                  ),
                  title: Text(
                    'Ibis Analyser',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Connected',
                    style: TextStyle(color: Color(0xff47466d)),
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.center_focus_weak,
                          color: Color(0xff3d84a7)),
                      onPressed: null),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        print('tap');
                        power = !power;
                      });
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      child: FlareActor('assets/powerButton.flr',
                          //alignment: Alignment.center,
                          animation: power == true ? "on" : "off"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocketScreen extends StatefulWidget {
  @override
  _SocketScreenState createState() => _SocketScreenState();
}

class _SocketScreenState extends State<SocketScreen> {
  TextEditingController textEditingController;
  TextEditingController ipEditingController;
  bool isConnected = false;
  Socket socket;
  String serverIP = '192.168.18.5';
  void connect() async {
    Socket.connect(serverIP, 80).then((sock) {
      setState(() {
        isConnected = true;
      });
      socket = sock;
      sock.listen((onData) {
        print(String.fromCharCodes(onData));
      });
    });
  }

  @override
  void initState() {
    textEditingController = TextEditingController();
    ipEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    socket.close();
    textEditingController.dispose();
    ipEditingController.dispose();
    super.dispose();
  }

  @override
  //Testing
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                onTap: () {
                  setServerIP(context);
                },
                leading: Icon(Icons.computer),
                title: Text('Connect to a TCP server'),
                subtitle: Text(
                    'Connected to : ${isConnected == false ? 'None' : serverIP}'),
              ),
              ListTile(
                title: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: 'Type text to send',
                      disabledBorder: InputBorder.none),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    socket.write(textEditingController.text);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setServerIP(context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Set your server IP',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.computer,
              ),
              title: TextField(
                keyboardType: TextInputType.number,
                controller: ipEditingController,
                decoration: InputDecoration(
                    hintText: 'Server IP ....',
                    disabledBorder: InputBorder.none),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    serverIP = ipEditingController.text;
                    connect();
                    Navigator.pop(context);
                  }),
            )
          ],
        );
      },
    );
  }
}
