import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_plus/pages/book_detail_page.dart';
import 'package:book_plus/pages/user_detail_page.dart';
import 'package:book_plus/bottom_navigation_bar_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('recent_books')
          .get();

      setState(() {
        searchedBooks = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  void updateRecentBooks(String title, {bool isRecent = true}) {
    setState(() {
      if (isRecent) {
        searchedBooks.removeWhere((book) => book['title'] == title);
        searchedBooks.insert(0, {
          'title': title,
        });
      }
    });
  }

  Future<void> searchBooks(String searchTerm) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: searchTerm)
        .get();

    if (querySnapshot.docs.isEmpty) {
      searchTerm = searchTerm.toLowerCase();

      final allBooksSnapshot =
          await FirebaseFirestore.instance.collection('books').get();

      final foundBooks = allBooksSnapshot.docs.where((book) =>
          book['title'].toString().toLowerCase().contains(searchTerm));

      if (foundBooks.isNotEmpty) {
        final firstBook = foundBooks.first;

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

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('recent_books')
              .add({
            'title': firstBook['title'],
            'author': firstBook['author'],
            'imageLink': firstBook['imageLink'],
          });

          updateRecentBooks(firstBook['title']);
          _loadRecentBooks();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book hasn\'t found.'),
          ),
        );
      }
    } else {
      final firstBook = querySnapshot.docs.first;
      String title = firstBook['title'];

      updateRecentBooks(title, isRecent: false);

      bool isBookInRecent = searchedBooks.any((book) => book['title'] == title);

      if (!isBookInRecent) {
        setState(() {
          searchedBooks.insert(0, {
            'title': title,
            'author': firstBook['author'],
            'imageLink': firstBook['imageLink'],
          });
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('recent_books')
              .add({
            'title': title,
            'author': firstBook['author'],
            'imageLink': firstBook['imageLink'],
          });

          updateRecentBooks(title);
          _loadRecentBooks();
        }
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

  Future<void> searchUsers(String searchTerm) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: searchTerm)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final user = querySnapshot.docs.first;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailPage(
            userId: user.id,
            username: user['username'],
            email: user['email'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found.'),
        ),
      );
    }
  }

  Future<void> clearHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('recent_books')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      _loadRecentBooks();
    }
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
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    searchBooks(_searchController.text);
                    searchUsers(_searchController.text);
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
              child: ListView(
                children: [
                  Column(
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
                              style: TextStyle(
                                color: Color.fromRGBO(45, 115, 109, 1),
                              ),
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
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetailPage(
                                        author: searchedBooks[index]['author'],
                                        country: searchedBooks[index]
                                            ['country'],
                                        imageLink: searchedBooks[index]
                                            ['imageLink'],
                                        language: searchedBooks[index]
                                            ['language'],
                                        link: searchedBooks[index]['link'],
                                        pages: searchedBooks[index]['pages'],
                                        title: searchedBooks[index]['title'],
                                        year: searchedBooks[index]['year'],
                                      ),
                                    ),
                                  );
                                },
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                              child: InkWell(
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
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Old Books',
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
                          .where('year', isLessThan: 1900)
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
                              child: InkWell(
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
