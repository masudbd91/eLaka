// File: lib/screens/wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'marketplace/improved_home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Return either Home or Login screen based on authentication state
    if (user == null) {
      return const LoginScreen();
    } else {
      return const ImprovedHomeScreen();
    }
  }
}
