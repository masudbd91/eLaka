import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/listing_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'storage_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  // Get user data
  Future<UserModel> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Get listings
  Future<List<ListingModel>> getListings({
    String? category,
    String? neighborhood,
    String? query,
    int limit = 20,
  }) async {
    try {
      Query listingsQuery = _firestore.collection('listings');

      if (category != null) {
        listingsQuery = listingsQuery.where('category', isEqualTo: category);
      }

      if (neighborhood != null) {
        listingsQuery = listingsQuery.where('neighborhood', isEqualTo: neighborhood);
      }

      // Note: For a real app, you would implement full-text search
      // using a service like Algolia or ElasticSearch

      listingsQuery = listingsQuery
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final querySnapshot = await listingsQuery.get();

      return querySnapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get listings: $e');
    }
  }

  // Get listing by ID
  Future<ListingModel> getListingById(String listingId) async {
    try {
      final doc = await _firestore.collection('listings').doc(listingId).get();

      if (!doc.exists) {
        throw Exception('Listing not found');
      }

      // Increment view count
      await _firestore.collection('listings').doc(listingId).update({
        'viewCount': FieldValue.increment(1),
      });

      return ListingModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }

  // Get categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();

      return querySnapshot.docs
          .map((doc) => {
        ...doc.data(),
        'id': doc.id,
      })
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Toggle favorite listing
  Future<void> toggleFavoriteListing(String listingId) async {
    try {
      final userId = _auth.currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data()!;
      final favoriteListings = List<String>.from(userData['favoriteListings'] ?? []);

      if (favoriteListings.contains(listingId)) {
        // Remove from favorites
        favoriteListings.remove(listingId);
        await _firestore.collection('listings').doc(listingId).update({
          'favoriteCount': FieldValue.increment(-1),
        });
      } else {
        // Add to favorites
        favoriteListings.add(listingId);
        await _firestore.collection('listings').doc(listingId).update({
          'favoriteCount': FieldValue.increment(1),
        });
      }

      await _firestore.collection('users').doc(userId).update({
        'favoriteListings': favoriteListings,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Create listing
  Future<String> createListing({
    required String title,
    required String description,
    required double price,
    required String category,
    required String subcategory,
    required List<File> images,
    required String neighborhood,
    required String location,
    required List<String> tags,
  }) async {
    try {
      final userId = _auth.currentUser!.uid;
      final userData = await getUserData(userId);

      // Upload images
      final imageUrls = await Future.wait(
        images.map((image) => _storageService.uploadListingImage(image)),
      );

      // Create listing document
      final listingRef = _firestore.collection('listings').doc();

      final listing = ListingModel(
        id: listingRef.id,
        title: title,
        description: description,
        price: price,
        category: category,
        subcategory: subcategory,
        imageUrls: imageUrls,
        neighborhood: neighborhood,
        location: location,
        tags: tags,
        sellerId: userId,
        sellerName: userData.name,
        sellerImageUrl: userData.imageUrl,
        isSellerVerified: userData.isVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await listingRef.set(listing.toMap());

      return listingRef.id;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  // Get chats
  Future<List<ChatModel>> getChats() async {
    try {
      final userId = _auth.currentUser!.uid;

      final querySnapshot = await _firestore.collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final chats = querySnapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
          .toList();

      // Fetch other user data for each chat
      for (var i = 0; i < chats.length; i++) {
        final chat = chats[i];
        final otherUserId = chat.buyerId == userId ? chat.sellerId : chat.buyerId;
        final otherUser = await getUserData(otherUserId);

        // Add other user data to chat
        chats[i] = chat.copyWith(
          otherUserName: otherUser.name,
          otherUserImageUrl: otherUser.imageUrl,
          otherUserNeighborhood: otherUser.neighborhood,
          isOtherUserVerified: otherUser.isVerified,
        );
      }

      return chats;
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  // Get chat by ID
  Future<ChatModel> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();

      if (!doc.exists) {
        throw Exception('Chat not found');
      }

      final chat = ChatModel.fromMap(doc.data()!, doc.id);

      // Fetch other user data
      final userId = _auth.currentUser!.uid;
      final otherUserId = chat.buyerId == userId ? chat.sellerId : chat.buyerId;
      final otherUser = await getUserData(otherUserId);

      // Add other user data to chat
      return chat.copyWith(
        otherUserName: otherUser.name,
        otherUserImageUrl: otherUser.imageUrl,
        otherUserNeighborhood: otherUser.neighborhood,
        isOtherUserVerified: otherUser.isVerified,
      );
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  // Get or create chat
  Future<String> getOrCreateChat(String listingId, String sellerId) async {
    try {
      final userId = _auth.currentUser!.uid;

      // Check if chat already exists
      final querySnapshot = await _firestore.collection('chats')
          .where('listingId', isEqualTo: listingId)
          .where('buyerId', isEqualTo: userId)
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      // Get listing data
      final listing = await getListingById(listingId);

      // Create new chat
      final chatRef = _firestore.collection('chats').doc();

      final chat = ChatModel(
        id: chatRef.id,
        listingId: listingId,
        listingTitle: listing.title,
        listingImageUrl: listing.imageUrls.isNotEmpty ? listing.imageUrls[0] : '',
        buyerId: userId,
        sellerId: sellerId,
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        createdAt: DateTime.now(),
      );

      await chatRef.set(chat.toMap());

      return chatRef.id;
    } catch (e) {
      throw Exception('Failed to get or create chat: $e');
    }
  }

  // Get messages
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final querySnapshot = await _firestore.collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp')
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      final userId = _auth.currentUser!.uid;

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      throw Exception('Failed to mark chat as read: $e');
    }
  }

  // Send message
  Future<MessageModel> sendMessage(String chatId, String text) async {
    try {
      final userId = _auth.currentUser!.uid;

      // Create message document
      final messageRef = _firestore.collection('messages').doc();

      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: userId,
        text: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toMap());

      // Update chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSenderId': userId,
        'unreadCount': FieldValue.increment(1),
      });

      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Send image message
  Future<MessageModel> sendImageMessage(String chatId, File image) async {
    try {
      final userId = _auth.currentUser!.uid;

      // Upload image
      final imageUrl = await _storageService.uploadChatImage(image);

      // Create message document
      final messageRef = _firestore.collection('messages').doc();

      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: userId,
        text: 'Image',
        imageUrl: imageUrl,
        type: MessageType.image,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toMap());

      // Update chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': 'Image',
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSenderId': userId,
        'unreadCount': FieldValue.increment(1),
      });

      return message;
    } catch (e) {
      throw Exception('Failed to send image message: $e');
    }
  }

  // Send offer
  Future<void> sendOffer(String chatId, String listingId, double price, String note) async {
    try {
      final userId = _auth.currentUser!.uid;

      // Create message document
      final messageRef = _firestore.collection('messages').doc();

      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: userId,
        text: 'Offered $price for this item',
        type: MessageType.offer,
        metadata: {
          'price': price,
          'note': note,
          'listingId': listingId,
        },
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toMap());

      // Update chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': 'Offered $price for this item',
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSenderId': userId,
        'unreadCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to send offer: $e');
    }
  }

  // Submit review
  Future<void> submitReview(
      String userId,
      String listingId,
      String transactionId,
      int rating,
      String review,
      ) async {
    try {
      final reviewerId = _auth.currentUser!.uid;

      // Create review document
      final reviewRef = _firestore.collection('reviews').doc();

      await reviewRef.set({
        'userId': userId,
        'reviewerId': reviewerId,
        'listingId': listingId,
        'transactionId': transactionId,
        'rating': rating,
        'review': review,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update user's rating
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final currentRating = (userData['rating'] ?? 0.0).toDouble();
        final reviewCount = (userData['reviewCount'] ?? 0) + 1;

        // Calculate new rating
        final newRating = ((currentRating * (reviewCount - 1)) + rating) / reviewCount;

        await _firestore.collection('users').doc(userId).update({
          'rating': newRating,
          'reviewCount': reviewCount,
        });
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  // Report user
  Future<void> reportUser(String userId, String reason) async {
    try {
      final reporterId = _auth.currentUser!.uid;

      // Create report document
      final reportRef = _firestore.collection('reports').doc();

      await reportRef.set({
        'userId': userId,
        'reporterId': reporterId,
        'reason': reason,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }
}
