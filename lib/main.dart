// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'config/theme.dart';

void main() async {
  print("App starting...");
  WidgetsFlutterBinding.ensureInitialized();
  print("Flutter binding initialized");

  try {
    // For Android and iOS
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");

    // Alternative initialization with options (try this if the above fails)
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCCCMPNXbDC5VMRdBefL4QM6hapW4TwvVA",
          appId: "1:233113275073:android:e93c0ad75516ece2612240",
          messagingSenderId: "233113275073",
          projectId: "elaka-dd0bf",
          storageBucket: "elaka-dd0bf.firebasestorage.app",
        ),
      );
      print("Firebase initialized with options successfully");
    } catch (e) {
      print("Firebase initialization with options error: $e");
    }
  }

  runApp(const MyApp());
  print("App running");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building MyApp");
    return MaterialApp(
      title: 'eLaka',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building AuthWrapper");
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        print("Auth state connection: ${snapshot.connectionState}");

        if (snapshot.hasError) {
          print("Auth stream error: ${snapshot.error}");
          return Scaffold(
            body: Center(
              child: Text("Authentication Error: ${snapshot.error}"),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          print("Auth state active");
          User? user = snapshot.data;
          if (user == null) {
            print("No user logged in, showing LoginScreen");
            return const LoginScreen();
          }
          print("User logged in, showing HomeScreen");
          return const HomeScreen();
        }

        // Show loading indicator while checking auth state
        print("Waiting for auth state, showing loading indicator");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

// // lib/main.dart
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'services/auth_service.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/home/home_screen.dart';
// import 'config/theme.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'eLaka',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.lightTheme,
//       themeMode: ThemeMode.system,
//       home: const AuthWrapper(),
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/home': (context) => const HomeScreen(),
//       },
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: AuthService().authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           User? user = snapshot.data;
//           if (user == null) {
//             return const LoginScreen();
//           }
//           return const HomeScreen();
//         }
//
//         // Show loading indicator while checking auth state
//         return const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//   }
// }
