import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibis/height_bar.dart';

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
      appBar: AppBar(
        backgroundColor: Color(0xffb9dfe6),
        automaticallyImplyLeading: false,
        title: Text(
          'Adjust Height',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffb9dfe6), Color(0xffffffff)]),
        ),
        child: Center(
          child: quesVis == true
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('Do you want height'),
                    RaisedButton(
                        child: Text('YES'),
                        onPressed: () {
                          widget.deviceObject.socket.write('2\r');
                          setState(() {
                            quesVis = !quesVis;
                          });
                        }),
                    RaisedButton(
                        child: Text('NO'),
                        onPressed: () {
                          widget.deviceObject.socket.write('-2\r');
                          widget.deviceObject.time = Duration(minutes: 1);
                          widget.deviceObject.progressDegrees = 0;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(widget.deviceObject)),
                          );
                        }),
                  ],
                )
              : Stack(

                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  alignment: Alignment.center,
                  children: <Widget>[
                    CustomPaint(
                      child: Text(''),
                      painter: HeightPainter(55),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Listener(
                          child: IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () {
                              print('[*]');
                            },
                          ),
                          onPointerDown: (data) {
                            print('tap up');
                            widget.deviceObject.socket.write('1\r');
                          },
                          onPointerUp: (data) {
                            print('cancel');
                            widget.deviceObject.socket.write('0\r');
                          },
                        ),
                        Listener(
                          child: IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () {
                              print('[*]');
                            },
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
                      ],
                    ),
                    ListTile(
                      title: Text('Confirm height ?'),
                      trailing: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            widget.deviceObject.progressDegrees = 0;
                            widget.deviceObject.socket.write('true');
                            widget.deviceObject.time = Duration(minutes: 1);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(widget.deviceObject)),
                            );
                          }),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
