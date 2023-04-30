import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../components/bottom_menu.dart';
import '../../config/constants.dart';
import '../../utils/network.dart';
import '../top.dart';

class UserShowPage extends StatefulWidget {
  const UserShowPage({super.key});

  @override
  State<UserShowPage> createState() => _UserShowPageState();
}

class _UserShowPageState extends State<UserShowPage> {
  String? _name;
  String? _email;
  bool _isLoading = false;

  // ユーザーの取得
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);

    if (user != null) {
      setState(() {
        _name = user['name'];
        _email = user['email'];
      });
    }
  }

  // ログアウト処理
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {'email': _email!};

    Response? res;
    try {
      res = await Network().postData(data, '/api/logout');
    } catch (e) {
      debugPrint(e.toString());
    }

    if (res == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("エラーが発生しました。"),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // エラーの場合
    if (res.statusCode != 204) {
      var body = json.decode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          (res.statusCode >= 500 && res.statusCode < 600)
              ? const SnackBar(
                  content: Text("サーバーエラーが発生しました。"),
                )
              : SnackBar(
                  content: Text(body['message']),
                ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 正常の場合
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    localStorage.remove('token');

    if (!mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const TopPage()));
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("マイページ"),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _logout();
                    },
                    child: const Text("ログアウト"),
                  )
                ],
              ),

            ),
      bottomNavigationBar: const BottomMenu(currentPageIndex: PageIndex.user),
    );
  }
}
