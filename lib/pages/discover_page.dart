import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_page.dart';
import 'package:book_plus/bottom_navigation_bar_controller.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot book = snapshot.data!.docs[index];
              return ListTile(
                leading: Image.asset(book['imageLink']),
                title: Text(book['title']),
                subtitle: Text(book['author']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailPage(
                        author: book['author'],
                        country: book['country'],
                        imageLink: book['imageLink'],
                        language: book['language'],
                        link: book['link'],
                        pages: book['pages'],
                        title: book['title'],
                        year: book['year'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 1),
    );
  }
}
