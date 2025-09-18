import 'package:flutter/material.dart';
import 'models/item.dart';
import 'cartManager.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cart = CartManager();

  Widget buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      return Image.asset(path, width: 50, height: 50, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.orange,
      ),
      body: items.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: buildImage(item.imagePath),
                    title: Text(item.name),
                    subtitle:
                    Text("RM ${item.price.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          cart.removeItem(item);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text("${item.name} removed from cart"),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "RM ${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Checkout feature coming soon..."),
                  ),
                );
              },
              child: const Text("CHECKOUT"),
            ),
          )
        ],
      ),
    );
  }
}