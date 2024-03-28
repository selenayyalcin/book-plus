import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/components/wall_post.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  //post message
  void postMessage() {
    //only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // store  in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
  }

  //clear the textfield
  void clearInput() {
    textController.clear();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book+'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        actions: [
          //sign out button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
          child: Column(
        children: [
          //the wall
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy(
                    "TimeStamp",
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error:${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),

          //post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                //textfield
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Write something on the wall...',
                    ),
                    obscureText: false,
                  ),
                ),
                //post button
                IconButton(
                    onPressed: () {
                      postMessage();
                      clearInput();
                    },
                    icon: const Icon(Icons.arrow_circle_up))
              ],
            ),
          ),

          //logged in as
          Text(
            "Logged in as: ${currentUser.email!}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(
            height: 20,
          )
        ],
      )),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 0),
    );
  }
}
