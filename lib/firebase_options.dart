// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAm33lsrKszrFBSvZxLuK6lhmlNTxzEgBY',
    appId: '1:594805785365:web:4c9bc2f31fbfda03425f1c',
    messagingSenderId: '594805785365',
    projectId: 'bookplusfirebaseauth',
    authDomain: 'bookplusfirebaseauth.firebaseapp.com',
    databaseURL: 'https://bookplusfirebaseauth-default-rtdb.firebaseio.com',
    storageBucket: 'bookplusfirebaseauth.appspot.com',
    measurementId: 'G-XWZ0WH8X5F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAz8YMnJFPpYiD9Oq8iWEsqTyl0LL9X1qk',
    appId: '1:594805785365:android:5b4c66aa05aeb84c425f1c',
    messagingSenderId: '594805785365',
    projectId: 'bookplusfirebaseauth',
    databaseURL: 'https://bookplusfirebaseauth-default-rtdb.firebaseio.com',
    storageBucket: 'bookplusfirebaseauth.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOcFfZdZbSkzrQGI22mx9bb6pqYKcjPlU',
    appId: '1:594805785365:ios:d8957aa053c51f23425f1c',
    messagingSenderId: '594805785365',
    projectId: 'bookplusfirebaseauth',
    databaseURL: 'https://bookplusfirebaseauth-default-rtdb.firebaseio.com',
    storageBucket: 'bookplusfirebaseauth.appspot.com',
    iosBundleId: 'com.example.bookPlus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDOcFfZdZbSkzrQGI22mx9bb6pqYKcjPlU',
    appId: '1:594805785365:ios:185bcb9d569d0d09425f1c',
    messagingSenderId: '594805785365',
    projectId: 'bookplusfirebaseauth',
    databaseURL: 'https://bookplusfirebaseauth-default-rtdb.firebaseio.com',
    storageBucket: 'bookplusfirebaseauth.appspot.com',
    iosBundleId: 'com.example.bookPlus.RunnerTests',
  );
}
