import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos') ?? [];
    state = todosJson
        .map((todo) => Todo.fromJson(json.decode(todo)))
        .toList();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = state
        .map((todo) => json.encode(todo.toJson()))
        .toList();
    await prefs.setStringList('todos', todosJson);
  }

  void addTodo(Todo todo) {
    state = [...state, todo];
    _saveTodos();
  }

  void updateTodo(Todo todo) {
    state = [
      for (final item in state)
        if (item.id == todo.id) todo else item
    ];
    _saveTodos();
  }

  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
    _saveTodos();
  }

  void toggleTodoStatus(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo
    ];
    _saveTodos();
  }

  List<Todo> sortByPriority() {
    final sortedList = [...state];
    sortedList.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sortedList;
  }

  List<Todo> filterByStatus(bool completed) {
    return state.where((todo) => todo.isCompleted == completed).toList();
  }
}