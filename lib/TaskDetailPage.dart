// TaskDetailPage.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TaskSummaryPage.dart';
import 'searchPage.dart';
import 'item.dart';
import 'cartPage.dart';

// Part model that works with Item
class Part {
  String name;
  int quantity;
  int? itemId;
  double? price;
  String? imagePath;

  Part({
    required this.name,
    required this.quantity,
    this.itemId,
    this.price,
    this.imagePath,
  });

  // Create Part from Item
  factory Part.fromItem(Item item, int quantity) {
    return Part(
      name: item.name,
      quantity: quantity,
      itemId: item.id,
      price: item.price,
      imagePath: item.imagePath,
    );
  }

  // Convert to Item for cart functionality
  Item toItem() {
    return Item(
      id: itemId ?? 0,
      name: name,
      price: price ?? 0.0,
      imagePath: imagePath,
    );
  }
}

class TaskDetailPage extends StatefulWidget {
  final String taskName;
  final DateTime creationTime;
  final String? taskId; // Add taskId parameter

  const TaskDetailPage({
    super.key,
    required this.taskName,
    required this.creationTime,
    this.taskId, // Add taskId parameter
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  // Timer variables
  late Timer _timer;
  int _seconds = 0;
  bool _isPaused = false;

  // Controller for the note text field
  final TextEditingController _noteController = TextEditingController();

  // List of assigned parts
  final List<Part> _assignedParts = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadTaskParts();
  }

  @override
  void dispose() {
    _timer.cancel();
    _noteController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  /// Load task parts from SharedPreferences
  Future<void> _loadTaskParts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskPartsData = prefs.getStringList('task_parts_${widget.taskName}') ?? [];

      setState(() {
        _assignedParts.clear();
        for (final itemJson in taskPartsData) {
          final item = Item.fromJson(jsonDecode(itemJson));
          // Check if this part already exists, if so increment quantity
          final existingPartIndex = _assignedParts.indexWhere((part) => part.name == item.name);
          if (existingPartIndex != -1) {
            _assignedParts[existingPartIndex].quantity++;
          } else {
            _assignedParts.add(Part.fromItem(item, 1));
          }
        }
      });
    } catch (e) {
      print('Error loading task parts: $e');
    }
  }

  void _toggleTimer() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  String _formatTime(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  void _addPart() async {
    // Navigate to SearchPage to select parts
    final selectedItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => const SearchPage(isFromTaskDetail: true),
      ),
    );

    if (selectedItem != null) {
      // Item was added to cart through DetailPage, show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedItem.name} added to cart. Complete checkout to add to assigned parts.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }


  void _onComplete() {
    final finishTime = DateTime.now();
    final totalUsedTime = _formatTime(_seconds);
    final taskDescription = _noteController.text;

    // Convert parts to JSON format
    final partsJson = _assignedParts.map((part) => {
      'name': part.name,
      'quantity': part.quantity,
      'itemId': part.itemId,
      'price': part.price,
      'imagePath': part.imagePath,
    }).toList();

    // Navigate to TaskSummaryPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskSummaryPage(
          taskName: widget.taskName,
          description: taskDescription,
          finishTime: finishTime,
          totalUsedTime: totalUsedTime,
          creationTime: widget.creationTime,
          assignedParts: partsJson,
          taskId: widget.taskId, // Pass taskId
        ),
      ),
    );
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
            icon: const Icon(Icons.shopping_cart),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(taskId: widget.taskName),
                ),
              );
              // Refresh assigned parts after returning from cart
              _loadTaskParts();
            },
          ),
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
            // Create Time Section
            Text('Create Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${widget.creationTime.day.toString().padLeft(2, '0')}-${widget.creationTime.month.toString().padLeft(2, '0')}-${widget.creationTime.year}  ${widget.creationTime.hour.toString().padLeft(2, '0')}:${widget.creationTime.minute.toString().padLeft(2, '0')}:${widget.creationTime.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Timer Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      _formatTime(_seconds),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_circle : Icons.pause_circle_filled, size: 64),
                    onPressed: _toggleTimer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note Text Field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Note',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Assigned Parts List
            Text('Assigned Parts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // List of parts
                  if (_assignedParts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No parts assigned yet. Tap + to add parts.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._assignedParts.map((part) => _buildPartItem(part)).toList(),
                  // Add button
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 36),
                      onPressed: _addPart,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Complete Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _onComplete,
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

  Widget _buildPartItem(Part part) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: ListTile(
        leading: part.imagePath != null && part.imagePath!.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            part.imagePath!,
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
          part.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: part.price != null
            ? Text('RM ${part.price!.toStringAsFixed(2)} each')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Qty: ${part.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              'RM ${((part.price ?? 0) * part.quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}