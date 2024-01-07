import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/discover_page.dart';
import 'pages/search_page.dart';
import 'pages/my_profile_page.dart';
import 'pages/login_page/Screens/Welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/discover': (context) => const DiscoverPage(),
        '/search': (context) => const SearchPage(),
        '/profile': (context) => const MyProfilePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
