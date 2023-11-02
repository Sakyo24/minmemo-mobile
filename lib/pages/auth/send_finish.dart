import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import 'login.dart';

class SendFinishPage extends StatefulWidget {
  const SendFinishPage({super.key});

  @override
  State<SendFinishPage> createState() => _SendFinishPageState();
}

class _SendFinishPageState extends State<SendFinishPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text("送信完了"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text('パスワードリセットのメールを送信しました。'),
                  const Text('メールに記載されているリンクにアクセスし、パスワードをリセットしてください。'),
                  const SizedBox(height: 40),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
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
