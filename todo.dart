import 'dart:convert';
import 'dart:io';

class Task {
  String description;
  bool isCompleted;

  Task(this.description, {this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'description': description,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        json['description'] as String,
        isCompleted: json['isCompleted'] as bool,
      );
}

class TodoApp {
  List<Task> tasks = [];
  final String fileName = 'tasks.json';

  TodoApp() {
    loadTasks();
  }

  void loadTasks() {
    final file = File(fileName);
    if (file.existsSync()) {
      try {
        final jsonString = file.readAsStringSync();
        final jsonList = json.decode(jsonString) as List;
        tasks = jsonList.map((jsonTask) => Task.fromJson(jsonTask)).toList();
      } catch (e) {
        print('Error reading file: $e');
      }
    }
  }

  void saveTasks() {
    final jsonList = tasks.map((task) => task.toJson()).toList();
    final jsonString = json.encode(jsonList);
    File(fileName).writeAsStringSync(jsonString);
  }

  void addTask(String description) {
    tasks.add(Task(description));
    saveTasks();
    listTasks();
  }

  void listTasks() {
    if (tasks.isEmpty) {
      print('No tasks.');
    } else {
      print('');
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        final status = task.isCompleted ? '[X]' : '[ ]';
        print('${i + 1}. $status ${task.description}');
      }
      print('');
    }
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      saveTasks();
      listTasks();
    } else {
      print('Invalid task number.');
    }
  }

  void removeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks.removeAt(index);
      saveTasks();
      listTasks();
    } else {
      print('Invalid task number.');
    }
  }

  void moveTaskUp(int index) {
    if (index > 0 && index < tasks.length) {
      final task = tasks.removeAt(index);
      tasks.insert(index - 1, task);
      saveTasks();
      listTasks();
    } else {
      print('Cannot move task up.');
    }
  }

  void moveTaskDown(int index) {
    if (index >= 0 && index < tasks.length - 1) {
      final task = tasks.removeAt(index);
      tasks.insert(index + 1, task);
      saveTasks();
      listTasks();
    } else {
      print('Cannot move task down.');
    }
  }

  void renameTask(int index, String newDescription) {
    if (index >= 0 && index < tasks.length) {
      final oldDescription = tasks[index].description;
      tasks[index].description = newDescription;
      saveTasks();
      print('  From: $oldDescription');
      print('  To:   $newDescription');
      listTasks();
    } else {
      print('Invalid task number.');
    }
  }

  void processCommand(String command) {
    final parts = command.split(' ');
    final action = parts[0].toLowerCase();

    switch (action) {
      case 'a':
        if (parts.length > 1) {
          addTask(parts.sublist(1).join(' '));
        } else {
          print('Usage: a <task description>');
        }
        break;
      case 't':
        listTasks();
        break;
      case 'x':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            toggleTaskCompletion(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: x <task number>');
        }
        break;
      case 'd':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            removeTask(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: d <task number>');
        }
        break;
      case 'h':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            moveTaskUp(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: h <task number>');
        }
        break;
      case 'l':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            moveTaskDown(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: l <task number>');
        }
        break;
      case 'r':
        if (parts.length > 2) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            final newDescription = parts.sublist(2).join(' ');
            renameTask(taskNumber - 1, newDescription);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: r <task number> <new task description>');
        }
        break;
      case 'q':
        exit(0);
      case '?':
        printHelp();
        break;
      default:
        print('Unknown command. Type "?" for help.');
    }
  }

  void printHelp() {
    print('Available commands:');
    print('  a <task description> - Add a new task');
    print('  t - List all tasks');
    print('  x <task number> - Mark task as complete/incomplete');
    print('  d <task number> - Remove task');
    print('  h <task number> - Move task higher');
    print('  l <task number> - Move task lower');
    print('  r <task number> <new description> - Rename task');
    print('  ? - Show this help message');
    print('  q - Quit the application');
  }

  void run() {
    listTasks(); // Display tasks at the start

    while (true) {
      stdout.write('> ');
      final input = stdin.readLineSync();
      if (input != null && input.isNotEmpty) {
        processCommand(input);
      }
    }
  }
}

void main() {
  TodoApp().run();
}
