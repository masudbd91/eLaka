// lib/screens/auth/verification_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isEmailVerified = false;
  Timer? _timer;
  int _resendTimeout = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    User? user = _authService.currentUser;

    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      // Check if email is verified
      await user.reload();
      bool isVerified = user.emailVerified;

      setState(() {
        _isEmailVerified = isVerified;
        _isLoading = false;
      });

      if (_isEmailVerified) {
        // Update verification status in Firestore
        await _authService.updateVerificationStatus(user.uid, true);

        // Navigate to home screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        // Start timer to check verification status periodically
        _timer = Timer.periodic(
          const Duration(seconds: 5),
              (_) => _checkEmailVerification(),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendTimeout > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait $_resendTimeout seconds before requesting again')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.currentUser?.sendEmailVerification();

      setState(() {
        _isLoading = false;
        _resendTimeout = 60;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
      );

      // Start countdown timer for resend button
      _resendTimer = Timer.periodic(
        const Duration(seconds: 1),
            (timer) {
          setState(() {
            if (_resendTimeout > 0) {
              _resendTimeout--;
            } else {
              _resendTimer?.cancel();
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification email: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Icon(
              _isEmailVerified ? Icons.check_circle : Icons.email,
              size: 100,
              color: _isEmailVerified ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              _isEmailVerified
                  ? 'Email Verified!'
                  : 'Verify Your Email',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _isEmailVerified
                  ? 'Your email has been successfully verified. You will be redirected to the home screen shortly.'
                  : 'We have sent a verification email to ${_authService.currentUser?.email}. Please check your inbox and click the verification link to complete your registration.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (!_isEmailVerified) ...[
              ElevatedButton(
                onPressed: _resendTimeout > 0 ? null : _resendVerificationEmail,
                child: Text(
                  _resendTimeout > 0
                      ? 'Resend Email (${_resendTimeout}s)'
                      : 'Resend Verification Email',
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Cancel and Sign Out'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
