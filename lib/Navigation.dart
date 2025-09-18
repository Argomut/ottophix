import 'package:flutter/material.dart';
import 'package:ottophix/Account.dart';
import 'package:ottophix/Home.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    Home(),
    Center(child: Text('Search Page')),
    Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index){
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Completed',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',)
        ],
      ),
    );
  }
}
