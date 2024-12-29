import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:to_do_app/screens/home_screen.dart';
import 'package:to_do_app/screens/to_do_form_screen.dart';

import 'models/todo.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const TodoFormScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final todo = state.extra as Todo?;
        return TodoFormScreen(todo: todo);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}