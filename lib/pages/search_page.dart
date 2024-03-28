// search_page.dart
import 'package:book_plus/pages/book_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late List<QueryDocumentSnapshot> searchedBooks;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    searchedBooks = [];
  }

  Future<void> searchBooks(String searchTerm) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: searchTerm)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot firstBook = querySnapshot.docs.first;
      // ignore: use_build_context_synchronously
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

      // Son aranan kitapları güncelle
      if (!searchedBooks.contains(firstBook)) {
        setState(() {
          if (searchedBooks.length >= 10) {
            searchedBooks.removeAt(0);
          }
          searchedBooks.add(firstBook);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book you are looking for havent found.')),
      );
    }
  }

  Future<void> addToMyBooks(QueryDocumentSnapshot bookSnapshot) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserEmail);

    final userDoc = await userRef.get();
    List<dynamic> myBooks = userDoc['myBooks'] ?? [];

    if (!myBooks.contains(bookSnapshot.id)) {
      myBooks.add(bookSnapshot.id);
      await userRef.update({'myBooks': myBooks});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book added to your list.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book is already in your list.')),
      );
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
            const Text(
              'Recently Searched Book',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(45, 115, 109, 1),
              ),
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
                          onPressed: () {
                            addToMyBooks(searchedBooks[index]);
                          },
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: const Color.fromRGBO(45, 115, 109, 1),
        unselectedItemColor: const Color.fromARGB(255, 126, 122, 122),
        showUnselectedLabels: true,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/discover');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
