// test/test_helper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

class TestHelper {
  static Future<void> setupFirebaseEmulators() async {
    // Initialize Firebase for testing
    await Firebase.initializeApp();

    // Connect to Firebase Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    // Connect to Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
}
