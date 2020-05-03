import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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

class BlueToothScreen extends StatefulWidget {
  @override
  _BlueToothScreenState createState() => _BlueToothScreenState();
}

class _BlueToothScreenState extends State<BlueToothScreen> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;
  BluetoothDevice device;
  List<BluetoothDevice> devices;
  bool isConnected = false;

  @override
  void initState() {
    getPairedDevices();
    super.initState();
  }

  getPairedDevices() async {
    List<BluetoothDevice> devicesList = [];

    try {
      devicesList = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      devices = devicesList;
    });
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
                onTap: getPairedDevices,
                leading: Icon(Icons.refresh),
                title: Text('Refresh List of Devices'),
              ),
              ListTile(
                onTap: () {
                  showDeviceList(context);
                },
                leading: Icon(Icons.developer_mode),
                subtitle:
                    Text('Selected : ${device == null ? 'None' : device.name}'),
                title: Text('Select a device'),
              ),
              ListTile(
                onTap: () {
                  showDeviceList(context);
                },
                leading: Icon(Icons.bluetooth),
                //subtitle: Text('Connection Status : '),
                title: Text('Connect'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDeviceList(context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Select a Device',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                devices.length,
                (index) {
                  return SimpleDialogOption(
                    child: ListTile(
                        leading: Icon(
                          Icons.bluetooth,
                        ),
                        title: Text(devices[index].name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(devices[index].address,
                            style: TextStyle(
                              color: Colors.black,
                            ))),
                    onPressed: () {
                      setState(() {
                        device = devices[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void connect() async {
    if (!isConnected) {
      await BluetoothConnection.toAddress(device.address).then((_connection) {
        print('Connected to ${device.name}');
        connection = _connection;
        setState(() {
          isConnected = true;
        });
      });
    }
  }
}
