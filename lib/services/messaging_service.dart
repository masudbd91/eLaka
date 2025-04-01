// lib/services/messaging_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessagingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MessagingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) :
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Create a new chat between two users
  Future<String> createChat(
      String currentUserId,
      String otherUserId,
      String listingTitle,
      ) async {
    try {
      // Check if chat already exists
      final existingChatQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChatQuery.docs) {
        List<dynamic> participants = doc.data()['participants'] ?? [];
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new chat
      final chatRef = _firestore.collection('chats').doc();
      await chatRef.set({
        'id': chatRef.id,
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'listingTitle': listingTitle,
        'unreadBy': [],
      });

      return chatRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Send a message in a chat
  Future<void> sendMessage(
      String chatId,
      String senderId,
      String content,
      ) async {
    try {
      // Add message to chat
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await messageRef.set(message.toMap());

      // Update chat with last message
      final otherParticipants = await _getOtherParticipants(chatId, senderId);

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadBy': otherParticipants,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Get all chats for a user
  Stream<List<dynamic>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Mark a chat as read for a user
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      List<dynamic> unreadBy = chatDoc.data()?['unreadBy'] ?? [];

      if (unreadBy.contains(userId)) {
        unreadBy.remove(userId);
        await _firestore.collection('chats').doc(chatId).update({
          'unreadBy': unreadBy,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get number of unread chats for a user
  Stream<int> getUnreadChatsCount(String userId) {
    return _firestore
        .collection('chats')
        .where('unreadBy', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Helper method to get other participants in a chat
  Future<List<String>> _getOtherParticipants(String chatId, String currentUserId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      List<dynamic> participants = chatDoc.data()?['participants'] ?? [];
      return participants.where((id) => id != currentUserId).cast<String>().toList();
    } catch (e) {
      rethrow;
    }
  }
}
