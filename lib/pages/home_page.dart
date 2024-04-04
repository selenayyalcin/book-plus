import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

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
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No reviews found.'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final review = snapshot.data!.docs[index];
                        return _buildReviewItem(review);
                      },
                    );
                  }
                },
              ),
            ),
            Text(
              "Logged in as: ${currentUser.email!}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 0),
    );
  }

  Widget _buildReviewItem(DocumentSnapshot review) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('books')
          .doc(review['bookId'])
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> bookSnapshot) {
        if (bookSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
          return Text('Book not found');
        } else {
          // Kitap belgesini alın
          var bookData = bookSnapshot.data!.data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(bookData['imageLink']),
              ),
              title: Text(review['userName']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review['review']),
                  Text(
                    formatDate(review['timestamp'],
                        dateFormat: 'dd/MM/yyyy HH:mm'),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
