import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/item.dart';
import 'cartPage.dart';

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  /// save to local database
  Future<void> addToCart(Item item, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList('cart') ?? [];

    // add to cart
    cartData.add(jsonEncode(item.toJson()));

    // save
    await prefs.setStringList('cart', cartData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.name} added to cart")),
    );
  }

  /// load image from path
  Widget buildImage(String path) {
    if (path.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    } else if (path.startsWith('http')) {
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
                Text(item.description ?? 'No description available',
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
                  onPressed: () => addToCart(item, context),
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