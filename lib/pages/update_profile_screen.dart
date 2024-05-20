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
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          final userData = documentSnapshot.data() as Map<String, dynamic>;
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromRGBO(45, 115, 109, 1),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 50),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
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
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 44, 96, 92),
                              ),
                            ),
                            labelText: 'Full Name',
                            prefixIcon: const Icon(LineAwesomeIcons.user),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 44, 96, 92),
                              ),
                            ),
                            labelText: 'E-mail',
                            prefixIcon: const Icon(LineAwesomeIcons.envelope_1),
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
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 149, 180, 178),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 44, 96, 92),
                              ),
                            ),
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(LineAwesomeIcons.fingerprint),
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
                                  const Color.fromARGB(255, 185, 214, 212),
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
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
    );
  }

  void _updateProfile(BuildContext context) async {
    final String newUsername = _usernameController.text.trim();
    final String newEmail = _emailController.text.trim();
    final String newPassword = _passwordController.text.trim();

    if (newUsername.isNotEmpty && newEmail.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;

      try {
        if (newEmail != currentUser!.email) {
          await currentUser.updateEmail(newEmail);
        }

        if (newPassword.isNotEmpty) {
          await currentUser.updatePassword(newPassword);
        }

        await currentUser.updateProfile(displayName: newUsername);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'username': newUsername,
          'email': newEmail,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully.'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username and email cannot be empty.'),
        ),
      );
    }
  }
}
