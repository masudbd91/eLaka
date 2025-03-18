import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/marketplace/home_screen.dart';
import '../screens/marketplace/search_screen.dart';
import '../screens/marketplace/listing_detail_screen.dart';
import '../screens/marketplace/create_listing_screen.dart';
import '../screens/messaging/chats_screen.dart';
import '../screens/messaging/chat_detail_screen.dart';
import '../screens/messaging/offer_screen.dart';
import '../screens/messaging/review_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String home = '/home';
  static const String search = '/search';
  static const String searchResults = '/search-results';
  static const String listingDetail = '/listing-detail';
  static const String createListing = '/create-listing';
  static const String chats = '/chats';
  static const String chatDetail = '/chat-detail';
  static const String offer = '/offer';
  static const String review = '/review';
  static const String profile = '/profile';
  static const String userProfile = '/user-profile';
  static const String notifications = '/notifications';
  static const String categories = '/categories';
  static const String category = '/category';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case searchResults:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SearchResultsScreen(
            query: args?['query'],
            category: args?['category'],
          ),
        );
      case listingDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ListingDetailScreen(
            listingId: args['listingId'],
          ),
        );
      case createListing:
        return MaterialPageRoute(builder: (_) => const CreateListingScreen());
      case chats:
        return MaterialPageRoute(builder: (_) => const ChatsScreen());
      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: args['chatId'],
          ),
        );
      case offer:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OfferScreen(
            chatId: args['chatId'],
            listingId: args['listingId'],
            originalPrice: args['originalPrice'],
          ),
        );
      case review:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(
            userId: args['userId'],
            listingId: args['listingId'],
            transactionId: args['transactionId'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}