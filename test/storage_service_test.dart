// test/storage_service_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:elaka/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockFirebaseStorage mockStorage;
  late StorageService storageService;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    storageService = StorageService(storage: mockStorage);
  });

  group('Image Upload Tests', () {
    test('Upload listing image', () async {
      // Create mock image data
      final Uint8List mockImageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Mock the upload process
      final String fileName = 'test_image.jpg';
      final String listingId = 'listing123';

      // Perform upload
      final downloadUrl = await storageService.uploadListingImage(
        mockImageData,
        fileName,
        listingId,
      );

      // Verify upload path and result
      expect(downloadUrl, isNotNull);
      expect(downloadUrl, contains('listings/$listingId'));
    });

    test('Upload profile image', () async {
      // Create mock image data
      final Uint8List mockImageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Mock the upload process
      final String fileName = 'profile_pic.jpg';
      final String userId = 'user123';

      // Perform upload
      final downloadUrl = await storageService.uploadProfileImage(
        mockImageData,
        fileName,
        userId,
      );

      // Verify upload path and result
      expect(downloadUrl, isNotNull);
      expect(downloadUrl, contains('users/$userId'));
    });
  });

  group('Image Deletion Tests', () {
    test('Delete listing image', () async {
      // Setup mock image URL
      final String imageUrl =
          'gs://elaka-app.appspot.com/listings/listing123/image.jpg';

      // Perform deletion
      await storageService.deleteImage(imageUrl);

      // Verify deletion was called (this is more complex with mocks)
      // In a real test, you'd verify the reference was deleted
    });
  });

  group('Multiple Image Upload Tests', () {
    test('Upload multiple listing images', () async {
      // Create mock image data
      final List<Uint8List> mockImagesData = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
        Uint8List.fromList([7, 8, 9]),
      ];

      // Mock the upload process
      final List<String> fileNames = [
        'image1.jpg',
        'image2.jpg',
        'image3.jpg',
      ];
      final String listingId = 'listing123';

      // Perform upload
      final downloadUrls = await storageService.uploadMultipleListingImages(
        mockImagesData,
        fileNames,
        listingId,
      );

      // Verify upload results
      expect(downloadUrls.length, 3);
      for (final url in downloadUrls) {
        expect(url, contains('listings/$listingId'));
      }
    });
  });
}
