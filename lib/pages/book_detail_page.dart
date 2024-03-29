import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BookDetailPage extends StatelessWidget {
  final String author;
  final String country;
  final String imageLink;
  final String language;
  final String link;
  final int pages;
  final String title;
  final int year;

  const BookDetailPage({
    super.key,
    required this.author,
    required this.country,
    required this.imageLink,
    required this.language,
    required this.link,
    required this.pages,
    required this.title,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imageLink),
            const SizedBox(height: 20),
            Text(
              'Title: $title',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Author: $author',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Country: $country',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Language: $language',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Pages: $pages',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Year: $year',
              style: const TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back',
                  style: TextStyle(color: Color.fromRGBO(45, 115, 109, 1))),
            ),
          ],
        ),
      ),
    );
  }
}
