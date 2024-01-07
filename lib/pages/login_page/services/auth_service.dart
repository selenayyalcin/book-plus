import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;
  Future<void> signUp(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        _registerUser(email: email, password: password);
        navigator
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> signIn(BuildContext context,
      {required String email, required String password}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        //giriş başarılı
        Fluttertoast.showToast(
            msg: "Successfully logged in.", toastLength: Toast.LENGTH_LONG);

        navigator
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _registerUser(
      {required String email, required String password}) async {
    await userCollection.doc().set({
      "username": email.split('@')[0],
      "password": password,
      "bio": 'Empty bio..'
    });
  }
}
