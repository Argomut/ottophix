// TaskMain.dart

import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Task.dart';
import 'NewTaskForm.dart';
import 'TaskDetailPage.dart';
import 'EditTaskForm.dart';
import 'TaskInfoPage.dart';


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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('tasks')
          .select()
          .order('creation_time', ascending: false);

      _tasks = data.map<Task>((e) => Task.fromSupabaseJson(e)).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching tasks: $e'),
        ));
      }
      setState(() => _isLoading = false);
    }
  }


  Future<String> _getNextTaskId() async {
    final count = await supabase
        .from('tasks')
        .count();

    // Add 1 to the count to get the next number
    final nextNumber = count + 1;
    return 'T${nextNumber.toString().padLeft(3, '0')}';
  }

  void _onAddTask() async {
    final taskData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewTaskForm(),
      ),
    );

    if (taskData != null && taskData is Map) {
      final newTaskId = await _getNextTaskId();

      final newTask = Task(
        id: newTaskId,
        name: taskData['name'],
        description: taskData['description'],
        creationTime: DateTime.now(),
      );

      final completionData = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskDetailPage(
            taskName: newTask.name,
            creationTime: newTask.creationTime!,
          ),
        ),
      );

      if (completionData != null && completionData is Map) {
        newTask.finishTime = completionData['finishTime'];
        newTask.totalUsedTime = completionData['totalUsedTime'];

        try {
          await supabase.from('tasks').insert(newTask.toSupabaseJson());
          if (mounted) {
            _fetchTasks();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error adding task: $e'),
            ));
          }
        }
      }
    }
  }

  void _onEditTask() async {
    if (_selectedTask != null) {
      final taskToEdit = _tasks.firstWhere((t) => t.id == _selectedTask);

      final editedTask = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditTaskForm(task: taskToEdit),
        ),
      );

      if (editedTask != null) {
        try {
          await supabase
              .from('tasks')
              .update(editedTask.toSupabaseJson())
              .eq('id', editedTask.id);
          _fetchTasks();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error updating task: $e'),
            ));
          }
        }
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

  void _onDeleteTask() async {
    if (_selectedTask != null) {
      try {
        await supabase
            .from('tasks')
            .delete()
            .eq('id', _selectedTask!);

        _fetchTasks();
        setState(() {
          _selectedTask = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting task: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task to delete.'),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            const SizedBox(height: 100),

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