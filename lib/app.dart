// File: lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/marketplace/home_screen.dart';
import 'screens/marketplace/create_listing_screen.dart';
import 'screens/marketplace/listing_detail_screen.dart';
import 'screens/messaging/chat_list_screen.dart';
import 'screens/messaging/chat_detail_screen.dart';
import 'services/chat_service.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'eLaka',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const Wrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/create-listing': (context) => const CreateListingScreen(),
          '/chats': (context) => const ChatListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/listing-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ListingDetailScreen(
                listingId: args['listingId'],
              ),
            );
          }

          if (settings.name == '/chat-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatId: args['chatId'],
                otherParticipantName: args['otherParticipantName'],
              ),
            );
          }

          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>;
            final authService = AuthService();
            final chatService = ChatService();

            // Get current user
            final currentUserId = authService.currentUserId;
            final currentUserName = authService.currentUser?.name;

            if (currentUserId == null || currentUserName == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Please log in to start a chat'),
                  ),
                ),
              );
            }

            // Create or get chat
            return MaterialPageRoute(
              builder: (context) => FutureBuilder<String>(
                future: chatService.getOrCreateChat(
                  currentUserId: currentUserId,
                  currentUserName: currentUserName,
                  otherUserId: args['sellerId'],
                  otherUserName: args['sellerName'],
                  listingId: args['listingId'],
                  listingTitle: args['listingTitle'],
                  listingImageUrl: args.containsKey('listingImageUrl')
                      ? args['listingImageUrl']
                      : null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }

                  final chatId = snapshot.data!;

                  return ChatDetailScreen(
                    chatId: chatId,
                    otherParticipantName: args['sellerName'],
                  );
                },
              ),
            );
          }

          // Use the original route generator for routes not defined above
          return AppRoutes.generateRoute(settings);
        },
      ),
    );
  }
}
