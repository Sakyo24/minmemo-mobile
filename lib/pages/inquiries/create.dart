import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../index.dart';
import '../../utils/app_colors.dart';
import '../../utils/network.dart';

class InquiriesCreatePage extends StatefulWidget {
  const InquiriesCreatePage({super.key});

  @override
  State<InquiriesCreatePage> createState() => _InquiriesCreatePageState();
}

class _InquiriesCreatePageState extends State<InquiriesCreatePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  bool _isLoading = false;

  // 登録処理
  Future<void> createInquiry() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'title': titleController.text,
      'detail': detailController.text,
    };

    Response? response;
    try {
      response = await Network().postData(data, '/api/inquiries');
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
          builder: ((context) => const IndexPage(toPageIndex: 2))),
    ).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const Text('お問い合わせ'),
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
                      // 詳細
                      const Text('詳細'),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: detailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: '詳細を入力してください',
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 25,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 登録ボタン
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            await createInquiry();
                          },
                          child: Text(
                            '登録',
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
