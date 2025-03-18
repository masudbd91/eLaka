import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call authentication service
      await AuthService().resetPassword(_emailController.text.trim());

      setState(() {
        _resetSent = true;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _resetSent
              ? _buildResetSentContent()
              : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40.0),
          // Icon
          const Icon(
            Icons.lock_reset,
            size: 80.0,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24.0),
          // Title
          Text(
            'Forgot Password',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          // Description
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40.0),
          // Email field
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          // Reset button
          PrimaryButton(
            text: 'Reset Password',
            onPressed: _resetPassword,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16.0),
          // Back to login
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetSentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40.0),
        // Success icon
        const Icon(
          Icons.check_circle,
          size: 80.0,
          color: AppTheme.successColor,
        ),
        const SizedBox(height: 24.0),
        // Title
        Text(
          'Email Sent',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        // Description
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}. Please check your email and follow the instructions to reset your password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40.0),
        // Back to login
        PrimaryButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pop();
          },
          isLoading: false,
        ),
      ],
    );
  }
}

class AuthService {
  // Current user
  firebase_auth.User? get currentUser => null;

  // Sign in with email and password
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // This is a simplified example
    throw UnimplementedError('This is a code example only');
  }

  // Register with email and password
  Future<firebase_auth.UserCredential> registerWithEmailAndPassword(
      String email,
      String password,
      String name,
      String phoneNumber,
      String neighborhood,
      ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // This is a simplified example
    throw UnimplementedError('This is a code example only');
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // This is a simplified example
    return;
  }

  // Verify user identity
  Future<void> verifyUserIdentity(File idDocument) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // This is a simplified example
    return;
  }
}

// Location service class (simplified for this example)
class LocationService {
  // Get current position
  Future<Position> getCurrentPosition() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // This is a simplified example
    return Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  // Get neighborhood from coordinates
  Future<String> getNeighborhoodFromCoordinates(double latitude, double longitude) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // This is a simplified example
    return 'Sample Neighborhood';
  }
}

// Position class (simplified for this example)
class Position {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedAccuracy;

  Position({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
  });
}

// App theme class (simplified for this example)
class AppTheme {
  static const Color primaryColor = Color(0xFFFF7E1D);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color surfaceColor = Color(0xFFF5F5F5);
}

// Custom text field widget (simplified for this example)
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// Primary button widget (simplified for this example)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.0,
        ),
      )
          : Text(text),
    );
  }
}
