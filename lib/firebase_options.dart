// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBPfQi6kb9Px7Zl27KQYSehpdb1pLqfeg8',
    appId: '1:405741142837:web:f277a1dcbf0904c0cec27c',
    messagingSenderId: '405741142837',
    projectId: 'games-1cd64',
    authDomain: 'games-1cd64.firebaseapp.com',
    storageBucket: 'games-1cd64.firebasestorage.app',
    measurementId: 'G-36RVDPS6X3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPfQi6kb9Px7Zl27KQYSehpdb1pLqfeg8',
    appId: '1:405741142837:web:f277a1dcbf0904c0cec27c',
    messagingSenderId: '405741142837',
    projectId: 'games-1cd64',
    storageBucket: 'games-1cd64.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPfQi6kb9Px7Zl27KQYSehpdb1pLqfeg8',
    appId: '1:405741142837:web:f277a1dcbf0904c0cec27c',
    messagingSenderId: '405741142837',
    projectId: 'games-1cd64',
    storageBucket: 'games-1cd64.firebasestorage.app',
    iosBundleId: 'com.example.chai_and_chase',
  );
}
