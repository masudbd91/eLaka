// test/auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:elaka/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './test_helper.dart';

void main() {
  late AuthService authService;

  setUpAll(() async {
    // Set up Firebase emulators before all tests
    await TestHelper.setupFirebaseEmulators();
  });

  setUp(() {
    // Create a fresh instance of AuthService before each test
    authService = AuthService();
  });

  group('Authentication Tests', () {
    test('AuthService can be instantiated', () {
      expect(authService, isNotNull);
    });

    // Add more tests using real Firebase emulators
    // ...
  });
}

// // test/auth_service_test.dart
//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:elaka/services/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import './test_helper.dart';
//
// void main() {
//   late AuthService authService;
//
//   setUpAll(() async {
//     // Set up Firebase emulators before all tests
//     await TestHelper.setupFirebaseEmulators();
//   });
//
//   setUp(() {
//     // Create a fresh instance of AuthService before each test
//     authService = AuthService();
//   });
//
//   group('Authentication Tests', () {
//     test('AuthService can be instantiated', () {
//       expect(authService, isNotNull);
//     });
//
//     // Add more tests using real Firebase emulators
//     test('Sign in with invalid credentials fails', () async {
//       try {
//         await authService.signInWithEmailAndPassword(
//             'test@example.com', 'wrongpassword');
//         fail('Should have thrown an exception');
//       } catch (e) {
//         expect(e, isA<FirebaseAuthException>());
//       }
//     });
//
//     // More tests...
//   });
// }
