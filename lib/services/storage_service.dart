import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Upload profile image
  Future<String> uploadProfileImage(File image) async {
    try {
      final userId = _auth.currentUser!.uid;
      final ref = _storage.ref().child('users/$userId/profile.jpg');

      await ref.putFile(image);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload listing image
  Future<String> uploadListingImage(File image) async {
    try {
      final userId = _auth.currentUser!.uid;
      final imageId = _uuid.v4();
      final ref = _storage.ref().child('listings/$userId/$imageId.jpg');

      await ref.putFile(image);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload listing image: $e');
    }
  }

  // Upload chat image
  Future<String> uploadChatImage(File image) async {
    try {
      final userId = _auth.currentUser!.uid;
      final imageId = _uuid.v4();
      final ref = _storage.ref().child('chats/$userId/$imageId.jpg');

      await ref.putFile(image);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  // Upload verification document
  Future<String> uploadVerificationDocument(File document) async {
    try {
      final userId = _auth.currentUser!.uid;
      final ref = _storage.ref().child('verification/$userId/document.jpg');

      await ref.putFile(document);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload verification document: $e');
    }
  }
}
