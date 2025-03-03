import 'package:flutter/material.dart';
import 'task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String name, String priority) {
    _tasks.add(Task(name: name, priority: priority));
    sortTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void sortTasks() {
    _tasks.sort((a, b) {
      Map<String, int> priorityMap = {"High": 1, "Medium": 2, "Low": 3};
      return priorityMap[a.priority]!.compareTo(priorityMap[b.priority]!);
    });
  }
}

