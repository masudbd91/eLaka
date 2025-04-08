// lib/models/chat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final String lastMessageSenderId;
  final bool isUnread;
  final String? listingId;
  final String? listingTitle;
  final String? listingImageUrl;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
    required this.isUnread,
    this.listingId,
    this.listingTitle,
    this.listingImageUrl,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp: (map['lastMessageTimestamp'] is Timestamp)
          ? (map['lastMessageTimestamp'] as Timestamp).toDate()
          : DateTime.parse(map['lastMessageTimestamp'].toString()),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      isUnread: map['isUnread'] ?? false,
      listingId: map['listingId'],
      listingTitle: map['listingTitle'],
      listingImageUrl: map['listingImageUrl'],
    );
  }

  // Add fromJson method to match what's used in chat_list_screen.dart
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      participantNames:
          Map<String, String>.from(json['participantNames'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp: (json['lastMessageTimestamp'] is Timestamp)
          ? (json['lastMessageTimestamp'] as Timestamp).toDate()
          : DateTime.parse(json['lastMessageTimestamp'].toString()),
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      isUnread: json['isUnread'] ?? false,
      listingId: json['listingId'],
      listingTitle: json['listingTitle'],
      listingImageUrl: json['listingImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'lastMessageSenderId': lastMessageSenderId,
      'isUnread': isUnread,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImageUrl': listingImageUrl,
    };
  }

  // Add toJson method for consistency
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    Map<String, String>? participantNames,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    String? lastMessageSenderId,
    bool? isUnread,
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      isUnread: isUnread ?? this.isUnread,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImageUrl: listingImageUrl ?? this.listingImageUrl,
    );
  }
}
