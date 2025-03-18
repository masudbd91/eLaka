import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  Map<String, dynamic>? _chat;
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _listing;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get chat details
      final chat = await DatabaseService().getChatById(widget.chatId);

      // Get messages
      final messages = await DatabaseService().getMessages(widget.chatId);

      // Get listing details
      final listing = await DatabaseService().getListingById(chat['listingId']);

      // Mark chat as read
      await DatabaseService().markChatAsRead(widget.chatId);

      setState(() {
        _chat = chat;
        _messages = messages;
        _listing = listing;
        _isLoading = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat: ${e.toString()}')),
      );

      // Navigate back
      Navigator.of(context).pop();
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Clear input field
      _messageController.clear();

      // Send message
      final newMessage = await DatabaseService().sendMessage(
        widget.chatId,
        message,
      );

      // Add message to list
      setState(() {
        _messages.add(newMessage);
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _isSending = true;
        });

        // Send image message
        final newMessage = await DatabaseService().sendImageMessage(
          widget.chatId,
          File(image.path),
        );

        // Add message to list
        setState(() {
          _messages.add(newMessage);
          _isSending = false;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: ${e.toString()}')),
      );
    }
  }

  void _viewListing() {
    if (_listing == null) return;

    Navigator.of(context).pushNamed(
      '/listing-detail',
      arguments: {'listingId': _listing!['id']},
    );
  }

  void _viewUserProfile() {
    if (_chat == null) return;

    Navigator.of(context).pushNamed(
      '/user-profile',
      arguments: {'userId': _chat!['otherUserId']},
    );
  }

  void _reportUser() {
    if (_chat == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text(
          'Are you sure you want to report this user? This will send a report to our moderation team for review.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await DatabaseService().reportUser(
                  _chat!['otherUserId'],
                  'Reported from chat',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User reported successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to report user: ${e.toString()}')),
                );
              }
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading || _chat == null
            ? const Text('Chat')
            : GestureDetector(
          onTap: _viewUserProfile,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16.0,
                backgroundImage: _chat!['otherUserImageUrl'].isNotEmpty
                    ? NetworkImage(_chat!['otherUserImageUrl'])
                    : null,
                child: _chat!['otherUserImageUrl'].isEmpty
                    ? Text(
                  _chat!['otherUserName'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          _chat!['otherUserName'],
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        if (_chat!['isOtherUserVerified'])
                          const Icon(
                            Icons.verified_user,
                            size: 14.0,
                            color: AppTheme.successColor,
                          ),
                      ],
                    ),
                    Text(
                      _chat!['otherUserNeighborhood'],
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!_isLoading && _chat != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view_listing') {
                  _viewListing();
                } else if (value == 'view_profile') {
                  _viewUserProfile();
                } else if (value == 'report') {
                  _reportUser();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'view_listing',
                  child: Text('View Listing'),
                ),
                const PopupMenuItem<String>(
                  value: 'view_profile',
                  child: Text('View Profile'),
                ),
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Text('Report User'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Listing info
          if (_listing != null)
            GestureDetector(
              onTap: _viewListing,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.dividerColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Listing image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        _listing!['imageUrls'][0],
                        width: 60.0,
                        height: 60.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60.0,
                            height: 60.0,
                            color: AppTheme.surfaceColor,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppTheme.textSecondaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Listing details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _listing!['title'],
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _listing!['price'] == 0
                                ? 'Free'
                                : '\$${_listing!['price'].toStringAsFixed(_listing!['price'].truncateToDouble() == _listing!['price'] ? 0 : 2)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _listing!['status'] == 'sold' ? 'Sold' : 'Available',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _listing!['status'] == 'sold'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message['senderId'] == AuthService().currentUser?.uid;

                // Check if we need to show date header
                final showDateHeader = index == 0 ||
                    !_isSameDay(
                      DateTime.parse(_messages[index - 1]['timestamp']),
                      DateTime.parse(message['timestamp']),
                    );

                return Column(
                  children: [
                    if (showDateHeader)
                      _buildDateHeader(DateTime.parse(message['timestamp'])),
                    MessageBubble(
                      message: message['text'],
                      imageUrl: message['imageUrl'],
                      isCurrentUser: isCurrentUser,
                      time: _formatMessageTime(DateTime.parse(message['timestamp'])),
                    ),
                  ],
                );
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image button
                IconButton(
                  icon: const Icon(Icons.photo_outlined),
                  onPressed: _pickImage,
                ),
                // Message input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                // Send button
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  )
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64.0,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16.0),
          Text(
            'No Messages Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Start the conversation by sending a message',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            _formatDateHeader(date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  String _formatMessageTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}