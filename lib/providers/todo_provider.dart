import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import '../models/todo.dart';

final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<TodoState> {
  final _storage = const FlutterSecureStorage();

  TodoNotifier() : super(TodoState(todos: [], jwt: '')) {
    _loadFromJWT();
  }

  Future<void> _loadFromJWT() async {
    try {
      final jwt = await _storage.read(key: 'todo_jwt');

      if (jwt != null) {
        final decodedToken = JwtDecoder.decode(jwt);
        final todosJson = decodedToken['todos'] as List<dynamic>?;

        if (todosJson != null) {
          final todosList = todosJson
              .map((todo) => Todo.fromJson(todo as Map<String, dynamic>?))
              .where((todo) => todo != null)
              .toList();

          state = TodoState(todos: todosList, jwt: jwt);

          Fluttertoast.showToast(
              msg: "succesfully loaded jwt from storage",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0
          );

        }
      }
    } catch (e) {
      print('Error loading JWT: $e');
      state = TodoState(todos: [], jwt: '');
    }
  }

  Future<void> _saveToJWT() async {
    try {
      final todos = state.todos.map((todo) => todo.toJson()).toList();

      final payload = {
        'todos': todos,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
      };

      final jwt = base64Url.encode(utf8.encode(json.encode(payload)));

      await _storage.write(key: 'todo_jwt', value: jwt);
      state = TodoState(todos: state.todos, jwt: jwt);
      Fluttertoast.showToast(
          msg: "Succesfully saved to jwt",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );

    } catch (e) {
      print('Error saving JWT: $e');
    }
  }

  void addTodo(Todo todo) {
    state = TodoState(
        todos: [...state.todos, todo],
        jwt: state.jwt
    );
    _saveToJWT();
    Fluttertoast.showToast(
        msg: "succesfully saved jwt to storage",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void updateTodo(Todo todo) {
    state = TodoState(
        todos: [
          for (final item in state.todos)
            if (item.id == todo.id) todo else item
        ],
        jwt: state.jwt
    );
    _saveToJWT();
  }

  void deleteTodo(String id) {
    state = TodoState(
        todos: state.todos.where((todo) => todo.id != id).toList(),
        jwt: state.jwt
    );
    _saveToJWT();
  }

  void toggleTodoStatus(String id) {
    state = TodoState(
        todos: [
          for (final todo in state.todos)
            if (todo.id == id)
              todo.copyWith(isCompleted: !todo.isCompleted)
            else
              todo
        ],
        jwt: state.jwt
    );
    _saveToJWT();
  }

  bool isTokenValid() {
    try {
      if (state.jwt.isEmpty) return false;

      final decodedToken = JwtDecoder.decode(state.jwt);
      final expiry = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);

      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearState() async {
    await _storage.delete(key: 'todo_jwt');
    state = TodoState(todos: [], jwt: '');
  }
}