import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_plus/pages/book_detail_page.dart';
import 'package:path/path.dart' as Path;
import 'package:book_plus/database_helper.dart';

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

      setState(() {
        searchedBooks
            .removeWhere((book) => book['title'] == firstBook['title']);
        searchedBooks.insert(0, {
          'title': firstBook['title'],
          'author': firstBook['author'],
          'imageLink': firstBook['imageLink'],
        });
      });

      await DatabaseHelper.instance.insertBook({
        'title': firstBook['title'],
        'author': firstBook['author'],
        'imageLink': firstBook['imageLink'],
      });

      _loadRecentBooks();

      Navigator.push(
        context as BuildContext,
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
                      border: OutlineInputBorder(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Searched Books',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(45, 115, 109, 1),
                  ),
                ),
                TextButton(
                  onPressed: clearHistory,
                  child: const Text('Clear History'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
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
                          height: 250,
                          width: 150,
                          child: Image.asset(
                            searchedBooks[index]['imageLink'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Add to My List'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 2),
    );
  }
}
