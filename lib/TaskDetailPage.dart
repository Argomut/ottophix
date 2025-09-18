// TaskDetailPage.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'TaskSummaryPage.dart';

// Assuming you have a Part model defined
class Part {
  String name;
  int quantity;
  Part({required this.name, required this.quantity});
}

class TaskDetailPage extends StatefulWidget {
  final String taskName;
  final DateTime creationTime;

  const TaskDetailPage({
    super.key,
    required this.taskName,
    required this.creationTime,
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

  // List of assigned parts (dummy data)
  final List<Part> _assignedParts = [
    Part(name: 'Part 1', quantity: 7),
    Part(name: 'Part 2', quantity: 5),
    Part(name: 'Part 7', quantity: 1),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  void _addPart() {
    // Logic to add a new part to the list
    setState(() {
      _assignedParts.add(Part(name: 'New Part', quantity: 1));
    });
    print('Add Part button pressed');
  }

  void _onComplete() {
    final finishTime = DateTime.now();
    final totalUsedTime = _formatTime(_seconds);
    final taskDescription = _noteController.text;

    // Pop this page and return the combined data
    Navigator.of(context).pop({
      'description': taskDescription,
      'finishTime': finishTime,
      'totalUsedTime': totalUsedTime,
    });
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
            Text('Assign Parts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  // List of parts
                  ..._assignedParts.map((part) => _buildPartItem(part)).toList(),
                  // Add button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 36),
                    onPressed: _addPart,
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
        title: Text(part.name),
        trailing: Text(part.quantity.toString()),
      ),
    );
  }
}