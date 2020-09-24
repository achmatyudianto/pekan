import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/api.dart';
import '../pekan/home.dart';
import 'widget/bezierContainer.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    var data = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text
    };

    var res = await CallApi().postData(data, 'auth/register');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      print(body);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', body['meta']['token']);
      localStorage.setString('user', json.encode(body['data']));

      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      print(body);
      var errorMessage = "";
      if (body['errors']['name'] != null) {
        errorMessage = body['errors']['name'][0];
      } else if (body['errors']['email'] != null) {
        errorMessage = body['errors']['email'][0];
      } else if (body['errors']['password'] != null) {
        errorMessage = body['errors']['password'][0];
      } else {
        errorMessage = body['message'];
      }
      print("errorMessage : $errorMessage");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              errorMessage,
              style: TextStyle(fontSize: 14.0),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Kembali',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Pe',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 33,
            fontWeight: FontWeight.w700,
            color: Color(0xfff79c4f),
          ),
          children: [
            TextSpan(
              text: 'Kan',
              style: TextStyle(color: Colors.green, fontSize: 33),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        TextField(
          controller: nameController,
          autofocus: false,
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(14.0),
            labelText: "Nama",
            labelStyle: TextStyle(fontSize: 14.0),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(15.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
        SizedBox(height: 13.0),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(14.0),
            labelText: "Email",
            labelStyle: TextStyle(fontSize: 14.0),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(15.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
        SizedBox(height: 13.0),
        TextField(
          controller: passwordController,
          autofocus: false,
          obscureText: true,
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(14.0),
            labelText: "Kata Sandi",
            labelStyle: TextStyle(fontSize: 14.0),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(15.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        _register();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.blueGrey, Colors.blueGrey.shade900])),
        child: Text(
          isLoading ? 'Memuat...' : 'Daftar',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer()),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .23),
                    _title(),
                    Text(
                      "Pengeluaran, Pemasukan",
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 70),
                    _emailPasswordWidget(),
                    SizedBox(height: 20),
                    _submitButton(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
