import 'package:flutter/material.dart';

class TodoDetailPage extends StatelessWidget {
  final String todo;
  const TodoDetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            todo,
            style: const TextStyle(fontSize: 30.0),
          ),
        ),
      ),
    );
  }
}
