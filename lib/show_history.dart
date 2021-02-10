import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data.dart';

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
                        style: TextStyle(
                            color: Color(0xff02457a),
                            fontSize: 40,
                            fontWeight: FontWeight.w900),
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
                        return ListTile(
                          onLongPress: () {},
                          leading: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              //color: myTheme.mainAccentColor,
                              child: Text((index + 1).toString(),
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white))),
                          onTap: () {},
                          title: Text(
                            historyList[(historyList.length - 1) - index]
                                .roomName,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Staff: ${historyList[(historyList.length - 1) - index].workerName}',
                                style: TextStyle(
                                    color: Color(0xff02457a), fontSize: 15),
                              ),
                              Text(
                                historyList[(historyList.length - 1) - index]
                                    .state,
                                style: TextStyle(
                                    color: Color(0xff02457a), fontSize: 15),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${historyList[(historyList.length - 1) - index].time.day}- ${mapMonth(historyList[(historyList.length - 1) - index].time.month)} - ${historyList[(historyList.length - 1) - index].time.hour > 12 ? historyList[(historyList.length - 1) - index].time.hour - 12 : historyList[(historyList.length - 1) - index].time.hour}:${NumberFormat("00", "en_US").format(historyList[(historyList.length - 1) - index].time.minute)} ${historyList[(historyList.length - 1) - index].time.hour > 12 ? 'PM' : 'AM'}',
                                style: TextStyle(
                                    color: Color(0xff02457a),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
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

String mapMonth(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
  }
  return '';
}
