import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'inventoryLogPage.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> stocks = [];

  @override
  void initState() {
    super.initState();
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    try {
      final response = await supabase
          .from('stock')
          .select(
          'stock_id, stock_quantity, category, location, stock_number, item(id, name, price, description, image_path)')
          .order('stock_id');

      setState(() {
        stocks = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      print("Error fetching stock: $e");
      setState(() => loading = false);
    }
  }

  Future<void> adjustStock(String stockId, int change, String action) async {
    try {
      // update stock
      await supabase.rpc('adjust_stock', params: {
        'p_stock_id': stockId,
        'p_change': change,
      });

      // record log
      await supabase.from('inventory_log').insert({
        'stock_id': stockId,
        'action': action,
        'quantity': change.abs(),
      });

      fetchStocks(); // refresh UI
    } catch (e) {
      print("Error adjusting stock: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Manager"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: "Inventory Logs",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryLogPage()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : stocks.isEmpty
          ? const Center(child: Text("No stock records found"))
          : ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          final item = stock['item'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: item['image_path'] != null
                  ? Image.network(item['image_path'],
                  width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.inventory),
              title: Text(item['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category: ${stock['category']}"),
                  Text("Location: ${stock['location']}"),
                  Text("Quantity: ${stock['stock_quantity']}"),
                  Text("Price: RM ${item['price']}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () => adjustStock(
                        stock['stock_id'], -1, 'issued'),
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.add, color: Colors.green),
                    onPressed: () => adjustStock(
                        stock['stock_id'], 1, 'received'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}