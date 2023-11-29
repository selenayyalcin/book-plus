import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/discover_page.dart';
import 'pages/search_page.dart';
import 'pages/my_profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      routes: {
        '/discover': (context) => const DiscoverPage(),
        '/search': (context) => const SearchPage(),
        '/profile': (context) => const MyProfilePage(),
      },
    );
  }
}
