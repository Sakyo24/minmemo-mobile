import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../model/group.dart';
import '../../model/todo.dart';
import '../../model/user.dart';
import '../../utils/app_colors.dart';
import '../todos/create_edit.dart';
import '../todos/show.dart';
import '../../utils/network.dart';
import 'add_user.dart';

class GroupsShowPage extends StatefulWidget {
  final Group currentGroup;
  const GroupsShowPage({super.key, required this.currentGroup});

  @override
  State<GroupsShowPage> createState() => _GroupsShowPageState();
}

class _GroupsShowPageState extends State<GroupsShowPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late String group_id;
  late String group_name;
  late TabController _tabController;
  int currentTab = 0;

  // todoの取得処理
  List todoItems = [];
  Future<void> getTodos() async {
    setState(() {
      _isLoading = true;
    });

    Response? response;
    try {
      response = await Network().getData('/api/groups/$group_id/todos');
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        todoItems = jsonResponse['todos'];
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ユーザーの取得処理
  List userItems = [];
  Future<void> getUsers() async {
    setState(() {
      _isLoading = true;
    });

    Response? response;
    try {
      response = await Network().getData('/api/groups/$group_id/users');
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        userItems = jsonResponse['users'];
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // todoの削除処理
  Future<void> deleteTodo({required int todo_id}) async {
    setState(() {
      _isLoading = true;
    });

    Response? response;
    try {
      response = await Network().deleteData('/api/todos/$todo_id');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (response == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("エラーが発生しました。")));
      }
      return;
    }

    // エラーの場合
    if (response.statusCode != 204) {
      if (mounted) {
        var body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            (response.statusCode >= 500 && response.statusCode < 600)
                ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
                : SnackBar(content: Text(body['message'])));
      }
      return;
    }
  }

  // ユーザーの削除処理
  Future<void> deleteUser({required int user_id}) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, int> data = {
      'user_id': user_id,
    };

    Response? response;
    try {
      response =
          await Network().postData(data, '/api/groups/$group_id/delete_user');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (response == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("エラーが発生しました。")));
      }
      return;
    }

    // エラーの場合
    if (response.statusCode != 204) {
      if (mounted) {
        var body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            (response.statusCode >= 500 && response.statusCode < 600)
                ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
                : SnackBar(content: Text(body['message'])));
      }
      return;
    }
  }

  // タブの変更処理
  void changeTab(index) {
    setState(() {
      currentTab = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    group_id = widget.currentGroup.id;
    group_name = widget.currentGroup.name;
    getTodos();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    // ユーザーのウィジェット
    List<Widget> userWidgets = [];
    // ユーザーのラベルのウィジェット
    List<Widget> userLabelWidgets = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // タイトル
          const Text('グループ名'),
          const SizedBox(height: 10),
          Text(
            widget.currentGroup.name,
            style: const TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 40),
          // メモ一覧
          const Text('ユーザー一覧'),
        ],
      ),
    ];
    // ユーザーの要素のウィジェット
    List<Widget> userItemWidgets = userItems.map((user) {
      Map<String, dynamic> data = user as Map<String, dynamic>;

      final User fetchUser = User(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        created_at: data['created_at'],
        updated_at: data['updated_at'],
      );

      final userName = fetchUser.name;

      return ListTile(
        title: Text(userName),
        trailing: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('ユーザー削除の確認'),
                    content: Text('$group_nameから$userNameを削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await deleteUser(user_id: fetchUser.id);
                          await getUsers();
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                });
          },
          icon: const Icon(Icons.delete),
        ),
      );
    }).toList();
    // ユーザーのウィジェットの結合
    userWidgets.addAll(userLabelWidgets);
    userWidgets.addAll(userItemWidgets);

    // todoのウィジェット
    List<Widget> todoWidgets = [];
    // todoのラベルのウィジェット
    List<Widget> todoLabelWidgets = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // タイトル
          const Text('グループ名'),
          const SizedBox(height: 10),
          Text(
            widget.currentGroup.name,
            style: const TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 40),
          // メモ一覧
          const Text('メモ一覧'),
        ],
      ),
    ];
    // todoの要素のウィジェット
    List<Widget> todoItemWidgets = todoItems.map((todo) {
      Map<String, dynamic> data = todo as Map<String, dynamic>;

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
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TodosCreateEditPage(
                                  currentTodo: fetchTodo,
                                  currentGroup: widget.currentGroup,
                                ),
                              ),
                            );
                          },
                          leading: const Icon(Icons.edit),
                          title: const Text('編集'),
                        ),
                        ListTile(
                          onTap: () async {
                            await deleteTodo(todo_id: fetchTodo.id);
                            await getTodos();
                            Navigator.pop(context);
                          },
                          leading: const Icon(Icons.delete),
                          title: const Text('削除'),
                        ),
                      ],
                    ),
                  );
                });
          },
          icon: const Icon(Icons.edit),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TodosShowPage(fetchTodo)),
          );
        },
      );
    }).toList();
    // todoのウィジェットの結合
    todoWidgets.addAll(todoLabelWidgets);
    todoWidgets.addAll(todoItemWidgets);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text('グループ詳細'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(child: Text('ユーザー')),
            Tab(child: Text('メモ')),
          ],
          onTap: (int index) {
            changeTab(index);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ユーザー
                ListView(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 100,
                    left: 20,
                    right: 20,
                  ),
                  children: userWidgets,
                ),
                // メモ
                ListView(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 100,
                    left: 20,
                    right: 20,
                  ),
                  children: todoWidgets,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentTab == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddUserPage(currentGroup: widget.currentGroup),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TodosCreateEditPage(currentGroup: widget.currentGroup),
              ),
            );
          }
        },
        tooltip: 'メモ追加',
        child: Icon(
          Icons.add,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}
