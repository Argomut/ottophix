// TaskMain.dart

import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Task.dart';
import 'NewTaskForm.dart';
import 'TaskDetailPage.dart';
import 'EditTaskForm.dart';
import 'TaskInfoPage.dart';


class TaskMain extends StatefulWidget {
  const TaskMain({super.key, required this.title});
  final String title;

  @override
  State<TaskMain> createState() => _TaskMainState();
}

class _TaskMainState extends State<TaskMain> {
  List<Task> _tasks = [];
  String? _selectedTask;
  bool _isLoading = true;
  bool _isFabOpen = false;

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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
            onPressed: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Task Selection Section
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Choose a task to manage'),
                      value: _selectedTask,
                      items: _tasks.map((Task task) {
                        return DropdownMenuItem<String>(
                          value: task.id,
                          child: Text(
                            task.name,
                            style: const TextStyle(fontSize: 16),
                          ),
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
              ],
            ),
          ),

          // Task Actions Section (only show if task is selected)
          if (_selectedTask != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Task Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.info_outline,
                        label: 'View Info',
                        color: Colors.blue,
                        onPressed: _onViewTaskInfo,
                      ),
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: Colors.orange,
                        onPressed: _onEditTask,
                      ),
                      _buildActionButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        color: Colors.red,
                        onPressed: _onDeleteTask,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Empty state when no tasks
          if (_tasks.isEmpty && !_isLoading) ...[
            const Spacer(),
            const Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to create your first task',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
          ],

          // Spacer to push content up
          if (_tasks.isNotEmpty) const Spacer(),
        ],
      ),

      // Floating Action Button with Speed Dial
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Speed Dial Options
          if (_isFabOpen) ...[
            // Add Task FAB
            FloatingActionButton(
              heroTag: "add_task",
              mini: true,
              backgroundColor: Colors.green,
              onPressed: () {
                setState(() => _isFabOpen = false);
                _onAddTask();
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 10),
            
            // View Task Info FAB (only if task selected)
            if (_selectedTask != null) ...[
              FloatingActionButton(
                heroTag: "view_info",
                mini: true,
                backgroundColor: Colors.blue,
                onPressed: () {
                  setState(() => _isFabOpen = false);
                  _onViewTaskInfo();
                },
                child: const Icon(Icons.info_outline, color: Colors.white),
              ),
              const SizedBox(height: 10),
            ],
            
            // Edit Task FAB (only if task selected)
            if (_selectedTask != null) ...[
              FloatingActionButton(
                heroTag: "edit_task",
                mini: true,
                backgroundColor: Colors.orange,
                onPressed: () {
                  setState(() => _isFabOpen = false);
                  _onEditTask();
                },
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              const SizedBox(height: 10),
            ],
            
            // Delete Task FAB (only if task selected)
            if (_selectedTask != null) ...[
              FloatingActionButton(
                heroTag: "delete_task",
                mini: true,
                backgroundColor: Colors.red,
                onPressed: () {
                  setState(() => _isFabOpen = false);
                  _onDeleteTask();
                },
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              const SizedBox(height: 10),
            ],
          ],
          
          // Main FAB
          FloatingActionButton(
            heroTag: "main_fab",
            onPressed: () {
              setState(() {
                _isFabOpen = !_isFabOpen;
              });
            },
            child: AnimatedRotation(
              turns: _isFabOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isFabOpen ? Icons.close : Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}