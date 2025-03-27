// test/messaging_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:elaka/services/messaging_service.dart';
import 'package:elaka/models/message_model.dart';

class MockMessagingService extends Mock implements MessagingService {}

void main() {
  late FakeFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MessagingService messagingService;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    messagingService = MessagingService(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('Chat Creation Tests', () {
    test('Create new chat', () async {
      // Test user IDs
      final String currentUserId = 'user123';
      final String otherUserId = 'user456';

      // Create chat
      final chatId = await messagingService.createChat(
        currentUserId,
        otherUserId,
        'Test Listing',
      );

      // Verify chat was created
      final chatDoc = await mockFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.exists, true);
      expect(chatDoc.data()?['participants'], contains(currentUserId));
      expect(chatDoc.data()?['participants'], contains(otherUserId));
      expect(chatDoc.data()?['listingTitle'], 'Test Listing');
    });
  });

  group('Message Tests', () {
    test('Send message', () async {
      // Test data
      final String chatId = 'chat123';
      final String senderId = 'user123';
      final String content = 'Hello, is this item still available?';

      // Send message
      await messagingService.sendMessage(
        chatId,
        senderId,
        content,
      );

      // Verify message was added
      final messagesSnapshot = await mockFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      expect(messagesSnapshot.docs.length, 1);
      expect(messagesSnapshot.docs.first.data()['senderId'], senderId);
      expect(messagesSnapshot.docs.first.data()['content'], content);
    });

    test('Get messages stream', () async {
      // Test data
      final String chatId = 'chat123';

      // Add test messages
      await mockFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': 'user123',
        'content': 'Message 1',
        'timestamp': DateTime.now(),
      });

      await mockFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': 'user456',
        'content': 'Message 2',
        'timestamp': DateTime.now(),
      });

      // Get messages stream
      final messagesStream = messagingService.getMessages(chatId);

      // Verify stream emits messages
      expect(
        messagesStream,
        emits(predicate<List<MessageModel>>((messages) =>
            messages.length == 2 &&
            messages.any((m) => m.content == 'Message 1') &&
            messages.any((m) => m.content == 'Message 2'))),
      );
    });
  });

  group('Chat List Tests', () {
    test('Get user chats', () async {
      // Test user ID
      final String userId = 'user123';

      // Add test chats
      await mockFirestore.collection('chats').add({
        'id': 'chat1',
        'participants': [userId, 'user456'],
        'lastMessage': 'Hello',
        'lastMessageTimestamp': DateTime.now(),
        'listingTitle': 'Test Listing 1',
      });

      await mockFirestore.collection('chats').add({
        'id': 'chat2',
        'participants': [userId, 'user789'],
        'lastMessage': 'Is this available?',
        'lastMessageTimestamp': DateTime.now(),
        'listingTitle': 'Test Listing 2',
      });

      await mockFirestore.collection('chats').add({
        'id': 'chat3',
        'participants': ['user456', 'user789'],
        'lastMessage': 'Other chat',
        'lastMessageTimestamp': DateTime.now(),
        'listingTitle': 'Test Listing 3',
      });

      // Get user chats
      final chatsStream = messagingService.getUserChats(userId);

      // Verify stream emits correct chats
      expect(
        chatsStream,
        emits(predicate<List<dynamic>>((chats) =>
            chats.length == 2 &&
            chats.any((c) => c.id == 'chat1') &&
            chats.any((c) => c.id == 'chat2') &&
            !chats.any((c) => c.id == 'chat3'))),
      );
    });
  });

  group('Notification Tests', () {
    test('Mark chat as read', () async {
      // Test data
      final String chatId = 'chat123';
      final String userId = 'user123';

      // Add test chat with unread status
      await mockFirestore.collection('chats').doc(chatId).set({
        'unreadBy': [userId],
      });

      // Mark as read
      await messagingService.markChatAsRead(chatId, userId);

      // Verify chat was marked as read
      final chatDoc = await mockFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.data()?['unreadBy'], isNot(contains(userId)));
    });
  });
}
