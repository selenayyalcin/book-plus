import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ReviewPage extends StatefulWidget {
  final DocumentSnapshot book;

  const ReviewPage({Key? key, required this.book}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.book['title']}'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display book image, title, and author
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Image.asset(
                      widget.book['imageLink'],
                      height: 200,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                    Text(widget.book['title'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${widget.book['author']}',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Review text area
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  hintText: 'Add your review here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              // Save review button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // Kötü sözleri yükle
                      List<String> badWords = await loadBadWords();

                      // Kötü sözleri kontrol et
                      if (_containsBadWords(_reviewController.text, badWords)) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Warning'),
                            content: Text(
                                'Your review contains inappropriate language.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Yorumu Firestore'a kaydet
                        await FirebaseFirestore.instance
                            .collection('reviews')
                            .add({
                          'userId': user.uid,
                          'userName': user.displayName,
                          'bookId': widget.book.id,
                          'bookTitle': widget.book['title'],
                          'bookAuthor': widget.book['author'],
                          'bookImage': widget.book['imageLink'],
                          'review': _reviewController.text,
                          'timestamp': Timestamp.now(),
                        });
                        _reviewController.clear();
                        Navigator.pop(context);
                      }
                      _reviewController.clear();
                    } else {
                      // Kullanıcı oturum açmamışsa uyarı göster
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Authentication Error'),
                          content: Text('You are not signed in.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Save Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<List<String>> loadBadWords() async {
    // JSON dosyasını yükle
    String data = await rootBundle.loadString('assets/karaliste.json');

    // JSON'u listeye dönüştür
    List<dynamic> jsonList = json.decode(data);

    // Listeyi String'e dönüştür
    List<String> badWords = jsonList.cast<String>();

    return badWords;
  }

  bool _containsBadWords(String text, List<String> badWords) {
    // Metni küçük harfe çevir
    String lowercaseText = text.toLowerCase();

    // Her kötü söz için kontrol et
    for (String word in badWords) {
      if (lowercaseText.contains(word)) {
        return true;
      }
    }

    return false;
  }
}
