import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No posts found.'),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          return _buildPostItem(post);
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
        bottomNavigationBar:
            const BottomNavigationBarController(initialIndex: 0));
  }

  Widget _buildPostItem(DocumentSnapshot post) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        height: 200, // Post yüksekliği
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap Resmi
            Container(
              height: 180, // Resim yüksekliği (Post yüksekliğinden 20 eksik)
              width: 140, // Resim genişliği
              margin: const EdgeInsets.only(right: 16),
              child: _buildBookImage(post['bookImage']),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username
                  Text(
                    post['userName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Kitap Adı
                  Text(
                    post['bookTitle'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Kitap Yorumu
                  Text(
                    post['review'],
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Tarih
                  Text(
                    formatDate(post['timestamp'],
                        dateFormat: 'dd/MM/yyyy HH:mm'),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    // Implement like functionality
                  },
                  icon: Icon(Icons.thumb_up),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    // Implement comment functionality
                  },
                  icon: Icon(Icons.comment),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage(String imagePath) {
    return SizedBox(
      width: 100, // Resmin genişliği
      height: 150, // Resmin yüksekliği
      child: Image.asset(
        imagePath,
        width: 100, // Resmin genişliği
        height: 150, // Resmin yüksekliği
        fit: BoxFit.contain, // Resmin boyutunu ayarlamak için kullanılabilir
      ),
    );
  }
}
