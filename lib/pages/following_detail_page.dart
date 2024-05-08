import 'package:book_plus/pages/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowingDetailPage extends StatelessWidget {
  final List<String> followings;

  const FollowingDetailPage({Key? key, required this.followings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: ListView.builder(
        itemCount: followings.length,
        itemBuilder: (context, index) {
          final followingId = followings[index];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(followingId)
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
              final followingUsername = snapshot.data!.get('username');
              return ListTile(
                title: Text(followingUsername),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(
                        userId: followingId,
                        username: followingUsername,
                        email: snapshot.data!.get('email'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
