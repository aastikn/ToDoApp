import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sort':
                  ref.read(todoProvider.notifier).sortByPriority();
                  break;
                case 'completed':
                  ref.read(todoProvider.notifier).filterByStatus(true);
                  break;
                case 'pending':
                  ref.read(todoProvider.notifier).filterByStatus(false);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Show Completed'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Show Pending'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Dismissible(
            key: Key(todo.id),
            onDismissed: (_) {
              ref.read(todoProvider.notifier).deleteTodo(todo.id);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(todo.description),
              leading: CircleAvatar(
                backgroundColor: _getPriorityColor(todo.priority),
                child: Text(
                  todo.priority.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) {
                      ref.read(todoProvider.notifier).toggleTodoStatus(todo.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.push('/edit/${todo.id}', extra: todo);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }
}
