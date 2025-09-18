import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

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

  /// 从本地加载购物车
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList('cart') ?? [];

    setState(() {
      items = cartData.map((e) => Item.fromJson(jsonDecode(e))).toList();
    });
  }

  /// 从购物车删除商品
  Future<void> removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList('cart') ?? [];

    cartData.removeAt(index);
    await prefs.setStringList('cart', cartData);

    loadCart(); // 重新加载
  }

  /// 计算总价
  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.price);
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
                    leading: item.imagePath.startsWith('http')
                        ? Image.network(item.imagePath,
                        width: 50, height: 50, fit: BoxFit.cover)
                        : Image.asset(item.imagePath,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item.name),
                    subtitle: Text("RM ${item.price.toStringAsFixed(2)}"),
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

          // 总价
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

          // Checkout 按钮
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
                  final itemsToInsert = cartData.map((e) {
                    final item = jsonDecode(e);
                    return {
                      'item_name': item['name'],
                      'price': item['price'],
                      // 'user_id': Supabase.instance.client.auth.currentUser?.id, // 删除掉这行
                    };
                  }).toList();

                  try {
                    await Supabase.instance.client
                        .from('checkout')
                        .insert(itemsToInsert);

                    // 清空本地购物车
                    await prefs.remove('cart');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Checkout complete ✅")),
                    );

                    // 刷新 UI
                    loadCart();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Checkout failed ❌: $e")),
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