import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call authentication service
      await AuthService().signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40.0),
                // App logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100.0,
                    // Use placeholder for example
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.shopping_basket,
                      size: 100.0,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                // Welcome text
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Sign in to continue',
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
                const SizedBox(height: 16.0),
                // Password field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24.0),
                // Login button
                PrimaryButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16.0),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
