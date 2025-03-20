// File: lib/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  // Convert MessageModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  // Create MessageModel from Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      id: documentId,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] != null
          ? MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      )
          : MessageType.text,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
