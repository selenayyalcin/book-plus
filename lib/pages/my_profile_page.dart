import 'dart:io';

import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/pages/comments_page.dart';
import 'package:book_plus/pages/followers_detail_page.dart';
import 'package:book_plus/pages/following_detail_page.dart';
import 'package:book_plus/pages/update_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  bool isFollowing = false;
  int followersCount = 0;
  int followingCount = 0;
  List<String> followers = [];
  List<String> followings = [];
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    updateFollowCounts();
  }

  Future<void> updateFollowCounts() async {
    final followersSnapshot = await usersCollection
        .doc(currentUser.uid)
        .collection('followers')
        .get();
    setState(() {
      followers = followersSnapshot.docs.map((doc) => doc.id).toList();
      followersCount = followers.length;
    });

    final followingSnapshot = await usersCollection
        .doc(currentUser.uid)
        .collection('following')
        .get();
    setState(() {
      followings = followingSnapshot.docs.map((doc) => doc.id).toList();
      followingCount = followings.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final String username = userData['username'];
              final String email = userData['email'];
              final String? profileImageUrl = userData['profileImageUrl'];

              return Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: _imagePath != null
                                ? Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : profileImageUrl != null
                                    ? Image.network(
                                        profileImageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/blank-profile-picture.jpg',
                                        fit: BoxFit.cover,
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
                              color: const Color.fromARGB(255, 149, 180, 178),
                            ),
                            child: IconButton(
                              onPressed: _selectImage,
                              icon: const Icon(
                                LineAwesomeIcons.camera,
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
                      username,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FollowerDetailPage(followers: followers),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const Text(
                                'Followers',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$followersCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FollowingDetailPage(followings: followings),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const Text(
                                'Following',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$followingCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBookList('read_books', 'Books I Read'),
                          const SizedBox(height: 10),
                          _buildBookList(
                              'want_to_read_books', 'Books I Want to Read'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),
                    _buildUserReviews(),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 3),
    );
  }

  Widget _buildBookList(String collectionName, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(45, 115, 109, 1),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .collection(collectionName)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  String bookImageLink = document['imageLink'];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 100,
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 150,
                            child: Image.asset(
                              bookImageLink,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserReviews() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> reviewSnapshot) {
        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
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
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviewSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post = reviewSnapshot.data!.docs[index];
              // Sadece ilk öğe için başlık ekle
              Widget listItem = _buildPostItem(post);
              if (index == 0) {
                listItem = Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'My Reviews',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(45, 115, 109, 1),
                        ),
                        textAlign: TextAlign.start, // Başlığı sola yasla
                      ),
                    ),
                    listItem,
                  ],
                );
              }
              return listItem;
            },
          );
        }
      },
    );
  }

  Widget _buildPostItem(DocumentSnapshot post) {
    return Card(
      margin: const EdgeInsets.all(4),
      child: Container(
        width: double.infinity,
        height: 170,
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              child: _buildBookImage(post['bookImage']),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    DateFormat('dd/MM/yyyy').format(post['timestamp'].toDate()),
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
                    _deletePost(post.reference);
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Moved "Show Comments" button here
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
        fit: BoxFit.contain,
      ),
    );
  }

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final String fileName = path.basename(file.path);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('User is not authenticated');
        return;
      }

      try {
        await FirebaseStorage.instance
            .ref('profile_photos/$fileName')
            .putFile(file);
        final String downloadUrl = await FirebaseStorage.instance
            .ref('profile_photos/$fileName')
            .getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'profileImageUrl': downloadUrl,
        }, SetOptions(merge: true));

        setState(() {
          _imagePath = pickedFile.path;
        });
      } catch (error) {
        print('Error uploading profile image: $error');
      }
    }
  }

  void _deletePost(DocumentReference postRef) {
    postRef.delete().then((value) => print('Post deleted successfully'));
  }
}
