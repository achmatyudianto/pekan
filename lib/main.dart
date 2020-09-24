import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart';
import 'pekan/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> _function() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Pe',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xfff79c4f),
          ),
          children: [
            TextSpan(
              text: 'Kan',
              style: TextStyle(color: Colors.green, fontSize: 30),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        accentColor: Colors.blueGrey,
      ),
      home: FutureBuilder(
        future: _function(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          //print(snapshot.data);
          if (snapshot.data == true) {
            return HomePage();
          } else if (snapshot.data == false) {
            return LoginPage();
          } else {
            return Scaffold(
              body: Container(child: Center(child: _title())),
            );
          }
        },
      ),
    );
  }
}
