// File: lib/services/chat_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart'; // Ensure this file defines the ChatModel class

// If the ChatModel class is not defined, define it in the chat_model.dart file.
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference messageCollection =
      FirebaseFirestore.instance.collection('messages');

  // Get or create a chat between two users
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
  }) async {
    // Check if a chat already exists between these users
    QuerySnapshot chatQuery = await chatCollection
        .where('participants', arrayContains: currentUserId)
        .get();

    List<ChatModel> chats = chatQuery.docs
        .map((doc) =>
            ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((chat) => chat.participants.contains(otherUserId))
        .toList();

    // If a chat exists for this listing, return it
    if (listingId != null) {
      for (var chat in chats) {
        if (chat.listingId == listingId) {
          return chat.id;
        }
      }
    }

    // If any chat exists between these users, return the first one
    if (chats.isNotEmpty) {
      return chats.first.id;
    }

    // Otherwise, create a new chat
    Map<String, String> participantNames = {
      currentUserId: currentUserName,
      otherUserId: otherUserName,
    };

    var newChat = ChatModel(
      id: const Uuid().v4(),
      participants: [currentUserId, otherUserId],
      participantNames: participantNames,
      lastMessage: '',
      lastMessageSenderId: '',
      lastMessageTimestamp: DateTime.now(),
      isUnread: false,
      listingId: listingId,
      listingTitle: listingTitle,
      listingImageUrl: listingImageUrl,
    );

    await chatCollection.doc(newChat.id).set(newChat.toMap());

    return newChat.id;
  }

  // Send a text message
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    // Create a new message
    MessageModel message = MessageModel(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add the message to Firestore
    await messageCollection.doc(message.id).set(message.toMap());

    // Update the chat with the last message
    await _updateChatWithLastMessage(
      chatId: chatId,
      senderId: senderId,
      content: content,
    );
  }

  // Send an image message
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required File imageFile,
  }) async {
    // Upload the image to Firebase Storage
    String fileName = '${const Uuid().v4()}.jpg';
    Reference ref = _storage.ref().child('chat_images/$chatId/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Create a new message
    MessageModel message = MessageModel(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: imageUrl,
      type: MessageType.image,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add the message to Firestore
    await messageCollection.doc(message.id).set(message.toMap());

    // Update the chat with the last message
    await _updateChatWithLastMessage(
      chatId: chatId,
      senderId: senderId,
      content: '📷 Image',
    );
  }

  // Update chat with last message
  Future<void> _updateChatWithLastMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    await chatCollection.doc(chatId).update({
      'lastMessage': content,
      'lastMessageSenderId': senderId,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'isUnread': true,
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    // Get unread messages sent by the other user
    QuerySnapshot unreadMessages = await messageCollection
        .where('chatId', isEqualTo: chatId)
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    // Mark each message as read
    for (var doc in unreadMessages.docs) {
      await messageCollection.doc(doc.id).update({'isRead': true});
    }

    // Update the chat's unread status
    await chatCollection.doc(chatId).update({'isUnread': false});
  }

  // Update typing status
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await chatCollection.doc(chatId).update({
      'typingUsers': isTyping
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  // Get chats for a user
  Stream<List<ChatModel>> getChatsForUser(String userId) {
    return chatCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getMessagesForChat(String chatId) {
    return messageCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get typing status for a chat
  Stream<List<String>> getTypingUsers(String chatId) {
    return chatCollection.doc(chatId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('typingUsers')) {
          return List<String>.from(data['typingUsers'] ?? []);
        }
      }
      return <String>[];
    });
  }
}
