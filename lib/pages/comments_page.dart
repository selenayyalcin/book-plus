import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatelessWidget {
  final DocumentReference postRef;

  const CommentsPage(this.postRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: postRef.snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No post data available.'),
                  );
                } else {
                  final post = snapshot.data!;
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['bookTitle'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(post['review']),
                            const SizedBox(height: 4),
                            Text(
                              'By: ${post['userName']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(post['timestamp'],
                                  dateFormat: 'dd/MM/yyyy HH:mm'),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .doc(postRef.id)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No comments yet.'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final comment = snapshot.data!.docs[index];
                        return SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['comment'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'By: ${comment['userName']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDate(comment['timestamp'],
                                            dateFormat: 'dd/MM/yyyy HH:mm'),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      StreamBuilder(
                                        stream: _getCommentLikesStream(
                                            comment.reference),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else {
                                            bool isLiked =
                                                snapshot.data!.docs.isNotEmpty;

                                            return IconButton(
                                              onPressed: () {
                                                _likeComment(
                                                    comment.reference, isLiked);
                                              },
                                              icon: Icon(
                                                Icons.thumb_up,
                                                color:
                                                    isLiked ? Colors.red : null,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getCommentLikesStream(DocumentReference commentRef) {
    return commentRef.collection('commentLikes').snapshots();
  }

  void _likeComment(DocumentReference commentRef, bool isLiked) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    CollectionReference userLikesCollection =
        commentRef.collection('commentLikes');

    if (isLiked) {
      userLikesCollection
          .where('userId', isEqualTo: currentUser.uid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } else {
      userLikesCollection.add({'userId': currentUser.uid});
    }
  }
}
