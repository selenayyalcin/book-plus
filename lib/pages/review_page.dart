import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                      // Yorumu Firestore'a kaydet
                      await FirebaseFirestore.instance
                          .collection('reviews')
                          .add({
                        'userId': user.uid, // Kullanıcının UID'si
                        'userName': user.displayName, // Kullanıcının adı
                        'bookId': widget
                            .book.id, // Kitabın Firestore belge kimliği (id)
                        'bookTitle': widget.book['title'], // Kitabın başlığı
                        'bookAuthor': widget.book['author'], // Kitabın yazarı
                        'bookImage': widget.book['imageLink'], // Kitabın resmi
                        'review':
                            _reviewController.text, // Kullanıcının incelemesi
                        'timestamp': Timestamp.now(), // Yorumun tarih ve saati
                      });

                      Navigator.pop(context); // Önceki sayfaya geri dön
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
}
