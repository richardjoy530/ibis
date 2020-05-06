import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Socket socket;

class SocketScreen extends StatefulWidget {
  @override
  _SocketScreenState createState() => _SocketScreenState();
}

class _SocketScreenState extends State<SocketScreen> {
  TextEditingController textEditingController;
  TextEditingController ipEditingController;
  TextEditingController portEditingController;
  String serverIP = '0.0.0.0';
  int port = 4041;
  String incomingMessages = '';
  bool isConnected = false;
  bool fetching = false;
  List<Socket> socketList = [];
  bool tap = false;
  bool _loopActive = false;

  @override
  void initState() {
    textEditingController = TextEditingController();
    ipEditingController = TextEditingController();
    ipEditingController.text = serverIP;
    portEditingController = TextEditingController();
    portEditingController.text = '4041';
    super.initState();
  }

  @override
  void dispose() {
    for (var s in socketList) {
      s.close();
      s.destroy();
    }
    socketList = [];
    textEditingController.dispose();
    ipEditingController.dispose();
    portEditingController.dispose();
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
                title: Text('Create a TCP server'),
                subtitle: Text(
                    'Hosted TCP server on : ${isConnected == false ? 'None' : serverIP}'),
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
                    for (var s in socketList) {
                      s.write(textEditingController.text);
                    }
                    textEditingController.text = '';
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Listener(
                      child: Icon(Icons.arrow_upward),
                      onPointerDown: (data) {
                        print('tap up');
                        tap = true;
                        heightOnTap(socket, '1');
                      },
                      onPointerUp: (data) {
                        print('cancel');
                        tap = false;
                      },
                    ),
                    Listener(
                      child: Icon(Icons.arrow_downward),
                      onPointerDown: (data) {
                        print('tap up');
                        tap = true;
                        heightOnTap(socket, '-1');
                      },
                      onPointerUp: (data) {
                        print('cancel');
                        tap = false;
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.check_circle),
                        onPressed: () {
                          socket.write('true');
                        })
                  ],
                ),
              ),
              Container(
                child: ListTile(
                    trailing: IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: () {
                        setState(() {
                          incomingMessages = '';
                        });
                      },
                    ),
                    title: Text('Recived data'),
                    subtitle: Text(incomingMessages)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  heightOnTap(Socket socket, String value) async {
    if (_loopActive) return;
    _loopActive = true;
    while (tap == true) {
      socket.write('$value\n\r');
      await Future.delayed(Duration(milliseconds: 100));
    }
    _loopActive = false;
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
                    hintText: 'Server IP', disabledBorder: InputBorder.none),
              ),
            ),
            ListTile(
              title: TextField(
                keyboardType: TextInputType.number,
                controller: portEditingController,
                decoration: InputDecoration(
                    hintText: 'Port', disabledBorder: InputBorder.none),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    port = int.parse(portEditingController.text);
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

  void connect() async {
    ServerSocket.bind(serverIP, port).then((serverSocket) {
      setState(() {
        isConnected = true;
      });
      serverSocket.listen((sock) {
        // print([sock.address, sock.remoteAddress]);
        //fetch();
      }).onData((sock) {
        socket = sock;
        socketList.add(socket);
        print(socketList);
        print([sock.remoteAddress, sock.remotePort, socketList.length]);
        sock.listen((onData) {
          setState(() {
            incomingMessages = incomingMessages + String.fromCharCodes(onData);
          });
        });
      });
    });
  }
}
