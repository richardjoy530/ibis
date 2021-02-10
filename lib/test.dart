import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'front_page.dart';
import 'select_time.dart';

Widget con(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(20.0),
      ),
      color: Color(0xff9ad2ec),
    ),
    child: GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          scrollDirection: Axis.horizontal,
          //-------------
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffbddeee),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                height: 125,
                width: MediaQuery.of(context).size.width / 1.5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    child: BarChart(
                      BarChartData(
                        //alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxYAxis / 60,
                        //groupsSpace: 40,
                        barTouchData: BarTouchData(
                          enabled: false,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.transparent,
                            tooltipPadding: const EdgeInsets.all(0),
                            tooltipBottomMargin: 8,
                            getTooltipItem: (
                              BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex,
                            ) {
                              return BarTooltipItem(
                                rod.y.round().toString(),
                                TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            textStyle: TextStyle(
                                color: const Color(0xff7589a2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            margin: 20,
                            getTitles: (double value) {
                              return barTime[value.toInt()];
                            },
                          ),
                          leftTitles: SideTitles(showTitles: false),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: [
                          BarChartGroupData(x: barYAxis.length, barRods: [
                            BarChartRodData(
                                y: 2, color: Colors.lightBlueAccent),
                          ], showingTooltipIndicators: [
                            0
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffbddeee),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                height: 125,
                width: MediaQuery.of(context).size.width / 1.5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.center,
                    maxY: maxYAxis / 60,
                    groupsSpace: 40,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: const EdgeInsets.all(0),
                        tooltipBottomMargin: 8,
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            rod.y.round().toString(),
                            TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: const Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 20,
                        getTitles: (double value) {
                          return barTime[value.toInt()];
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: barYAxis,
                  )),
                ),
              ),
              SizedBox(
                width: 80,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffbddeee),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                height: 125,
                width: MediaQuery.of(context).size.width / 1.5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.center,
                    maxY: maxYAxis / 60,
                    groupsSpace: 40,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: const EdgeInsets.all(0),
                        tooltipBottomMargin: 8,
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            rod.y.round().toString(),
                            TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: const Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 20,
                        getTitles: (double value) {
                          return barTime[value.toInt()];
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: barYAxis,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        //graph3Days(context, deviceObjectList[0]);
      },
    ),
  );
}
