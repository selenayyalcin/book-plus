import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:book_plus/pages/comments_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final String likesCollection = 'likes';
  TextEditingController _commentController = TextEditingController();

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
                StreamBuilder(
                  stream: _getUserLikesStream(post.reference),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      bool isLiked = snapshot.data!.docs.isNotEmpty;
                      int likeCount = snapshot.data!.docs.length;

                      return IconButton(
                        onPressed: () {
                          _likePost(post.reference, isLiked);
                        },
                        icon: Icon(
                          Icons.thumb_up,
                          color: isLiked ? Colors.red : null,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    _showCommentDialog(context, post.reference);
                  },
                  icon: Icon(Icons.comment),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(post.reference),
                      ),
                    );
                  },
                  child: Text('Show Comments'),
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

  Stream<QuerySnapshot> _getUserLikesStream(DocumentReference postRef) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection(likesCollection)
        .where('postId', isEqualTo: postRef.id)
        .snapshots();
  }

  void _likePost(DocumentReference postRef, bool isLiked) {
    CollectionReference userLikesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection(likesCollection);

    if (isLiked) {
      userLikesCollection
          .where('postId', isEqualTo: postRef.id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } else {
      userLikesCollection.add({'postId': postRef.id});
    }
  }

  void _showCommentDialog(BuildContext context, DocumentReference postRef) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: 'Enter your comment'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submitComment(postRef);
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitComment(DocumentReference postRef) {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      CollectionReference commentsCollection = FirebaseFirestore.instance
          .collection('reviews')
          .doc(postRef.id)
          .collection('comments'); // 'comments' koleksiyonu olarak ayarlanacak

      commentsCollection.add({
        'userId': currentUser.uid,
        'comment': commentText,
        'timestamp': Timestamp.now(),
      });

      _commentController.clear();
    }
  }
}
