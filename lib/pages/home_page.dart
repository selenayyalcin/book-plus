import 'package:book_plus/components/wall_post.dart';
import 'package:book_plus/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  //post message
  void postMessage() {
    //only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // store  in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
  }

  //clear the textfield
  void clearInput() {
    textController.clear();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/discover');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/search');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book+'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        actions: [
          //sign out button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
          child: Column(
        children: [
          //continue reading
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Continue Reading',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                'https://img.kitapyurdu.com/v1/getImage/fn:11503783/wh:true/miw:200/mih:200',
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    'Hayatta Kalanlar',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Alex Schulman',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  const SizedBox(
                                    width: 200,
                                    height: 20,
                                    child: LinearProgressIndicator(
                                      value: 0.4,
                                      backgroundColor: Colors.grey,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromRGBO(45, 115, 109, 1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            45, 115, 109, 1)),
                                    child: const Text('DID YOU FINISH?',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //the wall
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy(
                    "TimeStamp",
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error:${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),

          //post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                //textfield
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Write something on the wall...',
                    ),
                    obscureText: false,
                  ),
                ),
                //post button
                IconButton(
                    onPressed: () {
                      postMessage();
                      clearInput();
                    },
                    icon: const Icon(Icons.arrow_circle_up))
              ],
            ),
          ),

          //logged in as
          Text(
            "Logged in as: ${currentUser.email!}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(
            height: 20,
          )
        ],
      )),
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
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(45, 115, 109, 1),
        unselectedItemColor: const Color.fromARGB(255, 126, 122, 122),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
