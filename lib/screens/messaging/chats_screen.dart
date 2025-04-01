import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _chats = [];
  final int _currentIndex = 3; // Chats tab

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get chats
      final chats = await DatabaseService().getChats();

      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chats: ${e.toString()}')),
      );
    }
  }

  void _onChatTap(Map<String, dynamic> chat) {
    Navigator.of(context).pushNamed(
      '/chat-detail',
      arguments: {'chatId': chat['id']},
    );
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Home
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1: // Search
        Navigator.of(context).pushNamed('/search');
        break;
      case 2: // Sell
        Navigator.of(context).pushNamed('/create-listing');
        break;
      case 3: // Chats
      // Already on chats screen
        break;
      case 4: // Profile
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          itemCount: _chats.length,
          itemBuilder: (context, index) {
            final chat = _chats[index];
            return ChatListItem(
              title: chat['otherUserName'],
              subtitle: chat['lastMessage'],
              imageUrl: chat['otherUserImageUrl'],
              time: _getTimeAgo(DateTime.parse(chat['lastMessageTime'])),
              unreadCount: chat['unreadCount'],
              isVerified: chat['isOtherUserVerified'],
              onTap: () => _onChatTap(chat),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No Chats Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Start a conversation by contacting a seller',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Browse Listings'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      // Format as MM/DD/YY
      return DateFormat('MM/dd/yy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}