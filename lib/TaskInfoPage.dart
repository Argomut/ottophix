import 'package:flutter/material.dart';
import 'Task.dart'; // Make sure this file exists

class TaskInfoPage extends StatelessWidget {
  final Task task;

  const TaskInfoPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(task.description ?? 'No description provided.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            Text('Start Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              task.creationTime != null ? '${task.creationTime!.day}-${task.creationTime!.month}-${task.creationTime!.year}  ${task.creationTime!.hour}:${task.creationTime!.minute}:${task.creationTime!.second}' : 'Not available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            Text('Finish Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              task.finishTime != null ? '${task.finishTime!.day}-${task.finishTime!.month}-${task.finishTime!.year}  ${task.finishTime!.hour}:${task.finishTime!.minute}:${task.finishTime!.second}' : 'Not available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            Text('Total Used Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(task.totalUsedTime ?? 'Not available', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Note: Add sections for Evidence and Assigned Parts here.
            Text('Evidence', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('No evidence uploaded.', style: TextStyle(fontSize: 16)), // Placeholder
            const SizedBox(height: 24),

            Text('Requested Parts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('No parts assigned.', style: TextStyle(fontSize: 16)), // Placeholder
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}