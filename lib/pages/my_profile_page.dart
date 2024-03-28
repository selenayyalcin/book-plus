import 'package:book_plus/components/text_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:book_plus/bottom_navigation_bar_controller.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey[100]),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          //save button
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    //update in firestore
    if (newValue.trim().isNotEmpty) {
      //only uppdate if there is something in the text
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

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
          //get user data
          if (snapshot.hasData) {
            // final userData = snapshot.data!.data() as Map<String, dynamic>?;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 40),
                //profile pic
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                  ),
                ),

                //user email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 24, 24, 24)),
                ),
                const SizedBox(height: 50),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Followers',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '0',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Following',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '0',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                //user details
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                //username
                MyTextBox(
                  text: currentUser.email!,
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                //bio
                MyTextBox(
                  text: 'empty bio',
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),
                const SizedBox(height: 50),

                // //user posts
                // Padding(
                //   padding: const EdgeInsets.only(left: 25.0),
                //   child: Text(
                //     'My Posts',
                //     style: TextStyle(color: Colors.grey[600]),
                //   ),
                // ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error${snapshot.error}'));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 3),
    );
  }
}
