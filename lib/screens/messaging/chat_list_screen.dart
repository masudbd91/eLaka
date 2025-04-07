// lib/screens/messaging/chat_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';

class ChatModel {
  // Define your fields here
  final String id;
  final String participant1Id;
  final String participant2Id;
  final String? participant1Name;
  final String? participant2Name;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final String lastMessageSenderId;
  final bool isUnread;
  final String? listingTitle;
  final String? listingImageUrl;

  ChatModel({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    this.participant1Name,
    this.participant2Name,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
    required this.isUnread,
    this.listingTitle,
    this.listingImageUrl,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participant1Id: json['participant1Id'] as String,
      participant2Id: json['participant2Id'] as String,
      participant1Name: json['participant1Name'] as String?,
      participant2Name: json['participant2Name'] as String?,
      lastMessage: json['lastMessage'] as String,
      lastMessageTimestamp: DateTime.parse(json['lastMessageTimestamp'] as String),
      lastMessageSenderId: json['lastMessageSenderId'] as String,
      isUnread: json['isUnread'] as bool,
      listingTitle: json['listingTitle'] as String?,
      listingImageUrl: json['listingImageUrl'] as String?,
    );
  }
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Use the currentUserId getter instead of currentUser
    _currentUserId = _authService.currentUserId;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getOtherParticipantName(chat) {
    if (chat.participant1Id == _currentUserId) {
      return chat.participant2Name ?? 'Unknown';
    } else if (chat.participant2Id == _currentUserId) {
      return chat.participant1Name ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your chats'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _chatService.getChatsForUser(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<ChatModel> chats = [];

          if (snapshot.data != null) {
            chats = snapshot.data!.map((e) {
              // Use fromMap instead of fromJson if needed
              return ChatModel.fromJson(e as Map<String, dynamic>);
            }).toList();
          }
          if (chats.isEmpty) {
            return const Center(
              child: Text('No messages yet'),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherParticipantName = _getOtherParticipantName(chat);
              final isLastMessageFromMe =
                  chat.lastMessageSenderId == _currentUserId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    otherParticipantName.isNotEmpty
                        ? otherParticipantName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        otherParticipantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _getTimeAgo(chat.lastMessageTimestamp),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isLastMessageFromMe)
                          const Text(
                            'You: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            style: TextStyle(
                              fontWeight: chat.isUnread && !isLastMessageFromMe
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.isUnread && !isLastMessageFromMe)
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (chat.listingTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            if (chat.listingImageUrl != null)
                              Container(
                                width: 20.0,
                                height: 20.0,
                                margin: const EdgeInsets.only(right: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  image: DecorationImage(
                                    image: NetworkImage(chat.listingImageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                chat.listingTitle!,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/chat-detail',
                    arguments: {
                      'chatId': chat.id,
                      'otherParticipantName': otherParticipantName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
