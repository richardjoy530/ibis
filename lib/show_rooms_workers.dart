import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'front_page.dart';
import 'data.dart';

class ShowRoomsStaffs extends StatefulWidget {
  @override
  _ShowRoomsStaffsState createState() => _ShowRoomsStaffsState();
}

class _ShowRoomsStaffsState extends State<ShowRoomsStaffs> {
  @override
  void initState() {
    super.initState();
    WiFiForIoTPlugin.getBSSID().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xff02457a),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Rooms and Staff details',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xff02457a),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blue),
                //     borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Rooms',
                        style:
                            TextStyle(fontSize: 20, color: Color(0xff02457a)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  color: Color(0xffa9d5ea),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: ListTile(
                                leading: Icon(Icons.crop_portrait,
                                    color: Color(0xff02457a)),
                                title: Text('${rooms[index]}',
                                    style: TextStyle(color: Color(0xff02457a))),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Color(0xff02457a)),
                                  onPressed: () {
                                    setState(() {
                                      databaseHelper.deleteRoom(rooms[index]);
                                      rooms.removeAt(index);
                                      if (rooms.isEmpty) {
                                        room = "Room";
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 0,
                thickness: 2,
                color: Color(0xffa9d5ea),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blue),
                //     borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text('Staffs',
                          style: TextStyle(
                              fontSize: 20, color: Color(0xff02457a))),
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: ListView.builder(
                        itemCount: workers.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                color: Color(0xffa9d5ea),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            child: ListTile(
                              leading:
                                  Icon(Icons.person, color: Color(0xff02457a)),
                              title: Text(
                                '${workers[index]}',
                                style: TextStyle(color: Color(0xff02457a)),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    color: Color(0xff02457a)),
                                onPressed: () {
                                  setState(() {
                                    databaseHelper.deleteWorker(workers[index]);
                                    workers.removeAt(index);
                                    if (workers.isEmpty) {
                                        worker = "Room";
                                      }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton.extended(
                backgroundColor: Color(0xff02457a),
                heroTag: 'hero1',
                label: Text(
                  'Staff',
                  style: TextStyle(fontSize: 20, color: Color(0xffffffff)),
                ),
                icon: Icon(Icons.add, color: Color(0xffffffff)),
                onPressed: () {
                  FrontPageState().addWorker(context);
                },
              ),
              FloatingActionButton.extended(
                backgroundColor: Color(0xff02457a),
                heroTag: 'hero2',
                label: Text('Room',
                    style: TextStyle(fontSize: 20, color: Color(0xffffffff))),
                icon: Icon(Icons.add, color: Color(0xffffffff)),
                onPressed: () {
                  FrontPageState().addRooms(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
