// File generated or configured for Firebase
// Replace with your real project configuration using `flutterfire configure`
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Placeholder configurations - populate with your Firebase Project ID
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForLabTestWeb12345678',
    appId: '1:1234567890:web:abcdef12345678',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    authDomain: 'net4207-stock-inventory.firebaseapp.com',
    storageBucket: 'net4207-stock-inventory.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForLabTestAndr12345',
    appId: '1:1234567890:android:abcdef12345678',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    storageBucket: 'net4207-stock-inventory.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForLabTestiOS123456',
    appId: '1:1234567890:ios:abcdef12345678',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    storageBucket: 'net4207-stock-inventory.appspot.com',
    iosBundleId: 'com.example.stockInventoryApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderApiKeyForLabTestWin12345',
    appId: '1:1234567890:web:abcdef12345678',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    authDomain: 'net4207-stock-inventory.firebaseapp.com',
    storageBucket: 'net4207-stock-inventory.appspot.com',
  );
}
