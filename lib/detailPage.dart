import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/item.dart';
import 'cartPage.dart';

class DetailPage extends StatelessWidget {
  final Item item;
  final bool isFromTaskDetail;

  const DetailPage({super.key, required this.item, this.isFromTaskDetail = false});

  /// save to local database
  Future<Item?> addToCart(Item item, BuildContext context) async {
    if (isFromTaskDetail) {
      // If called from TaskDetailPage, show quantity dialog first
      final quantity = await _showQuantityDialog(item, context);
      if (quantity == null || quantity <= 0) {
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart') ?? [];

      // Add the item multiple times based on quantity
      for (int i = 0; i < quantity; i++) {
        cartData.add(jsonEncode(item.toJson()));
      }

      // save
      await prefs.setStringList('cart', cartData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.name} (x$quantity) added to cart")),
      );

      return item;
    } else {
      // Normal flow: add single item to cart
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart') ?? [];

      // add to cart
      cartData.add(jsonEncode(item.toJson()));

      // save
      await prefs.setStringList('cart', cartData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.name} added to cart")),
      );

      return null;
    }
  }

  /// Show quantity selection dialog
  Future<int?> _showQuantityDialog(Item item, BuildContext context) async {
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

  /// load image from path
  Widget buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.asset(path, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(child: buildImage(item.imagePath ?? '')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("RM ${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Text(item.description ?? '',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("BACK"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black),
                  onPressed: () async {
                    final result = await addToCart(item, context);
                    if (isFromTaskDetail && result != null) {
                      Navigator.of(context).pop(result);
                    }
                  },
                  child: const Text("ADD TO CART"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const CartPage()));
                  },
                  child: const Text("CART"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}