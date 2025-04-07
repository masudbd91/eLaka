// File: lib/models/temp_storage.dart

import 'package:elaka/models/listing_model.dart';
import '../models/user_model.dart';

/// A temporary storage class to simulate database functionality
/// until Firebase is integrated
class TempStorage {
  static final TempStorage _instance = TempStorage._internal();

  factory TempStorage() {
    return _instance;
  }

  TempStorage._internal();

  // Mock data
  final List<ListingModel> _listings = [];
  // Removed unused '_images' field
  final UserModel _currentUser = UserModel(
    id: 'temp-user-id',
    name: 'Demo User',
    email: 'demo@example.com',
    phone: '+1234567890',
    neighborhood: 'Sample Neighborhood',
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
    isVerified: true,
    lastLogin: DateTime.now(),
    profileImageUrl: '',
    location: '',
    ratings: 0.0,
    reviewCount: 0,
  );

  // Getters
  List<ListingModel> get listings => _listings;
  UserModel get currentUser => _currentUser;

  // Methods
  void addListing(ListingModel listing) {
    _listings.add(listing);
  }

  void updateListing(ListingModel listing) {
    final index = _listings.indexWhere((item) => item.id == listing.id);
    if (index != -1) {
      _listings[index] = listing;
    }
  }

  void deleteListing(String id) {
    _listings.removeWhere((listing) => listing.id == id);
  }

  ListingModel? getListingById(String id) {
    try {
      return _listings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getListingsByCategory(String category) async {
    return _listings
        .where((listing) =>
            listing.category == category &&
            listing.status == ListingStatus.sold)
        .toList();
  }

  Future<List<dynamic>> searchListings(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _listings
        .where((listing) =>
            listing.status == ListingStatus.sold &&
            (listing.title.toLowerCase().contains(lowercaseQuery) ||
                listing.description.toLowerCase().contains(lowercaseQuery) ||
                listing.tags
                    .any((tag) => tag.toLowerCase().contains(lowercaseQuery))))
        .toList();
  }

  // Add some sample listings for testing
  void addSampleListings() {
    if (_listings.isEmpty) {
      final now = DateTime.now();

      addListing(ListingModel(
        id: 'listing-1',
        title: 'Leather Sofa',
        description:
            'Comfortable brown leather sofa in excellent condition. Only 2 years old.',
        price: 250.0,
        category: 'Furniture',
        subcategory: 'Sofas & Chairs',
        imageUrls: [
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc'
        ],
        neighborhood: 'Downtown',
        tags: ['sofa', 'leather', 'furniture', 'living room'],
        sellerId: _currentUser.id,
        sellerName: _currentUser.name,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        status: '',
        ratings: 0.0,
        reviewCount: 0,
        location: '',
        images: [],
      ));

      addListing(ListingModel(
        id: 'listing-2',
        title: 'iPhone 13 Pro - 128GB',
        description:
            'Like new iPhone 13 Pro. Includes charger and original box.',
        price: 699.0,
        category: 'Electronics',
        subcategory: 'Phones',
        imageUrls: [
          'https://images.unsplash.com/photo-1591337676887-a217a6970a8a'
        ],
        neighborhood: 'Midtown',
        location: 'Oak Avenue',
        tags: ['iphone', 'apple', 'smartphone', 'electronics'],
        sellerId: _currentUser.id,
        sellerName: _currentUser.name,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        status: '',
        ratings: 0.0,
        reviewCount: 0,
        images: [],
      ));

      addListing(ListingModel(
        id: 'listing-3',
        title: 'Coffee Table - Solid Wood',
        description:
            'Beautiful solid wood coffee table. Minor scratches but overall good condition.',
        price: 120.0,
        category: 'Furniture',
        subcategory: 'Tables',
        imageUrls: [
          'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc'
        ],
        neighborhood: 'Westside',
        location: 'Pine Street',
        tags: ['coffee table', 'wood', 'furniture', 'living room'],
        sellerId: _currentUser.id,
        sellerName: _currentUser.name,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        status: '',
        ratings: 0.0,
        reviewCount: 0,
        images: [],
      ));

      addListing(ListingModel(
        id: 'listing-4',
        title: 'Mountain Bike - Trek',
        description:
            'Trek mountain bike in good condition. Recently serviced with new brakes.',
        price: 350.0,
        category: 'Sports & Outdoors',
        subcategory: 'Bikes',
        imageUrls: [
          'https://images.unsplash.com/photo-1485965120184-e220f721d03e'
        ],
        neighborhood: 'Northside',
        location: 'River Road',
        tags: ['bike', 'mountain bike', 'trek', 'sports', 'outdoors'],
        sellerId: _currentUser.id,
        sellerName: _currentUser.name,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        status: '',
        ratings: 0.0,
        reviewCount: 0,
        images: [],
      ));

      addListing(ListingModel(
        id: 'listing-5',
        title: 'Free Plants - Various Types',
        description:
            'Giving away various houseplants. Must pick up this weekend.',
        price: 0.0,
        category: 'Home & Garden',
        subcategory: 'Plants',
        imageUrls: [
          'https://images.unsplash.com/photo-1463936575829-25148e1db1b8'
        ],
        neighborhood: 'Eastside',
        location: 'Maple Avenue',
        tags: ['plants', 'free', 'houseplants', 'garden'],
        sellerId: _currentUser.id,
        sellerName: _currentUser.name,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        status: '',
        ratings: 0.0,
        reviewCount: 0,
        images: [],
      ));
    }
  }
}
