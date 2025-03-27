// Example Firebase service for listings
// File: lib/services/firebase_listing_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirebaseListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all listings
  Future<List<ListingModel>> getListings() async {
    final querySnapshot = await _firestore.collection('listings').get();
    return querySnapshot.docs.map((doc) =>
        ListingModel.fromMap(doc.data(), doc.id)
    ).toList();
  }

  // Add a listing
  Future<void> addListing(ListingModel listing) async {
    await _firestore.collection('listings').doc(listing.id).set(listing.toMap());
  }

  // Get listings by category
  Future<List<ListingModel>> getListingsByCategory(String category) async {
    final querySnapshot = await _firestore
        .collection('listings')
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .get();

    return querySnapshot.docs.map((doc) =>
        ListingModel.fromMap(doc.data(), doc.id)
    ).toList();
  }

  // Search listings
  Future<List<ListingModel>> searchListings(String query) async {
    // Note: This is a simple implementation. For better search,
    // consider using Firebase extensions like Algolia
    final querySnapshot = await _firestore
        .collection('listings')
        .where('status', isEqualTo: 'active')
        .get();

    final lowercaseQuery = query.toLowerCase();
    return querySnapshot.docs
        .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
        .where((listing) =>
    listing.title.toLowerCase().contains(lowercaseQuery) ||
        listing.description.toLowerCase().contains(lowercaseQuery) ||
        listing.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    )
        .toList();
  }
}
