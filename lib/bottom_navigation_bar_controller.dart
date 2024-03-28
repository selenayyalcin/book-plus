import 'package:flutter/material.dart';

class BottomNavigationBarController extends StatefulWidget {
  final int initialIndex;
  const BottomNavigationBarController({super.key, required this.initialIndex});

  @override
  _BottomNavigationBarControllerState createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/discover');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/search');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Discover',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'My Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromRGBO(45, 115, 109, 1),
      unselectedItemColor: const Color.fromARGB(255, 126, 122, 122),
      showUnselectedLabels: true,
      onTap: _onItemTapped,
    );
  }
}
