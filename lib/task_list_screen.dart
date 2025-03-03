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

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  return ListTile(
                    title: Text(task.name),
                    subtitle: Text('Priority: ${task.priority}'),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        taskProvider.toggleTaskCompletion(index);
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        taskProvider.deleteTask(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
