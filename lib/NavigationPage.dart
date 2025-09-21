import 'package:flutter/material.dart';
import 'package:ottophix/AccountPage.dart';
import 'package:ottophix/HistoryPage.dart';
import 'package:ottophix/HomePage.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    HistoryPage(),
    AccountPage(),
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
