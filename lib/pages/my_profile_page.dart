import 'package:book_plus/pages/update_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        actions: [],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // final userData = snapshot.data!.data() as Map<String, dynamic>?;
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 130),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image(
                              image: AssetImage(
                                'assets/images/profile.jpg',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProfileScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                LineAwesomeIcons.alternate_pencil,
                                color: Color.fromARGB(255, 75, 74, 74),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      currentUser.email!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 158, 213, 209),
                          side: BorderSide.none,
                          shape: StadiumBorder(),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProfileScreen(),
                          ),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          } else {
            // Eğer veri yoksa, bir CircularProgressIndicator döndür
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 3),
    );
  }
}
