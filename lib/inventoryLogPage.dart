import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryLogPage extends StatefulWidget {
  const InventoryLogPage({super.key});

  @override
  State<InventoryLogPage> createState() => _InventoryLogPageState();
}

class _InventoryLogPageState extends State<InventoryLogPage> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final response = await supabase
          .from('inventory_log')
          .select(
          'log_id, action, quantity, created_at, stock(stock_id, item(name))')
          .order('created_at', ascending: false);

      setState(() {
        logs = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      print("Error fetching logs: $e");
      setState(() => loading = false);
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return "";
    final dateTime = DateTime.parse(dateTimeStr);
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Logs"),
        backgroundColor: Colors.blueGrey,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
          ? const Center(child: Text("No inventory logs found"))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final stock = log['stock'];
          final itemName = stock?['item']?['name'] ?? "Unknown Item";

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("Action: ${log['action']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Item: $itemName"),
                  Text("Quantity: ${log['quantity']}"),
                  Text("Time: ${formatDateTime(log['created_at'])}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}