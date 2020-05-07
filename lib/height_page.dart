import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'main.dart';

class HeightPage extends StatefulWidget {
  final DeviceObject deviceObject;
  HeightPage(this.deviceObject);
  @override
  _HeightPageState createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  bool quesVis = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: quesVis,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Do you want height'),
                  RaisedButton(
                      child: Text('YES'),
                      onPressed: () {
                        widget.deviceObject.wantHeight = true;
                        widget.deviceObject.socket.write('yes');
                        setState(() {
                          quesVis = !quesVis;
                        });
                      }),
                  RaisedButton(
                      child: Text('NO'),
                      onPressed: () {
                        widget.deviceObject.wantHeight = false;
                        widget.deviceObject.socket.write('no');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(widget.deviceObject)),
                        );
                      }),
                ],
              ),
            ),
            Visibility(
                visible: !quesVis,
                child: Column(
                  children: <Widget>[
                    Listener(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: IconButton(
                          icon: Icon(Icons.arrow_upward),
                          onPressed: () {
                            print('[*]');
                          },
                        ),
                      ),
                      onPointerDown: (data) {
                        print('tap up');
                        widget.deviceObject.socket.write('1\n');
                      },
                      onPointerUp: (data) {
                        print('cancel');
                        widget.deviceObject.socket.write('0\n');
                      },
                    ),
                    Listener(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: IconButton(
                          icon: Icon(Icons.arrow_downward),
                          onPressed: () {
                            print('[*]');
                          },
                        ),
                      ),
                      onPointerDown: (data) {
                        print('tap up');
                        widget.deviceObject.socket.write('-1\r');
                      },
                      onPointerUp: (data) {
                        print('cancel');
                        widget.deviceObject.socket.write('0\r');
                      },
                    ),
                    ListTile(
                      title: Text('Confirm height ?'),
                      trailing: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            widget.deviceObject.socket.write('true');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(widget.deviceObject)),
                            );
                          }),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
