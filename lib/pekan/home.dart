import 'package:flutter/material.dart';
import 'analysis.dart';
import 'income.dart';
import 'spending.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    controller = new TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: 58,
        child: Material(
          color: Colors.white,
          child: TabBar(
            labelStyle: TextStyle(fontSize: 11),
            controller: controller,
            labelColor: Colors.black,
            indicatorColor: Colors.blueGrey,
            tabs: <Widget>[
              new Tab(
                icon: Icon(
                  Icons.trending_down,
                  size: 20.0,
                ),
                text: 'Pengeluaran',
              ),
              new Tab(
                icon: Icon(
                  Icons.trending_up,
                  size: 20.0,
                ),
                text: 'Pemasukan',
              ),
              new Tab(
                icon: Icon(
                  Icons.insert_chart,
                  size: 20.0,
                ),
                text: 'Analisa',
              ),
              new Tab(
                icon: Icon(
                  Icons.person,
                  size: 20.0,
                ),
                text: 'Akun',
              )
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: <Widget>[
          SpendingPage(),
          IncomePage(),
          AnalysisPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
