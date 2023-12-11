import 'package:flutter/material.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    AssetImage('assets/images/profile_picture.jpg'),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Followers',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '220',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Following',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '50',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Books I Have Read',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(45, 115, 109, 1),
                ),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  ListTile(
                    title: Text('Midnight Library, Matt Haig'),
                    subtitle: Text('Comment: Great!'),
                  ),
                  ListTile(
                    title: Text('Franny and Zooey, J.D. Salinger'),
                    subtitle: Text('Comment: Meaningful and nice fiction.'),
                  ),
                  ListTile(
                    title: Text('The Survivors, Alex Schulman'),
                    subtitle: Text('Comment: Loved this book!'),
                  ),
                  ListTile(
                    title: Text('Man\'s Search For Meaning, Viktor E. Frankl'),
                    subtitle: Text(
                        'Comment: Everyone should read this book at least once in their life time.'),
                  ),
                  ListTile(
                    title: Text('The Trial, Franz Kafka'),
                    subtitle: Text(
                        'Comment: In love with every book of Franz Kafka.'),
                  ),
                  ListTile(
                    title: Text('America, Franz Kafka'),
                    subtitle: Text(
                        'Comment: I have read this book in one day. It tells a lot of things about capitalism and the new world design. I think people can understand a lot things from this book.'),
                  ),
                ],
              ),
            ],
          ),
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
        currentIndex: 3,
        selectedItemColor: const Color.fromRGBO(45, 115, 109, 1),
        unselectedItemColor: const Color.fromARGB(255, 126, 122, 122),
        showUnselectedLabels: true,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/discover');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/search');
          } else if (index == 3) {}
        },
      ),
    );
  }
}
