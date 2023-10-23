import 'package:flutter/material.dart';

import '../components/bottom_menu.dart';
import './groups/index.dart';
import './todos/index.dart';
import './user/show.dart';
import '../utils/app_colors.dart';

class IndexPage extends StatefulWidget {
  final int? toPageIndex;
  const IndexPage({super.key, this.toPageIndex});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentPageIndex = 0;

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


  @override
  void initState() {
    super.initState();
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
      ),
      body: bodyList.elementAt(_currentPageIndex),
      bottomNavigationBar: BottomMenu(currentPageIndex: _currentPageIndex, callback: setCurrentPageIndex),
    );
  }
}
