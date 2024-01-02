import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('Describe Todo List App', () {
    Widget buildApp({MockApiClient? apiClient}) {
      return TodoApp(apiClient: apiClient);
    }

    testWidgets('it should correctly show title text', (tester) async {
      await tester.pumpWidget(buildApp());
      final title = find.text('Todo List');
      expect(title, findsOneWidget);
    });

    testWidgets('it should correctly submit a todo', (tester) async {
      await tester.pumpWidget(buildApp());
      final inputWidget = find.byKey(const Key('todo-input'));
      expect(inputWidget, findsOneWidget);

      await tester.enterText(inputWidget, 'Sample Todo 1');
      final userInput = find.text('Sample Todo 1');
      expect(userInput, findsOneWidget);

      final submitBtnWidget = find.byKey(const Key('submit-btn'));
      expect(submitBtnWidget, findsOneWidget);

      await tester.tap(submitBtnWidget);
      await tester.pumpAndSettle();

      final todoListTile = find.text('Sample Todo 1');
      expect(todoListTile, findsOneWidget);
    });

    testWidgets(
        'it should correctly display an error message if the user submits with an empty todo input',
        (tester) async {
      await tester.pumpWidget(buildApp());
      final submitBtnWidget = find.byKey(const Key('submit-btn'));

      await tester.tap(submitBtnWidget);
      await tester.pumpAndSettle();

      final notif = find.byType(SnackBar);
      expect(notif, findsOneWidget);
      final snackBarErrorMessage = find.text('Please input a todo.');
      expect(snackBarErrorMessage, findsOneWidget);
    });

    testWidgets(
        'it should correctly display an error message if the user submits an already existing todo',
        (tester) async {
      await tester.pumpWidget(buildApp());
      final inputWidget = find.byKey(const Key('todo-input'));
      final submitBtnWidget = find.byKey(const Key('submit-btn'));

      await tester.enterText(inputWidget, 'Sample Todo 1');
      await tester.tap(submitBtnWidget);
      await tester.pumpAndSettle();

      await tester.enterText(inputWidget, 'Sample Todo 1');
      await tester.tap(submitBtnWidget);
      await tester.pump();

      final snackBarErrorMessage =
          find.text('Todo already exists. Please enter a new one.');
      expect(snackBarErrorMessage, findsOneWidget);

      await tester.enterText(inputWidget, 'Sample Todo 2');
      await tester.tap(submitBtnWidget);
      await tester.pumpAndSettle();

      final todoListTile = find.text('Sample Todo 2');
      expect(todoListTile, findsOneWidget);
    });

    testWidgets('it should correctly generate a todo',
        (WidgetTester tester) async {
      const String url = 'https://dummyjson.com/todos/random';
      final mockApiClient = MockApiClient();
      await tester.pumpWidget(buildApp(apiClient: mockApiClient));

      const fakeTodo = {
        'body': {
          'id': 1,
          'todo': 'test generated todo',
          'completed': true,
          'userId': 1
        },
        'isSuccess': true
      };

      when(mockApiClient.fetchTodos(url: url))
          .thenAnswer((_) async => fakeTodo);

      final generateBtnWidget = find.byKey(const Key('generate-btn'));
      await tester.tap(generateBtnWidget);
      await tester.pumpAndSettle();

      verify(mockApiClient.fetchTodos(url: url)).called(1);
      final newGeneratedTodo = find.text('test generated todo');
      expect(newGeneratedTodo, findsOneWidget);
    });

    testWidgets(
        'it should correctly display an error message if the user generates an already existing todo',
        (WidgetTester tester) async {
      const String url = 'https://dummyjson.com/todos/random';
      final mockApiClient = MockApiClient();
      await tester.pumpWidget(buildApp(apiClient: mockApiClient));

      const fakeTodo = {
        'body': {
          'id': 1,
          'todo': 'test generated todo',
          'completed': true,
          'userId': 1
        },
        'isSuccess': true
      };

      when(mockApiClient.fetchTodos(url: url))
          .thenAnswer((_) async => fakeTodo);

      final generateBtnWidget = find.byKey(const Key('generate-btn'));
      await tester.tap(generateBtnWidget);
      await tester.pumpAndSettle();
      await tester.tap(generateBtnWidget);
      await tester.pumpAndSettle();

      verify(mockApiClient.fetchTodos(url: url)).called(2);
      final snackBarErrorMessage =
          find.text('Generated todo already exists. Please try again.');
      expect(snackBarErrorMessage, findsOneWidget);
    });

    testWidgets('it should be able to delete a todo', (tester) async {
      await tester.pumpWidget(buildApp());
      final inputWidget = find.byKey(const Key('todo-input'));
      expect(inputWidget, findsOneWidget);

      await tester.enterText(inputWidget, 'Sample Todo 1');
      final userInput = find.text('Sample Todo 1');
      expect(userInput, findsOneWidget);

      final submitBtnWidget = find.byKey(const Key('submit-btn'));
      expect(submitBtnWidget, findsOneWidget);

      await tester.tap(submitBtnWidget);
      await tester.pumpAndSettle();

      final todoListTile = find.text('Sample Todo 1');
      expect(todoListTile, findsOneWidget);

      final deleteBtnWidget = find.byKey(const Key('delete-btn'));
      await tester.tap(deleteBtnWidget);
      await tester.pumpAndSettle();

      final todoListTile1 = find.text('Sample Todo 1');
      expect(todoListTile1, findsNothing);
    });
  });
}
