import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool power = false;
  double buttonRadius = 100;
  Animation animation;
  Animation colorAnimation;
  AnimationController animationController;
  bool mReverse;
  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
    //colorAnimation = ColorTween();
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
                    icon: Icon(Icons.bluetooth_connected),
                    color: Color(0xff3d84a7),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BlueToothScreen()),
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
                  child: ClayContainer(
                    spread: 5,
                    surfaceColor: Color(0xFF4dc9cf),
                    color: Color(0xffb9dfe6),
                    borderRadius: 50,
                    curveType: CurveType.convex,
                    height: 100,
                    width: 100,
                    child: AnimatedBuilder(
//                        child: Container(
//                          child: IconButton(
//                              icon: AnimatedIcon(
//                                icon: AnimatedIcons.play_pause,
//                                progress: animation,
//                              ),
//                              onPressed: () {
//                                if (mReverse == true) {
//                                  animationController.forward();
//                                  mReverse = false;
//                                } else {
//                                  animationController.reverse();
//                                  mReverse = true;
//                                }
//                              }),
//                        ),
                      animation: animation,
                      builder: (BuildContext context, Widget child) {
                        return Container(
                          child: IconButton(
                              icon: AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: animation,
                              ),
                              onPressed: () {
                                if (mReverse == true) {
                                  animationController.forward();
                                  mReverse = false;
                                } else {
                                  animationController.reverse();
                                  mReverse = true;
                                }
                              }),
                        );
                      },
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

class BlueToothScreen extends StatefulWidget {
  @override
  _BlueToothScreenState createState() => _BlueToothScreenState();
}

class _BlueToothScreenState extends State<BlueToothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice bluetoothDevice;
  void test() {
    flutterBlue.startScan(
        timeout: Duration(seconds: 4), scanMode: ScanMode.balanced);
    print('In function');
// Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print(
            '${r.device.name} found! rssi: ${r.rssi} id: ${r.device.id.toString()} id.id: ${r.device.id.id}');
        bluetoothDevice = r.device;
      }
    });

// Stop scanning
    flutterBlue.stopScan();
  }

  void connect() {
    bluetoothDevice.connect();
    print('Connection initiated');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(icon: Icon(Icons.bluetooth), onPressed: test),
                IconButton(icon: Icon(Icons.touch_app), onPressed: connect)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
