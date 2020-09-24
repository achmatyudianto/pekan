import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// New Class call API
class CallApi {
  final String _url = 'https://pekan.mbiodo.com/api/';

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString('token');
    //print(token);
    return 'Bearer $token';
  }

  setHeader() async {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': await _getToken(),
    };
    return header;
  }

  // POST method
  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
      fullUrl,
      body: jsonEncode(data),
      headers: await setHeader(),
    );
  }

  // POST (file) method
  postDataFile(apiUrl) async {
    var uri = Uri.parse(_url + apiUrl);
    return http.MultipartRequest('POST', uri);
  }

  // PUT method
  putData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.put(
      fullUrl,
      body: jsonEncode(data),
      headers: await setHeader(),
    );
  }

  // DELETE method
  deleteData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.delete(
      fullUrl,
      headers: await setHeader(),
    );
  }

  // GET method
  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.get(
      fullUrl,
      headers: await setHeader(),
    );
  }
}
