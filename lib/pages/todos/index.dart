import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../components/bottom_menu.dart';
import '../../config/constants.dart';
import '../../model/todo.dart';
import 'show.dart';
import 'create_edit.dart';
import '../../utils/network.dart';

class TodosIndexPage extends StatefulWidget {
  const TodosIndexPage({super.key});

  @override
  State<TodosIndexPage> createState() => _TodosIndexPageState();
}

class _TodosIndexPageState extends State<TodosIndexPage> {
  final int _currentPage = 0;
  bool _isLoading = false;

  // Todoリスト取得処理
  List items = [];
  Future<void> getTodos() async {
    setState(() {
      _isLoading = true;
    });
    
    Response? response;
    try {
      response = await Network().getData('/api/todos');
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        items = jsonResponse['todos'];
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 削除処理
  Future<void> deleteTodo(id) async {
    Response? response;
    try {
      response = await Network().deleteData('/api/todos/$id');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {});
    }

    if (response == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("エラーが発生しました。"))
        );
      }
      return;
    }

    // エラーの場合
    if (response.statusCode != 204) {
      if (mounted) {
        var body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          (response.statusCode >= 500 && response.statusCode < 600) ? const SnackBar(content: Text("サーバーエラーが発生しました。")) : SnackBar(content: Text(body['message']))
        );
      }
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ一覧'),
        backgroundColor: const Color.fromARGB(255, 60, 0, 255),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
      ? const Center(
        child: CircularProgressIndicator()
      )
      : ListView.builder(
        padding: const EdgeInsets.only(bottom: 70),
        itemCount: items.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> data = items[index] as Map<String, dynamic>;

          final Todo fetchTodo = Todo(
            id: data['id'],
            title: data['title'],
            detail: data['detail'],
            created_at: data['created_at'],
            updated_at: data['updated_at'],
          );

          return ListTile(
            title: Text(fetchTodo.title),
            trailing: IconButton(
              onPressed: () {
                showModalBottomSheet(context: context, builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TodosCreateEditPage(currentTodo: fetchTodo)));
                          },
                          leading: const Icon(Icons.edit),
                          title: const Text('編集')
                        ),
                        ListTile(
                          onTap: () async {
                            await deleteTodo(fetchTodo.id);
                            await getTodos();
                            Navigator.pop(context);
                          },
                          leading: const Icon(Icons.delete),
                          title: const Text('削除')
                        )
                      ]
                    )
                  );
                });
              },
              icon: const Icon(Icons.edit),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TodosShowPage(fetchTodo)));
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TodosCreateEditPage()));
        },
        tooltip: 'メモ追加',
        child: const Icon(Icons.add)
      ),
      bottomNavigationBar: const BottomMenu(currentPageIndex: PageIndex.todo),
    );
  }
}
