import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:book_plus/pages/comments_page.dart';
import 'package:book_plus/pages/user_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final String likesCollection = 'likes';
  TextEditingController _commentController = TextEditingController();
  List<String> recommendedUserIds = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/welcome');
  }

  Stream<List<String>> getFollowingUserIdsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<List<String>> getUserFollowing(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('following')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getMutualFollowings(
      String userId, List<String> followingIds) async {
    Set<String> mutualFollowings = {};

    for (String followingId in followingIds) {
      List<String> theirFollowings = await getUserFollowing(followingId);
      mutualFollowings.addAll(theirFollowings);
    }

    // Mevcut kullanıcının zaten takip ettiği kullanıcıları ve kendisini çıkar
    mutualFollowings.remove(userId);
    mutualFollowings.removeAll(followingIds);

    return mutualFollowings.toList();
  }

  void _loadRecommendations() async {
    List<String> followingIds = await getFollowingUserIdsStream().first;
    List<String> recommendations =
        await getMutualFollowings(currentUser.uid, followingIds);
    setState(() {
      recommendedUserIds = recommendations;
    });
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
              child: StreamBuilder<List<String>>(
                stream: getFollowingUserIdsStream(),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No posts found.'),
                    );
                  } else {
                    List<String> userIds = [currentUser.uid, ...snapshot.data!];

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .where('userId', whereIn: userIds)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!reviewSnapshot.hasData ||
                            reviewSnapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text('No posts found.'),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: reviewSnapshot.data!.docs.length +
                                (recommendedUserIds.isNotEmpty ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (recommendedUserIds.isNotEmpty && index == 0) {
                                return _buildRecommendationsSection();
                              }
                              final postIndex = recommendedUserIds.isNotEmpty
                                  ? index - 1
                                  : index;
                              final post = reviewSnapshot.data!.docs[postIndex];
                              return _buildPostItem(post);
                            },
                          );
                        }
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

  Widget _buildRecommendationsSection() {
    return FutureBuilder<List<String>>(
      future: getFollowingUserIdsStream().first.then(
          (followingIds) => getMutualFollowings(currentUser.uid, followingIds)),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No recommendations found.'),
          );
        } else {
          List<String> recommendedUserIds = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Recommended Profiles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedUserIds.length,
                  itemBuilder: (context, index) {
                    String userId = recommendedUserIds[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          var user = userSnapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailPage(
                                      userId: userId,
                                      username: user['username'],
                                      email: user['email'],
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        NetworkImage(user['profileImageUrl']),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(user['username']),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPostItem(DocumentSnapshot post) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              child: _buildBookImage(post['bookImage']),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['userName'],
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['bookTitle'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['review'],
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
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

                      return IconButton(
                        onPressed: () {
                          _likePost(post.reference, isLiked);
                        },
                        icon: Icon(
                          Icons.thumb_up,
                          color: isLiked ? Colors.red : null,
                          size: 20,
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
                  icon: Icon(Icons.comment, size: 20),
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
      width: 100,
      height: 150,
      child: Image.asset(
        imagePath,
        width: 100,
        height: 150,
        fit: BoxFit.contain,
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

  void _submitComment(DocumentReference postRef) async {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      List<String> badWords = await loadBadWords();

      if (_containsBadWords(commentText, badWords)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Warning'),
            content: Text('Your comment contains inappropriate language.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        CollectionReference commentsCollection = FirebaseFirestore.instance
            .collection('reviews')
            .doc(postRef.id)
            .collection('comments');

        commentsCollection.add({
          'userId': currentUser.uid,
          'userName': currentUser.displayName,
          'comment': commentText,
          'timestamp': Timestamp.now(),
        });

        _commentController.clear();
      }
      _commentController.clear();
    }
  }

  Future<List<String>> loadBadWords() async {
    String data = await rootBundle.loadString('assets/karaliste.json');
    List<dynamic> jsonList = json.decode(data);
    List<String> badWords = jsonList.cast<String>();
    return badWords;
  }

  bool _containsBadWords(String text, List<String> badWords) {
    String lowercaseText = text.toLowerCase();
    for (String word in badWords) {
      if (lowercaseText.contains(word)) {
        return true;
      }
    }
    return false;
  }
}
