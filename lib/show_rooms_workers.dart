import 'package:flutter/material.dart';

import 'front_page.dart';
import 'data.dart';

class ShowRoomsStaffs extends StatefulWidget {
  @override
  _ShowRoomsStaffsState createState() => _ShowRoomsStaffsState();
}

class _ShowRoomsStaffsState extends State<ShowRoomsStaffs> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Staffs/Workers'),
        ),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                heroTag: 'hero1',
                label: Text('Staff'),
                icon: Icon(Icons.add),
                onPressed: () {
                  FrontPageState().addWorker(context);
                },
              ),
              FloatingActionButton.extended(
                heroTag: 'hero2',
                label: Text('Room'),
                icon: Icon(Icons.add),
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
