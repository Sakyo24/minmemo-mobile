import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';
import '../index.dart';
import 'password_reset.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _email;
  String? _password;

  // ログイン処理
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {'email': _email!, 'password': _password!};

    Response? res;
    try {
      res = await Network().postData(data, '/api/login');
    } catch (e) {
      debugPrint(e.toString());
    }

    if (res == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("エラーが発生しました。")));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var body = json.decode(res.body);

    // エラーの場合
    if (res.statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            (res.statusCode >= 500 && res.statusCode < 600)
                ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
                : SnackBar(content: Text(body['message'])));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 正常の場合
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('token', json.encode(body['token']));
    localStorage.setString('user', json.encode(body['user']));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IndexPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text("ログイン"),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(hintText: "メールアドレス"),
                        validator: (emailValue) {
                          if (emailValue == null || emailValue == "") {
                            return 'メールアドレスは必ず入力してください。';
                          }
                          _email = emailValue;
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(hintText: "パスワード"),
                        obscureText: true,
                        validator: (passwordValue) {
                          if (passwordValue == null || passwordValue == "") {
                            return 'パスワードは必ず入力してください。';
                          }
                          _password = passwordValue;
                          return null;
                        },
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                        onPressed: () {
                          _login();
                        },
                        child: Text(
                          "ログイン",
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PasswordResetPage()),
                          );
                        },
                        child: const Text('パスワードを忘れた場合は、こちら'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
