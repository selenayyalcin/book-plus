import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_page.dart';
import 'review_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key? key});

  Future<List<DocumentSnapshot>> getUserBooks(
      String userId, String collection) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .get();
    return querySnapshot.docs;
  }

  List<DocumentSnapshot> generateRecommendations(
      List<DocumentSnapshot> userBooks, List<DocumentSnapshot> allBooks) {
    List<DocumentSnapshot> recommendations = [];
    Set userAuthors = userBooks.map((book) => book['author']).toSet();

    for (var book in allBooks) {
      if (userAuthors.contains(book['author']) && !userBooks.contains(book)) {
        recommendations.add(book);
      }
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
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

          if (currentUser == null) {
            return const Center(
              child: Text('Please log in to see personalized recommendations.'),
            );
          }

          return FutureBuilder<List<List<DocumentSnapshot>>>(
            future: Future.wait([
              getUserBooks(currentUser.uid, 'read_books'),
              getUserBooks(currentUser.uid, 'want_to_read_books'),
            ]),
            builder: (context, userBooksSnapshot) {
              if (!userBooksSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<DocumentSnapshot> readBooks = userBooksSnapshot.data![0];
              List<DocumentSnapshot> wantToReadBooks =
                  userBooksSnapshot.data![1];
              List<DocumentSnapshot> allUserBooks = [
                ...readBooks,
                ...wantToReadBooks
              ];
              List<DocumentSnapshot> allBooks = snapshot.data!.docs;
              List<DocumentSnapshot> recommendedBooks =
                  generateRecommendations(allUserBooks, allBooks);

              return ListView(
                children: [
                  if (recommendedBooks.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'For You',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendedBooks.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot book = recommendedBooks[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      child: Image.asset(book['imageLink']),
                                    ),
                                    Text(book['title']),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'All Books',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                        trailing: IconButton(
                          icon: Icon(Icons.rate_review),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewPage(
                                  book: book,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 1),
    );
  }
}
