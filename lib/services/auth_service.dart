import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last active timestamp
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastActive': DateTime.now().toIso8601String(),
      });

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phoneNumber,
      String neighborhood,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        neighborhood: neighborhood,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Verify user identity
  Future<void> verifyUserIdentity(File idDocument) async {
    try {
      // In a real app, you would upload the document to storage
      // and create a verification request in the database

      // For this example, we'll just update the user document
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'verificationRequested': true,
        'verificationRequestDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to submit verification: $e');
    }
  }

  // Get user data
  Future<UserModel> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Handle authentication exceptions
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Incorrect password.');
        case 'email-already-in-use':
          return Exception('This email is already registered.');
        case 'weak-password':
          return Exception('Password is too weak.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        default:
          return Exception('Authentication failed: ${e.message}');
      }
    }
    return Exception('Authentication failed: $e');
  }
}
