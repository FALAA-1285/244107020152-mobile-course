import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    return const [];
  }

  Future<void> add(String title) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network request
      final currentTodos = state.value ?? <Todo>[];
      return <Todo>[...currentTodos, Todo(title)];
    });
  }

  Future<void> toggleTodo(Todo todo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      final currentTodos = state.value ?? <Todo>[];
      final index = currentTodos.indexOf(todo);
      if (index != -1) {
        final List<Todo> todos = <Todo>[...currentTodos];
        todos[index] = todos[index].copyWith(done: !todos[index].done);
        return todos;
      }
      return currentTodos;
    });
  }

  Future<void> removeTodo(Todo todo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      final currentTodos = state.value ?? <Todo>[];
      final index = currentTodos.indexOf(todo);
      if (index != -1) {
        return <Todo>[...currentTodos]..removeAt(index);
      }
      return currentTodos;
    });
  }
}

final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

final uncompletedTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoListProvider);
  return todosAsync.whenData((todos) => todos.where((todo) => !todo.done).toList());
});

final completedTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoListProvider);
  return todosAsync.whenData((todos) => todos.where((todo) => todo.done).toList());
});