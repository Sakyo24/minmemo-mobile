import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../components/bottom_menu.dart';
import './groups/index.dart';
import './inquiries/create.dart';
import './todos/index.dart';
import './user/edit_password.dart';
import './user/show.dart';
import './top.dart';
import '../utils/app_colors.dart';
import '../utils/network.dart';

class IndexPage extends StatefulWidget {
  final int? toPageIndex;
  const IndexPage({super.key, this.toPageIndex});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentPageIndex = 0;
  String? _email;
  bool _isLoading = false;

  final List titleList = [
    'メモ一覧',
    'グループ一覧',
    'マイページ',
  ];

  final List bodyList = [
    const TodosIndexPage(),
    const GroupsIndexPage(),
    const UserShowPage(),
  ];

  void setCurrentPageIndex(int data) {
    setState(() {
      _currentPageIndex = data;
    });
  }

  // ユーザーの取得
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);

    if (user != null) {
      setState(() {
        _email = user['email'];
      });
    }
  }

  // ログアウト処理
  Future<void> logout() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {'email': _email ?? ''};

    Response? res;
    try {
      res = await Network().postData(data, '/api/logout');
    } catch (e) {
      debugPrint(e.toString());
    }

    if (res == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("エラーが発生しました。"),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // エラーの場合
    if (res.statusCode != 204) {
      var body = json.decode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          (res.statusCode >= 500 && res.statusCode < 600)
              ? const SnackBar(
                  content: Text("サーバーエラーが発生しました。"),
                )
              : SnackBar(
                  content: Text(body['message']),
                ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 正常の場合
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    localStorage.remove('token');

    if (!mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const TopPage()));
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (widget.toPageIndex != null) {
      _currentPageIndex = widget.toPageIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(titleList[_currentPageIndex]),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 1,
                  child: Text('パスワード変更'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('お問い合わせ'),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text(
                    'ログアウト',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ];
            },
            onSelected: (int value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditPasswordPage()),
                );
              } else if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InquiriesCreatePage()),
                );
              } else if (value == 3) {
                logout();
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : bodyList.elementAt(_currentPageIndex),
      bottomNavigationBar: BottomMenu(
        currentPageIndex: _currentPageIndex,
        callback: setCurrentPageIndex,
      ),
    );
  }
}
