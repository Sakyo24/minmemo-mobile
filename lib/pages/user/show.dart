import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../utils/app_colors.dart';
import 'edit.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // タイトル
                    const Text('名前'),
                    const SizedBox(height: 10),
                    Text(
                      _name ?? '',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    const SizedBox(height: 40),
                    // タイトル
                    const Text('メールアドレス'),
                    const SizedBox(height: 10),
                    Text(
                      _email ?? '',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserEditPage(
                                name: _name ?? '',
                                email: _email ?? '',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "編集",
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
