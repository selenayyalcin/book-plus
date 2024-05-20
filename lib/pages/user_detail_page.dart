import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  final String username;
  final String email;

  const UserDetailPage({
    required this.userId,
    required this.username,
    required this.email,
  });

  void followUser(
      BuildContext context, String otherUserId, bool isFollowing) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final CollectionReference followingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('following');
    final CollectionReference followersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .collection('followers');

    try {
      if (isFollowing) {
        await followingRef.doc(otherUserId).delete();
        await followersRef.doc(currentUser.uid).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You unfollowed the user.'),
          ),
        );
      } else {
        await followingRef.doc(otherUserId).set({
          'userId': otherUserId,
        });

        await followersRef.doc(currentUser.uid).set({
          'userId': currentUser.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You followed the user.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<int> getFollowerCount(String userId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getFollowingCount(String userId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('following')
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        if (data == null) {
                          return Text('User data not found');
                        }
                        final String photoUrl = data['profileImageUrl'] ?? '';
                        return CircleAvatar(
                          radius: 75,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : AssetImage(
                                      'assets/images/blank-profile-picture.jpg')
                                  as ImageProvider<Object>?,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<int>(
                    future: getFollowerCount(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final followerCount = snapshot.data ?? 0;
                      return Text('Followers: $followerCount');
                    },
                  ),
                  SizedBox(width: 20),
                  FutureBuilder<int>(
                    future: getFollowingCount(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final followingCount = snapshot.data ?? 0;
                      return Text('Following: $followingCount');
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('following')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  final isFollowing = snapshot.data?.exists ?? false;
                  return ElevatedButton(
                    onPressed: () {
                      followUser(context, userId, isFollowing);
                    },
                    child: Text(isFollowing ? 'Following' : 'Follow'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
