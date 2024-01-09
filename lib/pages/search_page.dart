import 'package:book_plus/pages/book_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aranan kitap bulunamadı')),
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
                      hintText: 'Kitap İsmi',
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
                    'Ara',
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
              'Son Aranan Kitaplar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(45, 115, 109, 1),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              //height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchedBooks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        Image.asset(
                          searchedBooks[index]['imageLink'],
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
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
