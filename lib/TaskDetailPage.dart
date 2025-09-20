// TaskDetailPage.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TaskSummaryPage.dart';
import 'searchPage.dart';
import 'models/item.dart';

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

  // List of assigned parts
  final List<Part> _assignedParts = [];

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

  void _addPartToCart(Part part) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart') ?? [];

      // Add the part multiple times based on quantity
      for (int i = 0; i < part.quantity; i++) {
        cartData.add(jsonEncode(part.toItem().toJson()));
      }

      await prefs.setStringList('cart', cartData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${part.name} (x${part.quantity}) added to cart'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addAllToCart() async {
    if (_assignedParts.isEmpty) return;

    try {
      // Import SharedPreferences and json
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart') ?? [];

      int addedCount = 0;
      for (final part in _assignedParts) {
        // Add each part multiple times based on quantity
        for (int i = 0; i < part.quantity; i++) {
          cartData.add(jsonEncode(part.toItem().toJson()));
          addedCount++;
        }
      }

      await prefs.setStringList('cart', cartData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount items added to cart'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addPart() async {
    // Navigate to SearchPage to select parts
    final selectedItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );

    if (selectedItem != null) {
      // Show quantity dialog
      final quantity = await _showQuantityDialog(selectedItem);
      if (quantity != null && quantity > 0) {
        setState(() {
          _assignedParts.add(Part.fromItem(selectedItem, quantity));
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedItem.name} (x$quantity) added to parts list'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<int?> _showQuantityDialog(Item item) async {
    int quantity = 1;
    
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${item.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Price: RM ${item.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: RM ${(item.price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(quantity),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assign Parts', style: Theme.of(context).textTheme.titleLarge),
                if (_assignedParts.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _addAllToCart,
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Add All to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
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
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.green),
              onPressed: () => _addPartToCart(part),
              tooltip: 'Add to Cart',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _assignedParts.remove(part);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${part.name} removed from parts list'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}