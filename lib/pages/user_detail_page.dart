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
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    StreamBuilder<DocumentSnapshot>(
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
                          return const CircularProgressIndicator();
                        }
                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        if (data == null) {
                          return const Text('User data not found');
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
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
                  return const CircularProgressIndicator();
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
          ],
        ),
      ),
    );
  }
}
