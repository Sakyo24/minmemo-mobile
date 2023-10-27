import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../model/group.dart';
import '../../model/todo.dart';
import '../index.dart';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';

class TodosCreateEditPage extends StatefulWidget {
  final Todo? currentTodo;
  final Group? currentGroup;
  const TodosCreateEditPage({super.key, this.currentTodo, this.currentGroup});

  @override
  State<TodosCreateEditPage> createState() => _TodosCreateEditPageState();
}

class _TodosCreateEditPageState extends State<TodosCreateEditPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  bool _isLoading = false;
  String? group_id;

  // 登録・更新処理
  Future<void> createUpdateTodo({int? id}) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String?> data = {
      'title': titleController.text,
      'detail': detailController.text,
      'group_id': group_id,
    };

    Response? response;
    try {
      if (id == null) {
        response = await Network().postData(data, '/api/todos');
      } else {
        response = await Network().putData(data, '/api/todos/$id');
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
      MaterialPageRoute(
          builder: ((context) => group_id != null
              ? const IndexPage(toPageIndex: 1)
              : const IndexPage(toPageIndex: 0))),
    ).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentTodo != null) {
      titleController.text = widget.currentTodo!.title;
      detailController.text = widget.currentTodo!.detail;
    }
    if (widget.currentGroup != null) {
      group_id = widget.currentGroup!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(widget.currentTodo == null ? 'メモ新規登録' : 'メモ編集'),
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
                      // タイトル
                      const Text('タイトル'),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: 'タイトルを入力してください',
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // メモ
                      const Text('メモ'),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: detailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: 'メモを入力してください',
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 25,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 登録・更新ボタン
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (widget.currentTodo == null) {
                              await createUpdateTodo();
                            } else {
                              await createUpdateTodo(
                                  id: widget.currentTodo!.id);
                            }
                          },
                          child: Text(
                            widget.currentTodo == null ? '登録' : '更新',
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
