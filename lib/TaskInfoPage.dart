import 'package:flutter/material.dart';
import 'Task.dart'; // Make sure this file exists

class TaskInfoPage extends StatelessWidget {
  final Task task;

  const TaskInfoPage({super.key, required this.task});

  Widget _buildPartsList() {
    if (task.assignedParts == null || task.assignedParts!.isEmpty) {
      return const Text('No parts assigned.', style: TextStyle(fontSize: 16));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: task.assignedParts!.map((partData) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: ListTile(
              leading: partData['imagePath'] != null && partData['imagePath'].isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        partData['imagePath'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.inventory_2),
                    ),
              title: Text(
                partData['name'] ?? 'Unknown Part',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: partData['price'] != null
                  ? Text('RM ${partData['price'].toStringAsFixed(2)} each')
                  : null,
              trailing: Text(
                'Qty: ${partData['quantity'] ?? 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

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
            _buildPartsList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}