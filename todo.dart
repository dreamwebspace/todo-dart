import 'dart:io';
import 'dart:convert';

class Task {
  String description;
  bool isCompleted;

  Task(this.description, {this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'description': description,
    'isCompleted': isCompleted,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    json['description'],
    isCompleted: json['isCompleted'],
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
      final contents = file.readAsStringSync();
      final jsonList = json.decode(contents) as List;
      tasks = jsonList.map((taskJson) => Task.fromJson(taskJson)).toList();
    }
  }

  void saveTasks() {
    final file = File(fileName);
    final jsonList = tasks.map((task) => task.toJson()).toList();
    file.writeAsStringSync(json.encode(jsonList));
  }

  void addTask(String description) {
    tasks.add(Task(description));
    saveTasks();
    print('Task added: $description');
    listTasks();
  }

  void listTasks() {
    if (tasks.isEmpty) {
      print('No tasks.');
    } else {
      print('\nCurrent tasks:');
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        final status = task.isCompleted ? '[X]' : '[ ]';
        print('${i + 1}. $status ${task.description}');
      }
      print('');  // Add an empty line for better readability
    }
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      saveTasks();
      final status = tasks[index].isCompleted ? "completed" : "incomplete";
      print('Marked task as $status: ${tasks[index].description}');
      listTasks();
    } else {
      print('Invalid task number.');
    }
  }

  void removeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      final removedTask = tasks.removeAt(index);
      saveTasks();
      print('Removed task: ${removedTask.description}');
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
      print('Moved task up: ${task.description}');
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
      print('Moved task down: ${task.description}');
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
      print('Renamed task:');
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
      case 'l':
        listTasks();
        break;
      case 'm':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            toggleTaskCompletion(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: m <task number>');
        }
        break;
      case 'x':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            removeTask(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: x <task number>');
        }
        break;
      case 'u':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            moveTaskUp(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: u <task number>');
        }
        break;
      case 'd':
        if (parts.length > 1) {
          final taskNumber = int.tryParse(parts[1]);
          if (taskNumber != null) {
            moveTaskDown(taskNumber - 1);
          } else {
            print('Invalid task number.');
          }
        } else {
          print('Usage: d <task number>');
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
        print('Goodbye!');
        exit(0);
      case 'h':
        printHelp();
        break;
      default:
        print('Unknown command. Type "h" for help.');
    }
  }

  void printHelp() {
    print('Available commands:');
    print('  a <task description> - Add a new task');
    print('  l - List all tasks');
    print('  m <task number> - Mark task as complete/incomplete');
    print('  x <task number> - Remove task');
    print('  u <task number> - Move task up');
    print('  d <task number> - Move task down');
    print('  r <task number> <new description> - Rename task');
    print('  h - Show this help message');
    print('  q - Quit the application');
  }

  void run() {
    print('Welcome to the Dart To-Do App!');
    print('Type "h" for help or "q" to quit.');
    listTasks();  // Display tasks at the start
    
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
