// test/database_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:elaka/services/database_service.dart';
import 'package:elaka/models/listing_model.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late FakeFirebaseFirestore mockFirestore;
  late DatabaseService databaseService;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService(firestore: mockFirestore);
  });

  group('Listings Tests', () {
    test('Create listing', () async {
      // Create test listing data
      final testListing = ListingModel(
        id: 'test-id',
        title: 'Test Listing',
        description: 'Test description',
        price: 100.0,
        category: 'Electronics',
        images: ['image1.jpg'],
        sellerId: 'user123',
        sellerName: 'Test User',
        location: 'Test Location',
        createdAt: DateTime.now(),
        status: 'available',
        subcategory: '',
        imageUrls: [],
        neighborhood: '',
        updatedAt: DateTime.now(),
        tags: [],
        reviewCount: 0,
        ratings: 0,
      );

      // Add listing to database
      await databaseService.createListing(testListing);

      // Verify listing was added
      final snapshot =
          await mockFirestore.collection('listings').doc('test-id').get();
      expect(snapshot.exists, true);
      expect(snapshot.data()?['title'], 'Test Listing');
      expect(snapshot.data()?['price'], 100.0);
    });

    test('Get listings by category', () async {
      // Add test listings
      await mockFirestore.collection('listings').add({
        'id': 'listing1',
        'title': 'Test Listing 1',
        'category': 'Electronics',
        'price': 100.0,
        'status': 'available',
      });

      await mockFirestore.collection('listings').add({
        'id': 'listing2',
        'title': 'Test Listing 2',
        'category': 'Electronics',
        'price': 200.0,
        'status': 'available',
      });

      await mockFirestore.collection('listings').add({
        'id': 'listing3',
        'title': 'Test Listing 3',
        'category': 'Furniture',
        'price': 300.0,
        'status': 'available',
      });

      // Get listings by category
      final listings =
          await databaseService.getListingsByCategory('Electronics');

      // Verify correct listings are returned
      expect(listings.length, 2);
      expect(
          listings.any((listing) => listing.title == 'Test Listing 1'), true);
      expect(
          listings.any((listing) => listing.title == 'Test Listing 2'), true);
      expect(
          listings.any((listing) => listing.title == 'Test Listing 3'), false);
    });

    test('Update listing status', () async {
      // Add test listing
      final docRef = await mockFirestore.collection('listings').add({
        'id': 'listing1',
        'title': 'Test Listing',
        'status': 'available',
      });

      // Update listing status
      await databaseService.updateListingStatus(docRef.id, 'sold');

      // Verify status was updated
      final updatedDoc =
          await mockFirestore.collection('listings').doc(docRef.id).get();
      expect(updatedDoc.data()?['status'], 'sold');
    });

    test('Delete listing', () async {
      // Add test listing
      final docRef = await mockFirestore.collection('listings').add({
        'id': 'listing1',
        'title': 'Test Listing',
      });

      // Delete listing
      await databaseService.deleteListing(docRef.id);

      // Verify listing was deleted
      final deletedDoc =
          await mockFirestore.collection('listings').doc(docRef.id).get();
      expect(deletedDoc.exists, false);
    });
  });

  group('Categories Tests', () {
    test('Get all categories', () async {
      // Add test categories
      await mockFirestore.collection('categories').add({
        'id': 'cat1',
        'name': 'Electronics',
        'icon': 'electronics_icon',
      });

      await mockFirestore.collection('categories').add({
        'id': 'cat2',
        'name': 'Furniture',
        'icon': 'furniture_icon',
      });

      // Get all categories
      final categories = await databaseService.getCategories();

      // Verify categories are returned
      expect(categories.length, 2);
      expect(categories.any((cat) => cat.name == 'Electronics'), true);
      expect(categories.any((cat) => cat.name == 'Furniture'), true);
    });
  });

  group('User Data Tests', () {
    test('Get user listings', () async {
      // Add test listings for user
      await mockFirestore.collection('listings').add({
        'id': 'listing1',
        'title': 'User Listing 1',
        'sellerId': 'user123',
      });

      await mockFirestore.collection('listings').add({
        'id': 'listing2',
        'title': 'User Listing 2',
        'sellerId': 'user123',
      });

      await mockFirestore.collection('listings').add({
        'id': 'listing3',
        'title': 'Other User Listing',
        'sellerId': 'user456',
      });

      // Get user listings
      final userListings = await databaseService.getUserListings('user123');

      // Verify correct listings are returned
      expect(userListings.length, 2);
      expect(userListings.any((listing) => listing.title == 'User Listing 1'),
          true);
      expect(userListings.any((listing) => listing.title == 'User Listing 2'),
          true);
      expect(
          userListings.any((listing) => listing.title == 'Other User Listing'),
          false);
    });
  });
}
