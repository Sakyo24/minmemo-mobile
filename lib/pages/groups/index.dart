import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../components/bottom_menu.dart';
import '../../config/constants.dart';
import '../../model/group.dart';
import 'create_edit.dart';
import '../../utils/network.dart';

class GroupsIndexPage extends StatefulWidget {
  const GroupsIndexPage({super.key});

  @override
  State<GroupsIndexPage> createState() => _GroupsIndexPageState();
}

class _GroupsIndexPageState extends State<GroupsIndexPage> {
  bool _isLoading = true;

  // グループリスト取得処理
  List items = [];
  Future<void> getGroups() async {
    Response? response;
    try {
      response = await Network().getData('/api/groups');
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        items = jsonResponse['groups'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ一覧'),
        backgroundColor: const Color.fromARGB(255, 60, 0, 255),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    items[index] as Map<String, dynamic>;
                final Group fetchGroup = Group(
                  id: data['id'],
                  name: data['name'],
                  owner_user_id: data['owner_user_id'],
                  created_at: data['created_at'],
                  updated_at: data['updated_at'],
                );

                return ListTile(
                  title: Text(fetchGroup.name),
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
                                      // TODO:グループ編集ページに遷移
                                    },
                                    leading: const Icon(Icons.edit),
                                    title: const Text('編集')),
                                ListTile(
                                  onTap: () {
                                    // TODO:グループ削除処理
                                  },
                                  leading: const Icon(Icons.delete),
                                  title: const Text('削除'),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  onTap: () {
                    // TODO:グループ詳細ページに遷移
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GroupsCreateEditPage(),
            ),
          );
        },
        tooltip: 'グループ追加',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomMenu(currentPageIndex: PageIndex.group),
    );
  }
}
