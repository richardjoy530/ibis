import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibis/main.dart';
import 'package:intl/intl.dart';

class ShowHistory extends StatefulWidget {
  @override
  _ShowHistoryState createState() => _ShowHistoryState();
}

class _ShowHistoryState extends State<ShowHistory> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
              //height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Device History',
                        style: TextStyle(color: Color(0xff02457a),
                            fontSize: 40, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        return Container(
                           margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color(0xffa9d5ea),
                                    borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            onLongPress: () {},
                            leading: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                //color: myTheme.mainAccentColor,
                                child: Text((index + 1).toString(),
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.blue))),
                            onTap: () {},
                            title: Text(
                              historyList[index].workerName,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              historyList[index].state,
                              style:
                                  TextStyle(color: Color(0xff02457a), fontSize: 15),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${historyList[index].time.hour > 12 ? historyList[index].time.hour - 12 : historyList[index].time.hour}:${NumberFormat("00", "en_US").format(historyList[index].time.minute)} ${historyList[index].time.hour > 12 ? 'PM' : 'AM'}',
                                  style: TextStyle(
                                      color: Color(0xff02457a),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: historyList.length,

                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
