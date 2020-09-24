import 'dart:convert';
import 'package:pekan/model/api.dart';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

import 'constants.dart';

class AnalysisPage extends StatefulWidget {
  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final oCcy = new NumberFormat("#,##0", "en_US");
  List dataJSON;
  double spending = 0.0;
  double income = 0.0;
  String year = DateFormat('yyyy').format(DateTime.now());

  var dataBarChartSpending = [
    Analisys("1", 0, Colors.orange),
    Analisys("2", 0, Colors.orange),
    Analisys("3", 0, Colors.orange),
    Analisys("4", 0, Colors.orange),
    Analisys("5", 0, Colors.orange),
    Analisys("6", 0, Colors.orange),
    Analisys("7", 0, Colors.orange),
    Analisys("8", 0, Colors.orange),
    Analisys("9", 0, Colors.orange),
    Analisys("10", 0, Colors.orange),
    Analisys("11", 0, Colors.orange),
    Analisys("12", 0, Colors.orange),
  ];

  var dataBarChartIncome = [
    Analisys("1", 0, Colors.green),
    Analisys("2", 0, Colors.green),
    Analisys("3", 0, Colors.green),
    Analisys("4", 0, Colors.green),
    Analisys("5", 0, Colors.green),
    Analisys("6", 0, Colors.green),
    Analisys("7", 0, Colors.green),
    Analisys("8", 0, Colors.green),
    Analisys("9", 0, Colors.green),
    Analisys("10", 0, Colors.green),
    Analisys("11", 0, Colors.green),
    Analisys("12", 0, Colors.green),
  ];

  _getData() async {
    var res = await CallApi().getData('analysis?year=${year.toString()}');
    var body = json.decode(res.body);
    print(body);
    if (!mounted) return;
    setState(() {
      dataJSON = body['data'];
      if (dataJSON != null) {
        _insertData();
      }
    });
  }

  _insertData() {
    int b = dataJSON.length;

    if (b == null || b == 0) {
      dataBarChartSpending.clear();
      dataBarChartIncome.clear();
      for (int a = 0; a < 12; a++) {
        dataBarChartSpending.insert(
          a,
          Analisys(
            (a + 1).toString(),
            0,
            Colors.orange,
          ),
        );
        dataBarChartIncome.insert(
          a,
          Analisys(
            (a + 1).toString(),
            0,
            Colors.green,
          ),
        );
      }
      b = 0;
    }

    double spen = 0, inco = 0;
    for (int a = 0; a < dataJSON.length.toInt(); a++) {
      //spending
      if (dataJSON[a]['type'] == "S") {
        dataBarChartSpending.replaceRange(
          dataJSON[a]['month'] - 1,
          dataJSON[a]['month'],
          [
            Analisys(
              dataJSON[a]['month'].toString(),
              dataJSON[a]['amount'] + .0,
              dataJSON[a]['type'] == 'I' ? Colors.green : Colors.deepOrange,
            )
          ],
        );
        spen += dataJSON[a]['amount'];
      } else if (dataJSON[a]['type'] == "I") {
        dataBarChartIncome.replaceRange(
          dataJSON[a]['month'] - 1,
          dataJSON[a]['month'],
          [
            Analisys(
              dataJSON[a]['month'].toString(),
              dataJSON[a]['amount'] + .0,
              dataJSON[a]['type'] == 'I' ? Colors.green : Colors.deepOrange,
            )
          ],
        );
        inco += dataJSON[a]['amount'] + .0;
      }
    }

    setState(() {
      spending = spen;
      income = inco;
    });
  }

  void choiceAction(String choice) {
    print(choice);
    setState(() {
      year = choice;
      _getData();
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var seriesBarChartSpending = [
      charts.Series(
        domainFn: (Analisys spending, _) => spending.month,
        measureFn: (Analisys spending, _) => spending.amount,
        colorFn: (Analisys spending, _) => spending.color,
        id: 'Spending',
        data: dataBarChartSpending,
      )
    ];

    var seriesBarChartIncome = [
      charts.Series(
        domainFn: (Analisys spending, _) => spending.month,
        measureFn: (Analisys spending, _) => spending.amount,
        colorFn: (Analisys spending, _) => spending.color,
        id: 'Income',
        data: dataBarChartIncome,
      )
    ];

    var chartBarSpending = charts.BarChart(
      seriesBarChartSpending,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      animate: true,
    );

    var chartBarIncome = charts.BarChart(
      seriesBarChartIncome,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      animate: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Analisa", style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 0.0),
            child: Text(year),
          ),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            icon: Icon(Icons.arrow_drop_down),
            itemBuilder: (BuildContext context) {
              return ContanstYear.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.red,
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.trending_down, size: 40),
                            title: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              'Rp ' + oCcy.format(spending).toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.green,
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.trending_up, size: 40),
                            title: Text(
                              'Pemasukan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              'Rp ' + oCcy.format(income).toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Pengeluaran",
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  subtitle: Container(
                    height: MediaQuery.of(context).size.height - 375.0,
                    child: chartBarSpending,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Card(
                child: ListTile(
                  title: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Pemasukan",
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  subtitle: Container(
                    height: MediaQuery.of(context).size.height - 375.0,
                    child: chartBarIncome,
                  ),
                ),
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}

class Analisys {
  final String month;
  final double amount;
  final charts.Color color;

  Analisys(this.month, this.amount, Color color)
      : this.color = charts.Color(
          r: color.red,
          g: color.green,
          b: color.blue,
          a: color.alpha,
        );
}
