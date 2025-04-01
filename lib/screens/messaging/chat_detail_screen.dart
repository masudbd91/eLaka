// File: lib/screens/messaging/chat_detail_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherParticipantName;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherParticipantName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  String? _currentUserId;
  String? _currentUserName;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUserId;
    _currentUserName = _authService.currentUser?.name;

    // Mark messages as read when opening the chat
    if (_currentUserId != null) {
      _chatService.markMessagesAsRead(
        chatId: widget.chatId,
        currentUserId: _currentUserId!,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();

    // Update typing status when leaving the chat
    if (_currentUserId != null) {
      _chatService.updateTypingStatus(
        chatId: widget.chatId,
        userId: _currentUserId!,
        isTyping: false,
      );
    }

    super.dispose();
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null || _currentUserName == null) return;

    _chatService.sendTextMessage(
      chatId: widget.chatId,
      senderId: _currentUserId!,
      senderName: _currentUserName!,
      content: text,
    );

    _messageController.clear();

    // Update typing status
    _updateTypingStatus(false);
  }

  Future<void> _sendImageMessage() async {
    if (_currentUserId == null || _currentUserName == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _chatService.sendImageMessage(
        chatId: widget.chatId,
        senderId: _currentUserId!,
        senderName: _currentUserName!,
        imageFile: File(image.path),
      );
    }
  }

  void _updateTypingStatus(bool isTyping) {
    if (_currentUserId == null) return;

    // Cancel existing timer
    _typingTimer?.cancel();

    // If we're transitioning from not typing to typing
    if (isTyping && !_isTyping) {
      _chatService.updateTypingStatus(
        chatId: widget.chatId,
        userId: _currentUserId!,
        isTyping: true,
      );
      _isTyping = true;
    }

    // If we're typing, set a timer to stop typing status after 2 seconds of inactivity
    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _chatService.updateTypingStatus(
          chatId: widget.chatId,
          userId: _currentUserId!,
          isTyping: false,
        );
        _isTyping = false;
      });
    } else {
      // If we're explicitly setting typing to false
      _chatService.updateTypingStatus(
        chatId: widget.chatId,
        userId: _currentUserId!,
        isTyping: false,
      );
      _isTyping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view this chat'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherParticipantName),
            StreamBuilder<List<String>>(
              stream: _chatService.getTypingUsers(widget.chatId),
              builder: (context, snapshot) {
                final typingUsers = snapshot.data ?? [];
                final isOtherUserTyping = typingUsers.any((userId) => userId != _currentUserId);

                if (isOtherUserTyping) {
                  return const Text(
                    'Typing...',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessagesForChat(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }

                // Mark messages as read
                if (_currentUserId != null) {
                  _chatService.markMessagesAsRead(
                    chatId: widget.chatId,
                    currentUserId: _currentUserId!,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: 16.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                message.senderName.isNotEmpty
                                    ? message.senderName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: Container(
                              padding: message.type == MessageType.text
                                  ? const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              )
                                  : const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (message.type == MessageType.text)
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black,
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () {
                                        // Show full-screen image
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              appBar: AppBar(),
                                              body: Center(
                                                child: InteractiveViewer(
                                                  child: Image.network(
                                                    message.content,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Image.network(
                                          message.content,
                                          width: 200.0,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return SizedBox(
                                              width: 200.0,
                                              height: 200.0,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          color: isMe ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4.0),
                                        Icon(
                                          message.isRead
                                              ? Icons.done_all
                                              : Icons.done,
                                          size: 12.0,
                                          color: message.isRead
                                              ? Colors.blue[100]
                                              : Colors.white70,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          if (isMe)
                            CircleAvatar(
                              radius: 16.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                _currentUserName != null && _currentUserName!.isNotEmpty
                                    ? _currentUserName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _sendImageMessage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onChanged: (text) {
                      _updateTypingStatus(text.isNotEmpty);
                    },
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        _sendTextMessage();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendTextMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
