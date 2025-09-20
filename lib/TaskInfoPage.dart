import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Task.dart';
import 'models/item.dart';

class TaskInfoPage extends StatefulWidget {
  final Task task;

  const TaskInfoPage({super.key, required this.task});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage> {
  List<Map<String, dynamic>> assignedParts = [];

  @override
  void initState() {
    super.initState();
    _loadAssignedParts();
  }

  /// Load assigned parts from SharedPreferences
  Future<void> _loadAssignedParts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskPartsData = prefs.getStringList('task_parts_${widget.task.name}') ?? [];
      
      setState(() {
        assignedParts.clear();
        for (final itemJson in taskPartsData) {
          final item = Item.fromJson(jsonDecode(itemJson));
          // Check if this part already exists, if so increment quantity
          final existingPartIndex = assignedParts.indexWhere((part) => part['name'] == item.name);
          if (existingPartIndex != -1) {
            assignedParts[existingPartIndex]['quantity'] = (assignedParts[existingPartIndex]['quantity'] ?? 1) + 1;
          } else {
            assignedParts.add({
              'name': item.name,
              'price': item.price,
              'imagePath': item.imagePath,
              'quantity': 1,
            });
          }
        }
      });
    } catch (e) {
      print('Error loading assigned parts: $e');
    }
  }

  Widget _buildPartsList() {
    if (assignedParts.isEmpty) {
      return const Text('No parts assigned.', style: TextStyle(fontSize: 16));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: assignedParts.map((partData) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: ListTile(
              leading: partData['imagePath'] != null && partData['imagePath'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        partData['imagePath'].toString(),
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
                partData['name']?.toString() ?? 'Unknown Part',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: partData['price'] != null
                  ? Text('RM ${(partData['price'] as num).toStringAsFixed(2)} each')
                  : null,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Qty: ${partData['quantity'] ?? 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (partData['price'] != null && partData['quantity'] != null)
                    Text(
                      'RM ${((partData['price'] as num) * (partData['quantity'] as num)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                ],
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
        title: Text(widget.task.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadAssignedParts();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.task.description ?? 'No description provided.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            Text('Start Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              widget.task.creationTime != null ? '${widget.task.creationTime!.day}-${widget.task.creationTime!.month}-${widget.task.creationTime!.year}  ${widget.task.creationTime!.hour}:${widget.task.creationTime!.minute}:${widget.task.creationTime!.second}' : 'Not available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            Text('Finish Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              widget.task.finishTime != null ? '${widget.task.finishTime!.day}-${widget.task.finishTime!.month}-${widget.task.finishTime!.year}  ${widget.task.finishTime!.hour}:${widget.task.finishTime!.minute}:${widget.task.finishTime!.second}' : 'Not available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            Text('Total Used Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.task.totalUsedTime ?? 'Not available', style: const TextStyle(fontSize: 16)),
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