import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import './pages/index.dart';
import './pages/top.dart';
import './utils/app_colors.dart';
import './utils/network.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  bool _isLoading = true;
  bool _isAuth = false;

  Future<void> getLoginUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? localToken = localStorage.getString('token');

    if (localToken == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    Response? response;
    try {
      response = await Network().getData('/api/login-user');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (response == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("エラーが発生しました。")));
      }
      return;
    }

    // エラーの場合
    if (response.statusCode != 200) {
      if (mounted) {
        var body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            (response.statusCode >= 500 && response.statusCode < 600)
                ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
                : SnackBar(content: Text(body['message'])));
      }
      return;
    }

    if (!mounted) return;
    var jsonResponse = jsonDecode(response.body);
    var localUser = jsonDecode(localStorage.getString('user')!);
    if (jsonResponse['user']['id'] == localUser['id']) {
      setState(() {
        _isAuth = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLoginUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'みんメモ',
      theme: ThemeData(
        primarySwatch: primarySwatchColor,
        primaryColor: AppColors.primaryColor,
        canvasColor: AppColors.whiteColor,
      ),
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAuth
              ? const IndexPage()
              : const TopPage(),
    );
  }
}
