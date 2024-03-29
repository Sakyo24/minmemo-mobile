import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../model/group.dart';
import '../auth/not_verified.dart';
import 'create_edit.dart';
import 'show.dart';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';

class GroupsIndexPage extends StatefulWidget {
  const GroupsIndexPage({super.key});

  @override
  State<GroupsIndexPage> createState() => _GroupsIndexPageState();
}

class _GroupsIndexPageState extends State<GroupsIndexPage> {
  bool _isLoading = false;

  // グループリスト取得処理
  List items = [];
  Future<void> getGroups() async {
    setState(() {
      _isLoading = true;
    });

    Response? response;
    try {
      response = await Network().getData('/api/groups');
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
    if (response.statusCode != 200) {
      if (mounted) {
        var body = json.decode(response.body);
        if (response.statusCode == 403 &&
            body['message'] == "Your email address is not verified.") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotVerifiedPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              (response.statusCode >= 500 && response.statusCode < 600)
                  ? const SnackBar(content: Text("サーバーエラーが発生しました。"))
                  : SnackBar(content: Text(body['message'])));
        }
      }
      return;
    }

    // 正常の場合
    if (!mounted) return;
    var jsonResponse = jsonDecode(response.body);
    setState(() {
      items = jsonResponse['groups'];
    });
  }

  // 削除処理
  Future<void> deleteGroup({required String id}) async {
    Response? response;
    try {
      response = await Network().deleteData('/api/groups/$id');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {});
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

  @override
  void initState() {
    super.initState();
    getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 70),
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
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GroupsCreateEditPage(
                                                  currentGroup: fetchGroup)),
                                    );
                                  },
                                  leading: const Icon(Icons.edit),
                                  title: const Text('編集'),
                                ),
                                ListTile(
                                  onTap: () async {
                                    await deleteGroup(id: fetchGroup.id);
                                    await getGroups();
                                    Navigator.pop(context);
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GroupsShowPage(currentGroup: fetchGroup)),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const GroupsCreateEditPage()),
          );
        },
        tooltip: 'グループ追加',
        child: Icon(
          Icons.add,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}
