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

  void followUser(BuildContext context, String otherUserId) async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                followUser(context, userId);
              },
              child: const Text('Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
