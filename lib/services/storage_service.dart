// lib/services/storage_service.dart

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage storage;

  StorageService({FirebaseStorage? storage})
      : this.storage = storage ?? FirebaseStorage.instance;

  // Upload a single listing image
  Future<String> uploadListingImage(
      Uint8List imageData,
      String fileName,
      String listingId,
      ) async {
    try {
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = storage.ref().child('listings/$listingId/$uniqueFileName');

      UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw e;
    }
  }

  // Upload multiple listing images
  Future<List<String>> uploadMultipleListingImages(
      List<Uint8List> imagesData,
      List<String> fileNames,
      String listingId,
      ) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < imagesData.length; i++) {
        String url = await uploadListingImage(
          imagesData[i],
          fileNames[i],
          listingId,
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw e;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(
      Uint8List imageData,
      String fileName,
      String userId,
      ) async {
    try {
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = storage.ref().child('users/$userId/$uniqueFileName');

      UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw e;
    }
  }

  // Delete an image
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw e;
    }
  }
}
