import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      List<dynamic> decodedTasks = jsonDecode(tasksJson);
      _tasks = decodedTasks.map((task) => Task.fromJson(task)).toList();
      notifyListeners();
    }
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(_tasks));
  }

  void addTask(String name, String priority) {
    _tasks.add(Task(name: name, priority: priority));
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(int index, String newName, String newPriority) {
    _tasks[index].name = newName;
    _tasks[index].priority = newPriority;
    _saveTasks();
    notifyListeners();
  }

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get totalTasks => _tasks.length;

  double get completionPercentage =>
      _tasks.isEmpty ? 0.0 : completedTasks / totalTasks;
}
