import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'login.dart';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';

class NotVerifiedPage extends StatefulWidget {
  const NotVerifiedPage({super.key});

  @override
  State<NotVerifiedPage> createState() => _NotVerifiedPageState();
}

class _NotVerifiedPageState extends State<NotVerifiedPage> {
  String? _email;
  bool _isLoading = false;

  // ログインページへ遷移
  Future<void> toLoginPage() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);

    if (user != null) {
      setState(() {
        _email = user['email'];
      });
    }

    Map<String, String> data = {'email': _email ?? ''};

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
    localStorage.remove('user');
    localStorage.remove('token');
    if (!mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text("メールアドレス未認証"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        const Text('メールアドレスが認証されていません。'),
                        const Text('メールアドレス認証後、再度ログインしてください。'),
                        const SizedBox(height: 40),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              await toLoginPage();
                            },
                            child: Text(
                              'ログイン',
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
