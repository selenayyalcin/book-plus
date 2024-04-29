import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:book_plus/pages/home_page.dart';
import 'package:book_plus/pages/discover_page.dart';
import 'package:book_plus/pages/search_page.dart';
import 'package:book_plus/pages/my_profile_page.dart';
import 'package:book_plus/pages/login_page/Screens/Welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
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
