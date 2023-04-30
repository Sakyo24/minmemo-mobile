import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Network {
  final String _url = dotenv.get('APP_URL');
  String? token;

  // SharedPreferencesからトークンを取得
  _setToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? localToken = localStorage.getString('token');

    if (localToken != null) {
      token = localToken.replaceAll('"', '');
    }
  }

  // ヘッダー情報をセット
  _getHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  // GET
  Future<Response> getData(String apiUrl) async {
    await _setToken();
    Uri fullUrl = Uri.parse(_url + apiUrl);
    Response res = await get(fullUrl, headers: _getHeaders());    
    return res;
  }

  // POST
  Future<Response> postData(data, String apiUrl) async {
    await _setToken();
    Uri fullUrl = Uri.parse(_url + apiUrl);
    return await post(fullUrl, body: jsonEncode(data), headers: _getHeaders());
  }

  // PUT
  Future<Response> putData(data, String apiUrl) async {
    await _setToken();
    Uri fullUrl = Uri.parse(_url + apiUrl);
    return await put(fullUrl, body: jsonEncode(data), headers: _getHeaders());
  }

  // DELETE
  Future<Response> deleteData( String apiUrl) async {
    await _setToken();
    Uri fullUrl = Uri.parse(_url + apiUrl);
    return await delete(fullUrl, headers: _getHeaders());
  }
}
