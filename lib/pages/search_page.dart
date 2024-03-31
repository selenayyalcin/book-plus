import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_plus/pages/book_detail_page.dart';
import 'package:path/path.dart' as Path;
import 'package:book_plus/database_helper.dart';
import 'package:book_plus/bottom_navigation_bar_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> searchedBooks = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadRecentBooks();
  }

  Future<void> _loadRecentBooks() async {
    List<Map<String, dynamic>> recentBooks =
        await DatabaseHelper.instance.getRecentBooks();
    setState(() {
      searchedBooks = recentBooks;
    });
  }

  Future<void> searchBooks(String searchTerm) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: searchTerm)
        .get();

    if (querySnapshot.docs.isEmpty) {
      searchTerm = searchTerm.toLowerCase();

      querySnapshot =
          await FirebaseFirestore.instance.collection('books').get();

      List<QueryDocumentSnapshot> foundBooks = querySnapshot.docs
          .where((book) =>
              book['title'].toString().toLowerCase().contains(searchTerm))
          .toList();

      if (foundBooks.isNotEmpty) {
        QueryDocumentSnapshot firstBook = foundBooks.first;

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(
                author: firstBook['author'],
                country: firstBook['country'],
                imageLink: firstBook['imageLink'],
                language: firstBook['language'],
                link: firstBook['link'],
                pages: firstBook['pages'],
                title: firstBook['title'],
                year: firstBook['year'],
              ),
            ));

        await DatabaseHelper.instance.insertBook({
          'title': firstBook['title'],
          'author': firstBook['author'],
          'imageLink': firstBook['imageLink'],
        });

        _loadRecentBooks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book you are looking for haven\'t found.'),
          ),
        );
      }
    } else {
      QueryDocumentSnapshot firstBook = querySnapshot.docs.first;
      String title = firstBook['title'];

      bool isBookInRecent = searchedBooks.any((book) => book['title'] == title);

      if (!isBookInRecent) {
        setState(() {
          searchedBooks.insert(0, {
            'title': title,
            'author': firstBook['author'],
            'imageLink': firstBook['imageLink'],
          });
        });

        await DatabaseHelper.instance.insertBook({
          'title': title,
          'author': firstBook['author'],
          'imageLink': firstBook['imageLink'],
        });

        _loadRecentBooks();
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailPage(
            author: firstBook['author'],
            country: firstBook['country'],
            imageLink: firstBook['imageLink'],
            language: firstBook['language'],
            link: firstBook['link'],
            pages: firstBook['pages'],
            title: firstBook['title'],
            year: firstBook['year'],
          ),
        ),
      );
    }
  }

  Future<void> clearHistory() async {
    await DatabaseHelper.instance.clearHistory();
    _loadRecentBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'What do you want to search?',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    searchBooks(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(45, 115, 109, 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recently Searched Books',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(45, 115, 109, 1),
                        ),
                      ),
                      const SizedBox(width: 35),
                      TextButton(
                        onPressed: clearHistory,
                        child: const Text(
                          'Clear History',
                          style:
                              TextStyle(color: Color.fromRGBO(45, 115, 109, 1)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: searchedBooks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 200,
                                width: 150,
                                child: Image.asset(
                                  searchedBooks[index]['imageLink'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(searchedBooks[index]['title']),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'English Books',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(45, 115, 109, 1),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('books')
                          .where('language', isEqualTo: 'English')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot book = snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 150,
                                    child: Image.asset(
                                      book['imageLink'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    book['title'],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 2),
    );
  }
}
