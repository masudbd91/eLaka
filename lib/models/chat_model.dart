import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTimestamp;
  final bool isUnread;
  final String? listingId;
  final String? listingTitle;
  final String? listingImageUrl;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTimestamp,
    required this.isUnread,
    this.listingId,
    this.listingTitle,
    this.listingImageUrl,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(),
      isUnread: map['isUnread'] ?? false,
      listingId: map['listingId'],
      listingTitle: map['listingTitle'],
      listingImageUrl: map['listingImageUrl'],
    );
  }

  Object? toMap() {
    return{
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'isUnread': isUnread,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImageUrl': listingImageUrl,
    };
  }
}