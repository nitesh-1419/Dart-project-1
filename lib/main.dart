import 'dart:io';

enum Priority { High, Medium, Low }

class Task {
  String title;
  Priority priority;
  bool isCompleted;

  Task(this.title, this.priority, {this.isCompleted = false});

  @override
  String toString() {
    String status = isCompleted ? "✅" : "❌";
    return "$status $title (${priority.name})";
  }
}

class TodoApp {
  List<Task> tasks = [];

  void addTask() {
    stdout.write("Enter task title: ");
    String title = stdin.readLineSync()!;

    stdout.write("Enter priority (1-High, 2-Medium, 3-Low): ");
    int choice = int.parse(stdin.readLineSync()!);

    Priority priority;
    switch (choice) {
      case 1:
        priority = Priority.High;
        break;
      case 2:
        priority = Priority.Medium;
        break;
      default:
        priority = Priority.Low;
    }

    tasks.add(Task(title, priority));
    print("Task added successfully!");
  }

  void viewTasks() {
    if (tasks.isEmpty) {
      print("No tasks available.");
      return;
    }

    print("\n--- Task List ---");
    for (int i = 0; i < tasks.length; i++) {
      print("$i. ${tasks[i]}");
    }
  }

  void markComplete() {
    viewTasks();
    if (tasks.isEmpty) return;

    stdout.write("Enter task index to mark complete: ");
    int index = int.parse(stdin.readLineSync()!);

    if (index >= 0 && index < tasks.length) {
      tasks[index].isCompleted = true;
      print("Task marked as completed!");
    } else {
      print("Invalid index.");
    }
  }

  void deleteTask() {
    viewTasks();
    if (tasks.isEmpty) return;

    stdout.write("Enter task index to delete: ");
    int index = int.parse(stdin.readLineSync()!);

    if (index >= 0 && index < tasks.length) {
      tasks.removeAt(index);
      print("Task deleted!");
    } else {
      print("Invalid index.");
    }
  }

  void sortTasks() {
    tasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    print("Tasks sorted by priority!");
  }
}

void main() {
  TodoApp app = TodoApp();

  while (true) {
    print("\n==== TO-DO MENU ====");
    print("1. Add Task");
    print("2. View Tasks");
    print("3. Mark Complete");
    print("4. Delete Task");
    print("5. Sort by Priority");
    print("6. Exit");

    stdout.write("Choose option: ");
    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        app.addTask();
        break;
      case 2:
        app.viewTasks();
        break;
      case 3:
        app.markComplete();
        break;
      case 4:
        app.deleteTask();
        break;
      case 5:
        app.sortTasks();
        break;
      case 6:
        print("Goodbye!");
        return;
      default:
        print("Invalid option.");
    }
  }
}