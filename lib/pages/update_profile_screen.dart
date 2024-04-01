import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/pages/my_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyProfilePage()),
          ),
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Stack(children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image(
                          image: AssetImage('assets/images/profile.jpg'))),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Color.fromARGB(255, 149, 180, 178)),
                    child: const Icon(
                      LineAwesomeIcons.camera,
                      color: Color.fromARGB(255, 75, 74, 74),
                      size: 20,
                    ),
                  ),
                )
              ]),
              const SizedBox(height: 50),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    return CircularProgressIndicator();
                  }

                  return Form(
                    child: Column(
                      children: [
                        TextFormField(
                          // initialValue: 'Full Name',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            floatingLabelStyle: TextStyle(
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 44, 96, 92),
                              ),
                            ),
                            label: Text('Full Name'),
                            prefixIcon: Icon(LineAwesomeIcons.user),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          initialValue: currentUser.email,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            floatingLabelStyle: TextStyle(
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 44, 96, 92),
                              ),
                            ),
                            label: Text('E-mail'),
                            prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            floatingLabelStyle: TextStyle(
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 44, 96, 92),
                              ),
                            ),
                            label: Text('Password'),
                            prefixIcon: Icon(LineAwesomeIcons.fingerprint),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyProfilePage(),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 185, 214, 212),
                              side: BorderSide.none,
                              shape: StadiumBorder(),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarController(initialIndex: 3),
    );
  }
}
