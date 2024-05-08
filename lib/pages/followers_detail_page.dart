import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowerDetailPage extends StatelessWidget {
  final List<String> followers;

  const FollowerDetailPage({Key? key, required this.followers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final followerId = followers[index];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(followerId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('Loading...'),
                );
              }
              if (snapshot.hasError) {
                return ListTile(
                  title: Text('Error: ${snapshot.error}'),
                );
              }
              final followerUsername = snapshot.data!.get('username');
              return ListTile(
                title: Text(followerUsername),
                onTap: () {
                  // navigate to the profile of the tapped follower
                },
              );
            },
          );
        },
      ),
    );
  }
}
