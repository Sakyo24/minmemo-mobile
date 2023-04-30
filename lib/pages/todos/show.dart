import 'package:flutter/material.dart';
import '../../model/todo.dart';
import 'create_edit.dart';

class TodosShowPage extends StatelessWidget {
  final Todo todo;
  const TodosShowPage(this.todo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ詳細'),
        backgroundColor: const Color.fromARGB(255, 60, 0, 255)
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // タイトル
              const Text('タイトル'),
              const SizedBox(height: 10),
              Text(todo.title, style: const TextStyle(fontSize: 24.0)),
              const SizedBox(height: 40),
              // 詳細
              const Text('詳細'),
              const SizedBox(height: 10),
              Text(todo.detail, style: const TextStyle(fontSize: 24.0)),
              const SizedBox(height: 40),
              // 登録日時
              const Text('登録日時'),
              const SizedBox(height: 10),
              Text(todo.created_at, style: const TextStyle(fontSize: 24.0)),
              const SizedBox(height: 40),
              // 最終更新日時
              const Text('最終更新日時'),
              const SizedBox(height: 10),
              Text(todo.updated_at, style: const TextStyle(fontSize: 24.0)),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TodosCreateEditPage(currentTodo: todo)));
                  },
                  child: const Text('編集')
                )
              )
            ]
          )
        ]
      )
    );
  }
}