// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Convert Firebase User to our custom UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      neighborhood: '',  // This would be fetched from Firestore
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
  }

  // Auth state changes stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Update last active timestamp
      if (user != null) {
        await _databaseService.updateUserData(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          neighborhood: '',  // This would be fetched from Firestore
        );
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phoneNumber,
      String neighborhood,
      ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Update display name
      await user?.updateDisplayName(name);

      // Create a new user document in Firestore
      if (user != null) {
        await _databaseService.updateUserData(
          uid: user.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          neighborhood: neighborhood,
        );
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      return;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      return;
    }
  }

  // Get current user
  UserModel? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // Get current user ID
  String? get currentUserId {
    return _auth.currentUser?.uid;
  }
}
