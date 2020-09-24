import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'constants.dart';
import '../auth/login.dart';
import '../auth/widget/bezierContainer.dart';
import '../model/api.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File _imageFile;
  final picker = ImagePicker();
  bool isLoading = false;
  String email = "", avatar = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();

  Future _chooseGallery() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 1920.0,
      maxWidth: 1080.0,
    );

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future<String> checkImageProfile() async {
    var res = await CallApi().getData('profile');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      return body['data']['avatar'];
    } else {
      return "https://pekan.mbiodo.com/images/no-user-image.png";
    }
  }

  Future<void> _readData() async {
    var res = await CallApi().getData('profile');
    var body = json.decode(res.body);
    if (body['data'] != null) {
      print("Profile : $body");
      setState(() {
        email = body['data']['email'];
        avatar = body['data']['avatar'];
        nameController.text = body['data']['name'];
        noTelpController.text = body['data']['mobile_phone'];
      });
    }
  }

  Future<void> _updateData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var request = await CallApi().postDataFile('profile');
      request.headers.addAll(await CallApi().setHeader());
      request.fields['name'] = nameController.text;
      request.fields['mobile_phone'] = noTelpController.text;
      if (_imageFile != null) {
        var stream =
            http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        var length = await _imageFile.length();
        request.files.add(http.MultipartFile('image', stream, length,
            filename: path.basename(_imageFile.path)));
      }
      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode > 2) {
        //response status 201 (created)
        var body = json.decode(await response.stream.bytesToString());
        var errorMessage = "";
        print("Profile : $body");
        if (body['data'] != null) {
          _readData();
          errorMessage = "Profile telah disimpan";
        } else {
          errorMessage = body['errors']['name'][0];
        }
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
      } else {
        print('Gagal Disimpan !');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error : $e');
    }
  }

  Future<void> _logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('token');
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.reset_password) {
      print('Wroking');
    } else if (choice == Constants.logout) {
      _logout();
    }
  }

  Widget _settingsButton() {
    return PopupMenuButton<String>(
      onSelected: choiceAction,
      icon: Icon(
        Icons.settings,
        color: Colors.white,
      ),
      itemBuilder: (BuildContext context) {
        return Constants.choices.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(
              choice,
              style: TextStyle(fontSize: 14),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _imageProfile() {
    return Container(
      height: 113.0,
      child: InkWell(
        onTap: _chooseGallery,
        child: FutureBuilder(
          future: checkImageProfile(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              if (_imageFile == null) {
                return CircleAvatar(
                  radius: 58.0,
                  backgroundImage: NetworkImage(snapshot.data),
                  backgroundColor: Colors.transparent,
                );
              } else {
                return CircleAvatar(
                  radius: 58.0,
                  backgroundImage: FileImage(_imageFile),
                  backgroundColor: Colors.transparent,
                );
              }
            } else {
              return Text('No Image');
            }
          },
        ),
      ),
    );
  }

  Widget _textFieldWidget() {
    return Column(
      children: <Widget>[
        TextField(
          controller: nameController,
          keyboardType: TextInputType.name,
          autofocus: false,
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(13.0),
            labelText: "Nama",
            labelStyle: TextStyle(fontSize: 13.0),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(15.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
        SizedBox(height: 13.0),
        TextField(
          controller: noTelpController,
          keyboardType: TextInputType.phone,
          autofocus: false,
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(13.0),
            labelText: "Nomor Telepon",
            labelStyle: TextStyle(fontSize: 13.0),
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
        _updateData();
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
          isLoading ? 'Memuat...' : 'Simpan',
          style: TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void initState() {
    _readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer()),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              height: height,
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .22),
                    _imageProfile(),
                    SizedBox(height: 13.0),
                    Text(
                      email,
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 40),
                    _textFieldWidget(),
                    SizedBox(height: 20),
                    _submitButton(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, right: 10, child: _settingsButton()),
          ],
        ),
      ),
    );
  }
}
