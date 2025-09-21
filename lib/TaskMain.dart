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
  const TaskMain({super.key, required this.title, this.serviceId});
  final String title;
  final int? serviceId; // Add serviceId parameter to filter tasks

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

  Future<void> _fetchTasks({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final data = widget.serviceId != null
          ? await supabase
              .from('tasks')
              .select()
              .eq('service_id', widget.serviceId!)
              .order('creation_time', ascending: false)
          : await supabase
              .from('tasks')
              .select()
              .order('creation_time', ascending: false);

      _tasks = data.map<Task>((e) => Task.fromSupabaseJson(e)).toList();
      
      // Remove duplicate tasks based on ID
      final Map<String, Task> uniqueTasks = {};
      for (final task in _tasks) {
        uniqueTasks[task.id] = task;
      }
      _tasks = uniqueTasks.values.toList();
      if (showLoading) {
        setState(() => _isLoading = false);
      } else {
        setState(() {}); // Just refresh the UI without showing loading
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching tasks: $e'),
        ));
      }
      if (showLoading) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<String> _getNextTaskId() async {
    try {
      // Get the highest existing ID
      final result = await supabase
          .from('tasks')
          .select('id')
          .order('id', ascending: false)
          .limit(1);

      // If there are no tasks yet, start with T001
      if (result.isEmpty) {
        return 'T001';
      }

      // Extract the highest ID
      final highestId = result[0]['id'] as String;
      final idNumber = int.parse(highestId.substring(1)); // Convert "T001" to 1
      final nextIdNumber = idNumber + 1;

      // Format the new ID back into the "T00X" format
      return 'T${nextIdNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback to timestamp-based ID if there's an error
      return 'T${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    }
  }

  void _onAddTask() {
    // Use a post-frame callback to ensure navigation happens after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showNewTaskForm();
      }
    });
  }

  Future<void> _showNewTaskForm() async {
    if (!mounted) return;
    
    try {
      final taskData = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NewTaskForm(),
        ),
      );

      print('Task data received: $taskData'); // Debug info

      if (taskData != null && taskData is Map) {
      final newTaskId = await _getNextTaskId();
      print('Generated task ID: $newTaskId'); // Debug info

      final newTask = Task(
        id: newTaskId,
        name: taskData['name'],
        description: taskData['description'],
        creationTime: DateTime.now(),
        status: 'working', // Set default status to working
        serviceId: widget.serviceId, // Include serviceId when creating task
      );

      print('Task to be created: ${newTask.toSupabaseJson()}'); // Debug info

      // Save the new task to database first (without new columns for now)
      try {
        // Create a simplified task data without the new columns
        final taskData = {
          'id': newTask.id,
          'name': newTask.name,
          'description': newTask.description,
          'creation_time': newTask.creationTime?.toIso8601String(),
          'finish_time': newTask.finishTime?.toIso8601String(),
          'total_used_time': newTask.totalUsedTime,
          'status': newTask.status,
          'service_id': newTask.serviceId,
        };
        
        await supabase.from('tasks').insert(taskData);
        print('Task created successfully'); // Debug info
      } catch (e) {
        print('Error creating task: $e'); // Debug info
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Exit if database insert fails
      }

      // Navigate to TaskDetailPage - it will handle navigation to TaskSummaryPage
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskDetailPage(
            taskName: newTask.name,
            creationTime: newTask.creationTime!,
            taskId: newTaskId, // Pass the taskId
            accumulatedSeconds: 0, // New tasks start with 0 accumulated time
          ),
        ),
      );

        // Refresh the task list when returning from the task flow
        if (mounted) {
          _fetchTasks(showLoading: false);
        }
      }
    } catch (e) {
      print('Error in task creation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          // Only update the fields that were actually edited (name and description)
          // Don't overwrite other important fields like creation_time, status, etc.
          await supabase
              .from('tasks')
              .update({
                'name': editedTask.name,
                'description': editedTask.description,
              })
              .eq('id', editedTask.id);
          _fetchTasks(showLoading: false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          print('Error updating task: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error updating task: $e'),
              backgroundColor: Colors.red,
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

        _fetchTasks(showLoading: false);
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

  void _onResumePendingTask(Task task) async {
    // Navigate to TaskDetailPage to resume the pending task
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          taskName: task.name,
          creationTime: task.creationTime!,
          taskId: task.id,
          accumulatedSeconds: task.accumulatedSeconds,
        ),
      ),
    );

    // Refresh the task list when returning
    if (mounted) {
      _fetchTasks(showLoading: false);
    }
  }

  // Helper method to get tasks by status
  List<Task> _getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Helper method to get status color
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'working':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'complete':
        return Colors.green;
      case 'fail':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'working':
        return Icons.play_circle;
      case 'pending':
        return Icons.pause_circle;
      case 'complete':
        return Icons.check_circle;
      case 'fail':
        return Icons.cancel;
      default:
        return Icons.help;
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

  Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${task.creationTime?.day.toString().padLeft(2, '0')}-${task.creationTime?.month.toString().padLeft(2, '0')}-${task.creationTime?.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _onResumePendingTask(task),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
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
        title: Text(widget.serviceId != null ? 'Tasks for Service ${widget.serviceId}' : 'Tasks'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
      body: RefreshIndicator(
        onRefresh: () => _fetchTasks(showLoading: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
          ],

          // Task Status Overview Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  'Task Status Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusCard('Working', _getTasksByStatus('working').length, Colors.blue, Icons.play_circle),
                    _buildStatusCard('Pending', _getTasksByStatus('pending').length, Colors.orange, Icons.pause_circle),
                    _buildStatusCard('Complete', _getTasksByStatus('complete').length, Colors.green, Icons.check_circle),
                    _buildStatusCard('Failed', _getTasksByStatus('fail').length, Colors.red, Icons.cancel),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pending Tasks Section
          if (_getTasksByStatus('pending').isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending_actions, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Pending Tasks (${_getTasksByStatus('pending').length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(_getTasksByStatus('pending').map((task) => _buildPendingTaskItem(task)).toList()),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Empty state when no tasks
          if (_tasks.isEmpty && !_isLoading) ...[
            const SizedBox(height: 100),
            const Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              widget.serviceId != null ? 'No tasks for this service yet' : 'No tasks yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.serviceId != null 
                ? 'Tap the + button to create a task for this service'
                : 'Tap the + button to create your first task',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 100),
          ],

          // Add some bottom padding for mobile scrolling
          const SizedBox(height: 100),
          ],
          ),
        ),
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