import 'package:flutter/material.dart';
import 'Task.dart';
import 'NewTaskForm.dart';
import 'TaskDetailPage.dart';
import 'EditTaskForm.dart';
import 'TaskInfoPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> _tasks = [];

  String? _selectedTask;

  void _onEditTask() async {
    if (_selectedTask != null) {
      final taskToEdit = _tasks.firstWhere((t) => t.id == _selectedTask);

      final editedTask = await Navigator.of(context).push(
        MaterialPageRoute(
          // Pass the full Task object to the EditTaskForm
          builder: (context) => EditTaskForm(task: taskToEdit),
        ),
      );

      if (editedTask != null) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == editedTask.id);
          if (index != -1) {
            _tasks[index] = editedTask;
          }
        });
        print('Edited task: ${editedTask.name}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task to edit.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  void _onViewTaskInfo() {
    if (_selectedTask != null) {
      final taskToView = _tasks.firstWhere((t) => t.id == _selectedTask);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskInfoPage(task: taskToView),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task to view information.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onDeleteTask() {
    // Check if a task is selected before proceeding
    if (_selectedTask != null) {
      final taskToDelete = _tasks.firstWhere((t) => t.id == _selectedTask);
      setState(() {
        _tasks.remove(taskToDelete);
        _selectedTask = null; // Clear the selection after deletion
      });
      print('Deleted task: ${taskToDelete.name}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task to delete.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onAddTask() async {
    final taskData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewTaskForm(),
      ),
    );

    if (taskData != null && taskData is Map) {
      // Create the initial task object with creation time
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: taskData['name'],
        description: taskData['description'],
        creationTime: DateTime.now(), // This is the Start Time
      );

      // Navigate to the TaskDetailPage and await the completion data
      final completionData = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskDetailPage(
            taskName: newTask.name,
            creationTime: newTask.creationTime!,
          ),
        ),
      );

      // If data is returned (meaning the task was completed), update the task
      if (completionData != null && completionData is Map) {
        // Update the existing task with the new data
        newTask.finishTime = completionData['finishTime'];
        newTask.totalUsedTime = completionData['totalUsedTime'];

        // Add the fully-populated task to the list
        setState(() {
          _tasks.add(newTask);
        });

      } else {
        // If the user navigates back without completing, don't add the task
        print('Task creation cancelled.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job ID: ABC1234'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown button header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Task'),
                  value: _selectedTask,
                  items: _tasks.map((Task task) {
                    return DropdownMenuItem<String>(
                      value: task.id,
                      child: Text(task.name),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTask = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 100), // Spacing below the dropdown

            // The three icons in the center
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 48),
                  onPressed: _onEditTask,
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.delete, size: 48),
                  onPressed: _onDeleteTask,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // View Task Info button
            ElevatedButton.icon(
              onPressed: _onViewTaskInfo,
              icon: const Icon(Icons.info_outline),
              label: const Text('View Task Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9C0E2),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // The add icon
            IconButton(
              icon: const Icon(Icons.add_circle, size: 64),
              onPressed: _onAddTask,
            ),
          ],
        ),
      ),
    );
  }
}