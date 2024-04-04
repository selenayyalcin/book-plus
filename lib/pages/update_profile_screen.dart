import 'package:book_plus/bottom_navigation_bar_controller.dart';
import 'package:book_plus/pages/my_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final String username = userData['username'];
                  final String email = userData['email'];

                  _usernameController.text = username;
                  _emailController.text = email;

                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
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
                            labelText: 'Full Name',
                            prefixIcon: Icon(LineAwesomeIcons.user),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
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
                            labelText: 'E-mail',
                            prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
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
                            labelText: 'Password',
                            prefixIcon: Icon(LineAwesomeIcons.fingerprint),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _updateProfile(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 185, 214, 212),
                              side: BorderSide.none,
                              shape: StadiumBorder(),
                            ),
                            child: Text(
                              'Save',
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

  void _updateProfile(BuildContext context) async {
    final String newUsername = _usernameController.text.trim();
    final String newEmail = _emailController.text.trim();
    final String newPassword = _passwordController.text.trim();

    if (newUsername.isNotEmpty && newEmail.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;

      try {
        // Update user's email if it has changed
        if (newEmail != currentUser!.email) {
          await currentUser.updateEmail(newEmail);
        }

        // Update user's password if it has changed
        if (newPassword.isNotEmpty) {
          await currentUser.updatePassword(newPassword);
        }

        // Update user's display name (username)
        await currentUser.updateProfile(displayName: newUsername);

        // Update user's data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'username': newUsername,
          'email': newEmail,
        });

        // Show success message and navigate back to profile page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully.'),
          ),
        );
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        // Show error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      }
    } else {
      // Show error message if username or email is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username and email cannot be empty.'),
        ),
      );
    }
  }
}
