import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../model/group.dart';
import '../../utils/network.dart';
import 'index.dart';

class AddUserPage extends StatefulWidget {
  final Group currentGroup;
  const AddUserPage({super.key, required this.currentGroup});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  TextEditingController emailController = TextEditingController();
  bool _isLoading = false;
  late String group_name;

  // ユーザー追加処理
  Future<void> addUser({required String id}) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String?> data = {
      'email': emailController.text,
    };

    Response? response;
    try {
      response = await Network().postData(data, '/api/groups/$id/add_user');
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

    // エラーの場合
    if (response.statusCode != 200) {
      if (mounted) {
        var body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          (response.statusCode >= 500 && response.statusCode < 600)
              ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
              : SnackBar(content: Text(body['message'])),
        );
      }
      return;
    }

    // 成功の場合
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: ((context) => const GroupsIndexPage())),
    ).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      group_name = widget.currentGroup.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー追加'),
        backgroundColor: const Color.fromARGB(255, 60, 0, 255),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          '$group_nameに追加したいユーザーのメールアドレスを入力してください',
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('メールアドレス'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            await addUser(id: widget.currentGroup.id);
                          },
                          child: const Text('追加'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
