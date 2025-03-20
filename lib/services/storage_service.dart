// File: lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a single image and return the download URL
  Future<String> uploadImage(File imageFile, String folder) async {
    // Create a unique filename
    final String fileName = '${const Uuid().v4()}.jpg';

    // Create a reference to the file location
    final Reference ref = _storage.ref().child('$folder/$fileName');

    // Upload the file
    final UploadTask uploadTask = ref.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    final TaskSnapshot taskSnapshot = await uploadTask;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // Upload multiple images and return a list of download URLs
  Future<List<String>> uploadImages(List<XFile> images, String folder) async {
    List<String> imageUrls = [];

    for (var image in images) {
      final File file = File(image.path);
      final String url = await uploadImage(file, folder);
      imageUrls.add(url);
    }

    return imageUrls;
  }

  // Delete an image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract the path from the URL
      final Reference ref = _storage.refFromURL(imageUrl);

      // Delete the file
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      throw e;
    }
  }
}
