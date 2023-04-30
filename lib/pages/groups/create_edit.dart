import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'index.dart';
import '../../utils/network.dart';

class GroupsCreateEditPage extends StatefulWidget {
  const GroupsCreateEditPage({super.key});

  @override
  State<GroupsCreateEditPage> createState() => _GroupsCreateEditPageState();
}

class _GroupsCreateEditPageState extends State<GroupsCreateEditPage> {
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  // 登録処理
  Future<void> createGroup() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'name': nameController.text,
    };

    Response? response;
    try {
      response = await Network().postData(data, '/api/groups');
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
    if (response.statusCode != 201) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ新規登録'),
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
                      // グループ名
                      const Text('グループ名'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 登録ボタン
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            await createGroup();
                          },
                          child: const Text('登録'),
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
