// lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing_model.dart';
import '../models/category_model.dart';

class DatabaseService {
  final FirebaseFirestore firestore;

  DatabaseService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Listings Methods
  Future<void> createListing(ListingModel listing) async {
    try {
      await firestore
          .collection('listings')
          .doc(listing.id)
          .set(listing.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<ListingModel?> getListing(String listingId) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ListingModel>> getListingsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('listings')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ListingModel>> searchListings(String query) async {
    try {
      // This is a simple implementation. For production, consider using Algolia or Firebase Extensions for better search
      QuerySnapshot snapshot = await firestore
          .collection('listings')
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .get();

      List<ListingModel> listings = snapshot.docs
          .map((doc) =>
              ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filter listings by query
      return listings
          .where((listing) =>
              listing.title.toLowerCase().contains(query.toLowerCase()) ||
              listing.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateListingStatus(String listingId, String status) async {
    try {
      await firestore.collection('listings').doc(listingId).update({
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteListing(String listingId) async {
    try {
      await firestore.collection('listings').doc(listingId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Categories Methods
  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('categories').get();
      return snapshot.docs
          .map((doc) =>
              CategoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // User Methods
  Future<List<ListingModel>> getUserListings(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('listings')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ListingModel>> getFavoriteListings(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      List<dynamic> favorites = userDoc.data() != null
          ? (userDoc.data() as Map<String, dynamic>)['favorites'] ?? []
          : [];

      List<ListingModel> listings = [];
      for (String listingId in favorites) {
        ListingModel? listing = await getListing(listingId);
        if (listing != null) {
          listings.add(listing);
        }
      }

      return listings;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToFavorites(String userId, String listingId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([listingId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String userId, String listingId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([listingId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  getUserData(User userId) {}

  getAllListings() {}

  getListingById(String listingId) {}

  getListings({String? query, String? category, required int limit}) {}

  getChats() {}

  sendOffer(String chatId, String listingId, double price, String trim) {}

  submitReview(String userId, String listingId, String transactionId,
      int rating, String trim) {}
}
