enum Priority { low, medium, high }

class Todo {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final Priority priority;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.priority,
  });

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
  }) {
    return Todo(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.toString(),
    };
  }

  static Todo fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw FormatException('Null JSON provided to Todo.fromJson');
    }

    return Todo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: Priority.values.firstWhere(
            (e) => e.toString() == (json['priority'] as String?),
        orElse: () => Priority.low,
      ),
    );
  }
}

// lib/models/todo_state.dart
class TodoState {
  final List<Todo> todos;
  final String jwt;

  TodoState({required this.todos, required this.jwt});
}