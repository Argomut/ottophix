import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("SliverList Example"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              collapsedHeight: 80,
              expandedHeight: 80, // Adjust the height for your needs
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.filter_list, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  // Build each list item
                  return ListTile(
                    title: Text('Item #$index'),
                  );
                },
                childCount: 100, // Number of items in the list
              ),
            ),
          ],
        ),
    );
  }
}
