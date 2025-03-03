import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'Medium';

  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Task Manager'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: _toggleDarkMode,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: taskProvider.completionPercentage,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _taskController,
                decoration: InputDecoration(labelText: 'Enter Task Name'),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedPriority,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
                items: ['High', 'Medium', 'Low']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_taskController.text.isNotEmpty) {
                    taskProvider.addTask(_taskController.text, _selectedPriority);
                    _taskController.clear();
                  }
                },
                child: Text('Add Task'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task.name,
                            style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                        subtitle: Text('Priority: ${task.priority}'),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            taskProvider.toggleTaskCompletion(index);
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditDialog(context, taskProvider, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showUndoSnackbar(context, taskProvider, index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TaskProvider taskProvider, int index) {
    final TextEditingController editController =
        TextEditingController(text: taskProvider.tasks[index].name);
    String updatedPriority = taskProvider.tasks[index].priority;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: editController, decoration: InputDecoration(labelText: "Task Name")),
            DropdownButton<String>(
              value: updatedPriority,
              onChanged: (newValue) {
                setState(() {
                  updatedPriority = newValue!;
                });
              },
              items: ['High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              taskProvider.updateTask(index, editController.text, updatedPriority);
              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showUndoSnackbar(BuildContext context, TaskProvider taskProvider, int index) {
    final deletedTask = taskProvider.tasks[index];
    taskProvider.deleteTask(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Task deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            taskProvider.addTask(deletedTask.name, deletedTask.priority);
          },
        ),
      ),
    );
  }
}
