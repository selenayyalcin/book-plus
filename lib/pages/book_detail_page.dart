import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailPage extends StatefulWidget {
  final String author;
  final String country;
  final String imageLink;
  final String language;
  final String link;
  final int pages;
  final String title;
  final int year;

  const BookDetailPage({
    Key? key,
    required this.author,
    required this.country,
    required this.imageLink,
    required this.language,
    required this.link,
    required this.pages,
    required this.title,
    required this.year,
  }) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late User? _user;
  late CollectionReference _userReadBooksCollection;
  late CollectionReference _userWantToReadBooksCollection;

  bool addedToRead = false;
  bool addedToWantToRead = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userReadBooksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('read_books');
    _userWantToReadBooksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('want_to_read_books');

    // Check if the book is already added to the collections
    _userReadBooksCollection.doc(widget.title).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          addedToRead = true;
        });
      }
    });

    _userWantToReadBooksCollection.doc(widget.title).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          addedToWantToRead = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(widget.imageLink),
            const SizedBox(height: 20),
            Text(
              'Title: ${widget.title}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Author: ${widget.author}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Country: ${widget.country}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Language: ${widget.language}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Pages: ${widget.pages}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Year: ${widget.year}',
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: addedToRead
                      ? () => _removeFromCollection('read_books', widget.title)
                      : () => _addToCollection('read_books', widget.title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: addedToRead ? Colors.red : null,
                  ),
                  child: Text(
                    addedToRead ? 'Remove from List' : 'What I Read',
                    style: TextStyle(
                      color: addedToRead ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: addedToWantToRead
                      ? () => _removeFromCollection(
                          'want_to_read_books', widget.title)
                      : () =>
                          _addToCollection('want_to_read_books', widget.title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: addedToWantToRead ? Colors.red : null,
                  ),
                  child: Text(
                    addedToWantToRead ? 'Remove from List' : 'Want to Read',
                    style: TextStyle(
                      color: addedToWantToRead ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addToCollection(String collectionName, String bookTitle) {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection(collectionName);
    collection.doc(bookTitle).set({
      'author': widget.author,
      'country': widget.country,
      'imageLink': widget.imageLink,
      'language': widget.language,
      'link': widget.link,
      'pages': widget.pages,
      'year': widget.year,
    }).then((value) {
      setState(() {
        if (collectionName == 'read_books') {
          addedToRead = true;
        } else {
          addedToWantToRead = true;
        }
      });
    });
  }

  void _removeFromCollection(String collectionName, String bookTitle) {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection(collectionName);
    collection.doc(bookTitle).delete().then((value) {
      setState(() {
        if (collectionName == 'read_books') {
          addedToRead = false;
        } else {
          addedToWantToRead = false;
        }
      });
    });
  }
}
