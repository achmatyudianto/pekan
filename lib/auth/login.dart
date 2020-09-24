import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pekan/auth/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/api.dart';
import '../pekan/home.dart';
import 'widget/bezierContainer.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    var data = {
      'email': emailController.text,
      'password': passwordController.text
    };

    var res = await CallApi().postData(data, 'auth/login');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      print(body);
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', body['meta']['token']);
      localStorage.setString('user', json.encode(body['data']));

      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      print('Email / Password Salah');
      dialogError(context);
    }

    setState(() {
      isLoading = false;
    });
  }

  dialogError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                padding: EdgeInsets.all(16.0),
                shrinkWrap: true,
                children: <Widget>[
                  Icon(
                    Icons.block,
                    size: 55.0,
                    color: Color(0xfff79c4f),
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      "Email / Kata Sandi Salah",
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xfff79c4f),
                            fontSize: 15.0),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
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
        _login();
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
          isLoading ? 'Memuat...' : 'Masuk',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RegisterPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Belum Punya Akun ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Daftar',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 14,
                  fontWeight: FontWeight.w800),
            ),
          ],
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
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.centerRight,
                      child: Text('Lupa kata sandi ?',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(height: height * .13),
                    _createAccountLabel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
