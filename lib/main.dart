import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool power = false;
  double buttonRadius = 100;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'BalooTamma2',
      ),
      home: Scaffold(
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
                    leading: Icon(Icons.bluetooth_connected,
                        color: Color(0xff3d84a7)),
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
                    child: Stack(
                      children: <Widget>[
                        Visibility(
                          visible: !power,
                          child: ClayContainer(
                            spread: 5,
                            surfaceColor: Color(0xFF4dc9cf),
                            color: Color(0xffb9dfe6),
                            borderRadius: 50,
                            curveType: CurveType.convex,
                            height: 100,
                            width: 100,
                            child: Container(
                              child: IconButton(
                                  icon: Icon(
                                    Icons.power_settings_new,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      power = !power;
                                      print('Pressed Power');
                                    });
                                  }),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: power,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                AnimatedContainer(
                                  height: buttonRadius,
                                  width: buttonRadius,
                                  child: ClayContainer(
                                    spread: 5,
                                    surfaceColor: Color(0xFFffffff),
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: 50,
                                    curveType: CurveType.convex,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.pause,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            power = !power;
                                            print('Pressed Pause');
                                          });
                                        }),
                                  ),
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.bounceOut,
                                ),
                                ClayContainer(
                                  spread: 5,
                                  surfaceColor: Color(0xFFffffff),
                                  color: Color(0xFFF2F2F2),
                                  borderRadius: 50,
                                  curveType: CurveType.convex,
                                  height: buttonRadius,
                                  width: buttonRadius,
                                  child: Container(
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.stop,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            power = !power;
                                            print('Pressed Power');
                                          });
                                        }),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
