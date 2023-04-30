import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../../utils/network.dart';
import './login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _name;
  String? _email;
  String? _password;
  String? _password_confirmation;

  // 会員登録処理
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'name': _name!,
      'email': _email!,
      'password': _password!,
      'password_confirmation': _password_confirmation!
    };

    Response? res;
    try {
      res = await Network().postData(data, '/api/register');
    } catch (e) {
      debugPrint(e.toString());
    }

    if (res == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("エラーが発生しました。"))
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // エラーの場合
    if (res.statusCode != 201) {
      if (mounted) {
        var body = json.decode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          (res.statusCode >= 500 && res.statusCode < 600) ? const SnackBar(content: Text("サーバーエラーが発生しました。")) : SnackBar(content: Text(body['message']))
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 会員登録成功の場合
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("会員登録"),
      ),
      body: SafeArea(
        child: _isLoading
        ? const Center(
          child: CircularProgressIndicator()
        )
        : Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "名前"
                ),
                validator: (nameValue) {
                  if (nameValue == null || nameValue == "") {
                    return '名前は必ず入力してください。';
                  }
                  _name = nameValue;
                  return null;
                }
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "メールアドレス"
                ),
                validator: (emailValue) {
                  if (emailValue == null || emailValue == "") {
                    return 'メールアドレスは必ず入力してください。';
                  }
                  _email = emailValue;
                  return null;
                }
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "パスワード"
                ),
                obscureText: true,
                validator: (passwordValue) {
                  if (passwordValue == null || passwordValue == "") {
                    return 'パスワードは必ず入力してください。';
                  }
                  _password = passwordValue;
                  return null;
                }
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "パスワード(確認)"
                ),
                obscureText: true,
                validator: (passwordConfirmationValue) {
                  if (passwordConfirmationValue == null || passwordConfirmationValue == "") {
                    return 'パスワード(確認)は必ず入力してください。';
                  }
                  _password_confirmation = passwordConfirmationValue;
                  return null;
                }
              ),
              const SizedBox(
                height: 16
              ),
              ElevatedButton(
                onPressed: () {
                  _register();
                },
                child: const Text("会員登録")
              )
            ]
          )
        )
      )
    );
  }
}
