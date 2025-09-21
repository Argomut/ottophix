// TaskSummaryPage.dart
import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';
import 'package:ottophix/Task.dart';
import 'package:ottophix/note_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskSummaryPage extends StatefulWidget {
  final String taskName;
  final String? description;
  final DateTime finishTime;
  final String totalUsedTime;
  final DateTime creationTime;
  final List<Map<String, dynamic>>? assignedParts;
  final String? taskId; // Add taskId parameter
  final String? status; // Add status parameter

  const TaskSummaryPage({
    super.key,
    required this.taskName,
    this.description,
    required this.finishTime,
    required this.totalUsedTime,
    required this.creationTime,
    this.assignedParts,
    this.taskId, // Add taskId parameter
    this.status, // Add status parameter
  });

  @override
  State<TaskSummaryPage> createState() => _TaskSummaryPageState();
}

class _TaskSummaryPageState extends State<TaskSummaryPage> {

  Future<String> _getNextTaskId() async {
    // Query for the highest existing ID in the 'tasks' table
    final result = await supabase
        .from('tasks')
        .select('id')
        .order('id', ascending: false) // Order by ID in descending order
        .limit(1); // Get only the first (highest) one

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
  }

  Future<void> _onFinalComplete() async {
    try {
      if (widget.taskId != null) {
        // Update existing task
        await supabase
            .from('tasks')
            .update({
              'description': widget.description,
              'finish_time': widget.finishTime.toIso8601String(),
              'total_used_time': widget.totalUsedTime,
              'status': widget.status ?? 'complete',
            })
            .eq('id', widget.taskId!);
      } else {
        // Create new task only if no taskId is provided
        final newTaskId = await _getNextTaskId();
        
        final newTask = Task(
          id: newTaskId,
          name: widget.taskName,
          description: widget.description,
          creationTime: widget.creationTime,
          finishTime: widget.finishTime,
          totalUsedTime: widget.totalUsedTime,
          assignedParts: null, // We'll handle parts separately
          status: widget.status ?? 'complete', // Use provided status or default to complete
        );

        // Save the new task to database
        await supabase.from('tasks').insert(newTask.toSupabaseJson());
      }
      
      // Task parts are now handled through the cart system
      // No need to save them separately here
      
      if (mounted) {
        String message = 'Task completed successfully!';
        Color backgroundColor = Colors.green;
        
        // Customize message based on status
        if (widget.status == 'fail') {
          message = 'Task marked as failed!';
          backgroundColor = Colors.red;
        } else if (widget.status == 'complete') {
          message = 'Task completed successfully!';
          backgroundColor = Colors.green;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
          ),
        );
        
        // Navigate back to TaskMain (pop back 2 screens: TaskSummaryPage → TaskDetailPage → TaskMain)
        Navigator.of(context).pop(); // Pop TaskSummaryPage
        Navigator.of(context).pop(); // Pop TaskDetailPage to reach TaskMain
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskName),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Section
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.description ?? 'No description provided.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Finish Time Section
            Text(
              'Finish Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${widget.finishTime.day.toString().padLeft(2, '0')} - ${widget.finishTime.month.toString().padLeft(2, '0')} - ${widget.finishTime.year}  ${widget.finishTime.hour.toString().padLeft(2, '0')}:${widget.finishTime.minute.toString().padLeft(2, '0')}:${widget.finishTime.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Total Used Time Section
            Text(
              'Total Used Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.totalUsedTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Evidence Section with NotesWidget
            NotesWidget(jobId: widget.taskId ?? 'TEMP_${DateTime.now().millisecondsSinceEpoch}'),
            const SizedBox(height: 24),

            // Complete Button (Finalized)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _onFinalComplete,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Complete', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9C0E2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}