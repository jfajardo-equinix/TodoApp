import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'page.dart';
import 'api_client.dart';

void main() {
  final apiClient = ApiClient();
  runApp(TodoApp(apiClient: apiClient));
}

class TodoApp extends StatelessWidget {
  final ApiClient? apiClient;
  const TodoApp({super.key, this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
        ),
        body: TodoListApp(apiClient: apiClient),
      ),
    );
  }
}

class TodoListApp extends StatefulWidget {
  final ApiClient? apiClient;
  const TodoListApp({super.key, this.apiClient});

  @override
  State<StatefulWidget> createState() => TodoListAppState();
}

class TodoListAppState extends State<TodoListApp> {
  List<String> todos = [];
  bool isLoading = false;
  final TextEditingController todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedTodos();
  }

  void loadSavedTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => todos = prefs.getStringList('todos') ?? []);
  }

  void saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', todos);
  }

  void addTodo(String todo) {
    setState(() => todos.add(todo));
    todoController.clear();
    saveTodos();
  }

  void removeTodo(int index) {
    setState(() => todos.removeAt(index));
    saveTodos();
  }

  void navigateToTodoDetail(String todo, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoDetailPage(todo: todo),
      ),
    );
  }

  void submitTodo(String newTodo, BuildContext context) {
    if (newTodo.isEmpty) {
      notify('Please input a todo.', context);
      return;
    }
    if (todos.contains(newTodo)) {
      notify('Todo already exists. Please enter a new one.', context);
      return;
    }
    addTodo(newTodo);
  }

  void generateTodo(BuildContext context) async {
    setState(() => isLoading = true);

    const String url = 'https://dummyjson.com/todos/random';
    final response =
        await (widget.apiClient ?? ApiClient()).fetchTodos(url: url);

    if (response['isSuccess'] && context.mounted) {
      String newTodo = response['body']['todo'];

      if (!todos.contains(newTodo)) {
        addTodo(newTodo);
        setState(() => isLoading = false);
        return;
      }

      notify('Generated todo already exists. Please try again.', context);
    } else {
      notify('There was an error generating. Please try again.', context);
    }

    setState(() => isLoading = false);
  }

  void notify(String message, BuildContext context) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(message),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.none,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 90,
          right: 25,
          left: 25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget todoList() {
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          int number = index + 1;
          return ListTile(
            title: Text(todos[index]),
            leading: Text('$number.)'),
            onTap: () => navigateToTodoDetail(todos[index], context),
            trailing: OutlinedButton(
              key: const Key('delete-btn'),
              onPressed: () => removeTodo(index),
              child: const Icon(Icons.delete),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              key: const Key('list-view'),
              child: Card(
                  elevation: 5,
                  child: todos.isEmpty
                      ? const Center(child: Text('Nothing to show here :('))
                      : todoList()),
            ),
            const SizedBox(height: 20),
            TextField(key: const Key('todo-input'), controller: todoController),
            const SizedBox(height: 20),
            const Text('What do I need to do?'),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('submit-btn'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () => submitTodo(todoController.text, context),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              key: const Key('generate-btn'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: isLoading ? null : () => generateTodo(context),
              child: isLoading
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Generate a random todo!'),
            ),
          ],
        ),
      ),
    );
  }
}
