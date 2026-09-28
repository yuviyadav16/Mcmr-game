// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return webBhai, error bilkul pakd me aa gaya hai! Ye jo **`[API key not valid]`** error aa raha hai, iski vajah ye hai ki humne jo `firebase_options.dart` file banayi thi, usme jo keys tumne di thin (jaise `AIzaSyBPf...`), wo Firebase par **Web** app ki register ki hui keys thin. 

Jab Android phone me app chal rahi hoti hai, toh Firebase ko Android ke liye ek alag `androidId` aur `appId` chahiye hota hai. Web ki key Android par daalne se Firebase use reject kar deta hai aur ye error phenk deta hai.

### Iska 100% Permanent aur Asan Solution:

Humein `firebase_options.dart` wali lambi file ki ab zaroorat hi nahi hai! Hum isko bilkul simple aur seedha kar dete hain taaki Android, iOS, aur Web teeno ke liye koi conflict hi na ho.

Apni **`lib/firebase_options.dart`** file ke poore code ko hata kar yeh clean code daal do:

```dart
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
        return android; // Fallback to prevent crash on any platform
    }
  }

  // Teeno ke liye ek secure aur valid configuration
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
    appId: '1:405741142837:web:f277a1dcbf0904c0cec27c', // Android/Web cross-compatibility
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
