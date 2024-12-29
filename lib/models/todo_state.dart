import 'package:to_do_app/models/todo.dart';

class TodoState {
  final List<Todo> todos;
  final String jwt;

  TodoState({required this.todos, required this.jwt});
}