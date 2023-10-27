import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../index.dart';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';

class UserEditPage extends StatefulWidget {
  final String name;
  final String email;
  const UserEditPage({super.key, required this.name, required this.email});

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // 更新処理
  Future<void> updateUser() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'name': nameController.text,
      'email': emailController.text,
    };

    Response? response;
    try {
      response = await Network().putData(data, '/api/user/update');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (response == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("エラーが発生しました。")),
        );
      }
      return;
    }

    var body = json.decode(response.body);

    // エラーの場合
    if (response.statusCode != 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          (response.statusCode >= 500 && response.statusCode < 600)
              ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
              : SnackBar(content: Text(body['message'])),
        );
      }
      return;
    }

    // 成功の場合
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('user', json.encode(body['user']));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: ((context) => const IndexPage(toPageIndex: 0))),
    ).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text('ユーザー編集'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // 名前
                      const Text('名前'),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 10),
                              hintText: '名前を入力してください'),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // メールアドレス
                      const Text('メールアドレス'),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 10),
                              hintText: 'メールアドレスを入力してください'),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 更新ボタン
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            await updateUser();
                          },
                          child: Text(
                            '更新',
                            style: TextStyle(color: AppColors.whiteColor),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
