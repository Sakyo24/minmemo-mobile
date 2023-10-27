import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../model/group.dart';
import '../index.dart';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';

class GroupsCreateEditPage extends StatefulWidget {
  final Group? currentGroup;
  const GroupsCreateEditPage({super.key, this.currentGroup});

  @override
  State<GroupsCreateEditPage> createState() => _GroupsCreateEditPageState();
}

class _GroupsCreateEditPageState extends State<GroupsCreateEditPage> {
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  // 登録・更新処理
  Future<void> createUpdateGroup({String? id}) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'name': nameController.text,
    };

    Response? response;
    try {
      if (id == null) {
        response = await Network().postData(data, '/api/groups');
      } else {
        response = await Network().putData(data, '/api/groups/$id');
      }
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
    if (response.statusCode != 201 && response.statusCode != 200) {
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
      MaterialPageRoute(builder: ((context) => const IndexPage(toPageIndex: 1))),
    ).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentGroup != null) {
      nameController.text = widget.currentGroup!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(widget.currentGroup == null ? 'グループ新規登録' : 'グループ編集'),
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 登録・更新ボタン
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (widget.currentGroup == null) {
                              await createUpdateGroup();
                            } else {
                              await createUpdateGroup(
                                  id: widget.currentGroup!.id);
                            }
                          },
                          child: Text(
                            widget.currentGroup == null ? '登録' : '更新',
                            style: TextStyle(color: AppColors.whiteColor),
                          ),
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
