import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_friendly_name/flutter_device_friendly_name.dart';
import 'package:ibis/height_page.dart';
import 'package:ibis/main.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:sqflite/sqflite.dart';

import 'data.dart';

List<DeviceObject> deviceObjectList = [];
List<String> ipList = [];
List<Socket> sockets = [];
ServerSocket serverSocket;
bool serverOnline = false;
bool isEnabled = false;
bool isConnected = false;
String serverIp;
int screenLengthConstant=0;
int nameNumber=1;
Database database;

final List<bool> isSelected = [false];
Future<void> wifi() async {
  WiFiForIoTPlugin.isEnabled().then((val) {
    if (val != null) {
      isEnabled = val;
      print('Wifi Status:$isEnabled');
      if (isEnabled == false) {
        WiFiForIoTPlugin.setEnabled(true);
        print('Wifi turned on');
      }
    }
  });
  WiFiForIoTPlugin.isConnected().then((val) {
    if (val != null) {
      isConnected = val;
      print('Connected:$isConnected');
    }
  });
  
  serverIp = await WiFiForIoTPlugin.getIP();
}

class FrontPage extends StatefulWidget {
  @override
  FrontPageState createState() => FrontPageState();
}

class FrontPageState extends State<FrontPage> with TickerProviderStateMixin {
  Timer timer;
  TextEditingController nameController;
  String _friendlyName = 'Loading...';

  @override
  void initState() {
    FlutterDeviceFriendlyName.friendlyName.then((x) {
      setState(() {
        _friendlyName = x;
      });
    });
    connect();
    nameController = TextEditingController();
    wifi();
    getIpList();
    timer = Timer.periodic(Duration(milliseconds: 100), (callback) {
      setState(() {
        for (var i = 0; i < deviceObjectList.length; i++) {
          if (deviceObjectList[i].motionDetected == true &&
              deviceObjectList[i].power == true) {
            deviceObjectList[i].power = false;
            deviceObjectList[i].pause = false;

            prefs.setInt('${deviceObjectList[i].ip}totalDuration',
                deviceObjectList[i].totalDuration.inSeconds);
            prefs.setInt('${deviceObjectList[i].ip}secondDuration',
                deviceObjectList[i].secondDuration.inSeconds);
            deviceObjectList[i].flare = 'off';
            deviceObjectList[i].timer.cancel();
            deviceObjectList[i].elapsedTime = 0;
            deviceObjectList[i].time = Duration(minutes: 0);
            deviceObjectList[i].mainTime = Duration(minutes: 0);
            deviceObjectList[i].progressDegrees = 0;
          }

          if (deviceObjectList[i].power == true &&
              deviceObjectList[i].pause == false) {
            deviceObjectList[i].linearProgressBarValue =
                (1 / deviceObjectList[i].time.inSeconds) *
                    deviceObjectList[i].elapsedTime;
            if (deviceObjectList[i].elapsedTime >
                deviceObjectList[i].time.inSeconds) {
              prefs.setInt('${deviceObjectList[i].ip}totalDuration',
                  deviceObjectList[i].totalDuration.inSeconds);
              prefs.setInt('${deviceObjectList[i].ip}secondDuration',
                  deviceObjectList[i].secondDuration.inSeconds);
              deviceObjectList[i].power = false;
              deviceObjectList[i].pause = false;
              deviceObjectList[i].flare = 'off';
              deviceObjectList[i].timer.cancel();
              deviceObjectList[i].elapsedTime = 0;
              deviceObjectList[i].time = Duration(minutes: 0);
              deviceObjectList[i].mainTime = Duration(minutes: 0);
              deviceObjectList[i].progressDegrees = 0;
            }
          }
        }
      });
    });
    databaseConnect();
    super.initState();
  }

  Future<void> databaseConnect() async
  {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath+'/ibis.db';
    print(path);
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute('CREATE TABLE Rooms (id INTEGER NOT NULL , roomName TEXT)');
        },singleInstance: true);
    print('database:$database');
    //await database.close();
  }

  Future<void> databaseInsertion() async
  {
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Rooms(id, roomName) VALUES(1,"room1")');
      print('inserted:$id1');
      List list = await database.rawQuery('SELECT * FROM Rooms');
      print('list:$list');

    });
  }

  @override
  void dispose() {
    nameController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffffffff), Color(0xffffffff)]),
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 30,
                      width: 30,
                      child: FlareActor(
                        'assets/status.flr',
                        animation: 'Connected',
                      ),
                    ),
                  ),
                  Expanded(child: Image.asset('images/razecov.jfif')),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      color: Color(0xff019ae6),
                      onPressed: () {
                        onMenuPressed(context);
                      },
                    ),
                  )
                ],
              ),
              serverOnline == true
                  ? deviceObjectList.length == 0
                      ? Center(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xffd6e7ee),
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              leading: Icon(Icons.wifi_tethering),
                              title: Text('Please connect your device!'),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                              itemCount: deviceObjectList.length,
                              itemBuilder: (context, index) {
                                if(deviceObjectList[index].name=='Device'){
                                deviceObjectList[index].name='';
                                nameIt(context,deviceObjectList[index]);
                                }
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Color(0xffa9d5ea),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ListTile(
                                    leading: Icon(
                                      deviceObjectList[index].offline == true
                                          ? Icons.signal_wifi_off
                                          : Icons.network_wifi,
                                      color: Color(0xff019ae6),
                                    ),
                                    trailing: deviceObjectList[index]
                                                .motionDetected ==
                                            true
                                        ? Icon(
                                            Icons.warning,
                                            color: Color(0xff019ae6),
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.more_vert,
                                                color: Color(0xff019ae6)),
                                            onPressed: () {
                                              info(context,
                                                  deviceObjectList[index]);
                                            },
                                          ),
                                    title:
                                        Text('${deviceObjectList[index].name}'),
                                    subtitle: deviceObjectList[index].power ==
                                            false
                                        ? Text(deviceObjectList[index]
                                                    .offline ==
                                                true
                                            ? 'Device not Connected'
                                            : deviceObjectList[index]
                                                        .motionDetected ==
                                                    false
                                                ? 'Device Connected'
                                                : 'Motion Detected : Tap to start again')
                                        : LinearPercentIndicator(
                                            lineHeight: 5.0,
                                            animation: false,
                                            animationDuration: 0,
                                            backgroundColor: Color(0xffd6e7ee),
                                            percent: deviceObjectList[index]
                                                .linearProgressBarValue,
                                            linearStrokeCap:
                                                LinearStrokeCap.roundAll,
                                            progressColor: Color(0xff019ae6),
                                          ),
                                    onTap: () {
                                      if (deviceObjectList[index].offline ==
                                          false) {
                                        if (deviceObjectList[index].power ==
                                            true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                    deviceObjectList[index])),
                                          );
                                        } else {
                                          deviceObjectList[index]
                                              .motionDetected = false;
                                          deviceObjectList[index].time =
                                              Duration(minutes: 0);
                                          deviceObjectList[index]
                                              .progressDegrees = 0;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HeightPage(deviceObjectList[
                                                        index])),
                                          );
                                        }
                                      }
                                    },
                                    onLongPress: () {
                                      setName(context, deviceObjectList[index]);
                                    },
                                  ),
                                );
                              }),
                        )
                  : Align(
                      alignment: Alignment.center,
                      child: AlertDialog(
                        backgroundColor: Color(0xffffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        title: Text(
                          'Server is Offline',
                          style: TextStyle(
                              color: Color(0xff02457a),
                              fontWeight: FontWeight.bold),
                        ),
                        content: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Color(0xff019ae6),
                          ),
                          onPressed: () {
                            connect();
                          },
                        ),
                      ),
                    ),
            ],
          ),
        
      ),
     floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: 'hero1',
              label: Text('Add Worker'),
             // icon: Icon(Icons.add),
              onPressed: ()
              {

              },
            ),
            FloatingActionButton.extended(
              heroTag: 'hero2',
              label: Text('Add Room'),
             // icon: Icon(Icons.home),
              onPressed: ()
              {
                addRooms();
              },
            )
          ],
        )
      )
    );
  }

  void addRooms() async
  {
    showDialog(context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context,setState){
              return SimpleDialog(
                title: Center(child: Text('Add Room',style: TextStyle(fontSize: 25,color: Colors.black),)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                children: <Widget>[

                  SimpleDialogOption(
                      child:Container(
                        height: MediaQuery.of(context).size.height/(7-nameNumber+screenLengthConstant),
                        width: 300,
                        child: ListView.builder(
                          itemCount: nameNumber,
                          itemBuilder: (context,index)
                          {
                            return ListTile(
                                title:TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(fontSize: 20,color: Colors.blue),

                                  ),
                                )
                            );
                          },
                        ),
                      )

                  ),
                  SimpleDialogOption(
                    child: ListTile(
                      leading:Container(
                        decoration: ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.blue
                        ),
                        child:IconButton(
                          icon: Icon(Icons.add),
                          color:Colors.white,
                          onPressed: ()
                          {
                            setState(() {
                              nameNumber+=1;
                              if(nameNumber>4)
                              {
                                screenLengthConstant+=1;
                              }
                            });

                            print(nameNumber);

                          },
                        ),
                      ),
                      trailing:Container(
                        decoration: ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.blue
                        ),
                        child:IconButton(
                          icon: Icon(Icons.check),
                          color:Colors.white,
                          onPressed: ()
                          {
                            databaseInsertion();
                          },
                        ),
                      ),
                    ),
                  )

                ],
              );
            },
          );
        }
    );
  }

  void onMenuPressed(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        builder: (context) {
          return Wrap(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(200.0, 10, 200, 10),
                  child: Divider(thickness: 2, color: Colors.grey[500])),
              ListTile(
                leading: Icon(
                  Icons.settings_input_composite,
                  color: Color(0xff02457a),
                ),
                title: Text(
                  'Server Ip: $serverIp',
                ),
                subtitle: Text(_friendlyName),
                onTap: () {
                  setState(() {
                    WiFiForIoTPlugin.getIP().then((value) => serverIp = value);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  isEnabled == true
                      ? Icons.signal_wifi_4_bar
                      : Icons.signal_wifi_off,
                  color: Color(0xff02457a),
                ),
                title: Text(
                  isEnabled == true ? 'Tap to disconnect' : 'Tap to connect',
                ),
                onTap: () {
                  setState(() {
                    WiFiForIoTPlugin.setEnabled(!isEnabled);
                    isEnabled = !isEnabled;
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Color(0xff02457a),
                  ),
                  title: Text('About')),
            ],
          );
        });
  }

  Future<void> info(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Total Runtime',
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff02457a),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                    "${deviceObject.totalDuration.inDays} Days, ${deviceObject.totalDuration.inHours.remainder(24)} Hours, ${deviceObject.totalDuration.inMinutes.remainder(60)} Minutes"),
              ),
              Center(
                child: Text(
                  "Health",
                  style: TextStyle(
                      color: Color(0xff02457a),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: LinearPercentIndicator(
                  leading: Text("Upper",
                      style: TextStyle(
                          color: Color(0xff02457a),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  lineHeight: 5.0,
                  trailing: Text(
                      "${(100 - ((deviceObject.secondDuration.inHours / 9000) * 100)).floor()}%"),
                  percent: 1 - deviceObject.secondDuration.inHours / 9000,
                  backgroundColor: Colors.grey[300],
                  progressColor: deviceObject.secondDuration.inHours / 9000 > .5
                      ? deviceObject.secondDuration.inHours / 9000 > .2
                          ? Colors.red
                          : Colors.orange
                      : Colors.green,
                  curve: Curves.bounceInOut,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: LinearPercentIndicator(
                  leading: Text("Lower",
                      style: TextStyle(
                          color: Color(0xff02457a),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  trailing: Text(
                      "${(100 - ((deviceObject.totalDuration.inHours / 9000) * 100)).floor()}%"),
                  lineHeight: 5.0,
                  percent: 1 - (deviceObject.totalDuration.inHours) / 9000,
                  backgroundColor: Colors.grey[300],
                  progressColor: deviceObject.totalDuration.inHours / 9000 > .5
                      ? deviceObject.totalDuration.inHours / 9000 > .8
                          ? Colors.red
                          : Colors.orange
                      : Colors.green,
                ),
              ),
            ],
          );
        });
  }

  Future<void> setName(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Give a name for your device',
              style: TextStyle(
                  color: Color(0xff02457a), fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Enter name'),
                  onSubmitted: (name) {
                    deviceObject.name = nameController.text;
                    prefs.setString('${deviceObject.ip}name', name);
                    nameController.text = '';
                    Navigator.pop(context);
                  },
                ),
              ),
              SimpleDialogOption(
                child: Text('OK'),
                onPressed: () {
                  if (nameController.text != '') {
                    deviceObject.name = nameController.text;
                    prefs.setString(
                        '${deviceObject.ip}name', nameController.text);
                    nameController.text = '';
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> setHeightYN(context, DeviceObject deviceObject) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Color(0xffdec3e4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Do you want height?',
              style: TextStyle(
                  color: Color(0xff83caec), fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Yes'),
                onPressed: () {
                  deviceObject.motionDetected = false;
                  deviceObject.socket.write('2\r');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HeightPage(deviceObject)),
                  );
                },
              ),
              SimpleDialogOption(
                  child: Text('No'),
                  onPressed: () {
                    deviceObject.motionDetected = false;
                    deviceObject.socket.write('-2\r');
                    deviceObject.time = Duration(minutes: 0);
                    deviceObject.progressDegrees = 0;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(deviceObject)),
                    );
                  })
            ],
          );
        });
  }

  Future<void> nameIt(BuildContext context,DeviceObject deviceObject) async{
    Future.delayed(Duration(milliseconds: 300),(){
      setName(context, deviceObject);
    });
  }
}
