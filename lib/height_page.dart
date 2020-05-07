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
          children: <Widget>[
            Text('Do you want height'),
            Visibility(
              visible: quesVis,
              child: Row(
                children: <Widget>[
                  RaisedButton(
                      child: Text('YES'),
                      onPressed: () {
                        widget.deviceObject.wantHeight = true;
                      }),
                  RaisedButton(
                      child: Text('NO'),
                      onPressed: () {
                        widget.deviceObject.wantHeight = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(widget.deviceObject)),
                        );
                      }),
                  Visibility(
                      child: Column(
                    children: <Widget>[
                      Listener(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () {
                              print('[*]');
                            },
                          ),
                        ),
                        onPointerDown: (data) {
                          print('tap up');
                          //tap = true;
                          //heightOnTap(socket, '1');
                        },
                        onPointerUp: (data) {
                          print('cancel');
                          //tap = false;
                        },
                      ),
                      Listener(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () {
                              print('[*]');
                            },
                          ),
                        ),
                        onPointerDown: (data) {
                          print('tap up');
                          //tap = true;
                          //heightOnTap(socket, '-1');
                        },
                        onPointerUp: (data) {
                          print('cancel');
                          //tap = false;
                        },
                      ),
                      ListTile(
                        title: Text('Confirm height ?'),
                        trailing: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              print('confirm');
                              setState(() {
                                widget.deviceObject.isHeightSet = true;
                              });
                              Navigator.pop(context);
                            }),
                      ),
                    ],
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
