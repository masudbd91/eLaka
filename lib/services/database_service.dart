// File: lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference listingCollection = FirebaseFirestore.instance.collection('listings');

  // User operations

  // Create or update user data
  Future<void> updateUserData({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required String neighborhood,
  }) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'neighborhood': neighborhood,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await userCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listing operations

  // Add a listing
  Future<String> addListing(ListingModel listing) async {
    DocumentReference docRef = await listingCollection.add(listing.toMap());
    return docRef.id;
  }

  // Update a listing
  Future<void> updateListing(ListingModel listing) async {
    return await listingCollection.doc(listing.id).update(listing.toMap());
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    return await listingCollection.doc(id).delete();
  }

  // Get a listing by ID
  Future<ListingModel?> getListingById(String id) async {
    DocumentSnapshot doc = await listingCollection.doc(id).get();
    if (doc.exists) {
      return ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get listings by category
  Stream<List<ListingModel>> getListingsByCategory(String category) {
    return listingCollection
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_listingListFromSnapshot);
  }

  // Get listings by user ID
  Stream<List<ListingModel>> getListingsByUserId(String userId) {
    return listingCollection
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_listingListFromSnapshot);
  }

  // Get all listings
  Stream<List<ListingModel>> getAllListings() {
    return listingCollection
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_listingListFromSnapshot);
  }

  // Search listings
  Future<List<ListingModel>> searchListings(String query) async {
    // Note: For better search functionality, consider using Algolia or other search services
    QuerySnapshot snapshot = await listingCollection
        .where('status', isEqualTo: 'active')
        .get();

    List<ListingModel> listings = _listingListFromSnapshot(snapshot);

    if (query.isEmpty) return listings;

    final lowercaseQuery = query.toLowerCase();
    return listings.where((listing) =>
    listing.title.toLowerCase().contains(lowercaseQuery) ||
        listing.description.toLowerCase().contains(lowercaseQuery) ||
        listing.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Helper method to convert snapshot to list of listings
  List<ListingModel> _listingListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ListingModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }
}
