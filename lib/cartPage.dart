import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  final String? taskId;
  
  const CartPage({super.key, this.taskId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  /// load local cart
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList('cart') ?? [];

    setState(() {
      items = cartData.map((e) => Item.fromJson(jsonDecode(e))).toList();
    });
  }

  /// delete item from cart
  Future<void> removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList('cart') ?? [];

    cartData.removeAt(index);
    await prefs.setStringList('cart', cartData);

    loadCart(); // reload
  }

  /// calculate price
  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.price);
  }

  /// Add items to task assigned parts after checkout
  Future<void> _addItemsToTaskParts(List<String> cartData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskPartsData = prefs.getStringList('task_parts_${widget.taskId}') ?? [];
      
      // Add all cart items to task parts
      for (final itemJson in cartData) {
        taskPartsData.add(itemJson);
      }
      
      await prefs.setStringList('task_parts_${widget.taskId}', taskPartsData);
    } catch (e) {
      print('Error adding items to task parts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    leading: (item.imagePath ?? '').startsWith('http')
                        ? Image.network(item.imagePath ?? '',
                        width: 50, height: 50, fit: BoxFit.cover)
                        : Image.asset(item.imagePath ?? '',
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item.name),
                    subtitle:
                    Text("RM ${item.price.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        removeItem(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${item.name} removed from cart")),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // total price
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
                  "RM ${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Checkout
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final cartData = prefs.getStringList('cart') ?? [];

                 if (cartData.isNotEmpty) {
                   try {
                     for (var itemJson in cartData) {
                       final item = jsonDecode(itemJson);

                       // save checkout record
                       await Supabase.instance.client
                           .from('checkout')
                           .insert({
                         'item_name': item['name'],
                         'price': item['price'],
                       });

                       // find stock_id and adjust stock
                       try {
                         final stockRes = await Supabase.instance.client
                             .from('stock')
                             .select('stock_id')
                             .eq('item_id', item['id'])
                             .single();

                         final stockId = stockRes['stock_id'];

                         // apply adjust_stock (-1, stock_id, 'checkout')
                         await Supabase.instance.client.rpc(
                           'adjust_stock',
                           params: {
                             'p_change': -1,
                             'p_stock_id': stockId,
                             'p_action': 'checkout',
                           },
                         );
                       } catch (stockError) {
                         print('Warning: Could not adjust stock for item ${item['name']}: $stockError');
                         // Continue with checkout even if stock adjustment fails
                       }
                     }

                    // empty cart
                    await prefs.remove('cart');

                    // If this is from a task, add items to task assigned parts
                    if (widget.taskId != null) {
                      await _addItemsToTaskParts(cartData);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Checkout complete ")),
                    );

                    // refresh UI
                    loadCart();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Checkout failed : $e")),
                    );
                  }
                }
              },
              child: const Text("CHECKOUT"),
            ),
          )
        ],
      ),
    );
  }
}