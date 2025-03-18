import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _idDocument;
  bool _isLoading = false;
  bool _verificationSubmitted = false;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _idDocument = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitVerification() async {
    if (_idDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ID document')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call authentication service
      await AuthService().verifyUserIdentity(_idDocument!);

      setState(() {
        _verificationSubmitted = true;
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
        title: const Text('Verify Identity'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _verificationSubmitted
              ? _buildVerificationSubmittedContent()
              : _buildVerificationForm(),
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24.0),
        // Title
        Text(
          'Verify Your Identity',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        // Description
        Text(
          'To ensure a safe community, we need to verify your identity. Please upload a photo of your ID document (passport, driver\'s license, or ID card).',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40.0),
        // ID document upload
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200.0,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: _idDocument != null
                    ? AppTheme.primaryColor
                    : AppTheme.dividerColor,
                width: 2.0,
              ),
            ),
            child: _idDocument != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.file(
                _idDocument!,
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate,
                  size: 64.0,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Tap to upload ID document',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        // Privacy note
        Text(
          'Your ID will be securely stored and only used for verification purposes.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40.0),
        // Submit button
        PrimaryButton(
          text: 'Submit for Verification',
          onPressed: _submitVerification,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16.0),
        // Skip for now
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Skip for Now'),
        ),
      ],
    );
  }

  Widget _buildVerificationSubmittedContent() {
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
          'Verification Submitted',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        // Description
        Text(
          'Your verification request has been submitted. We\'ll review your documents and update your account status. This usually takes 1-2 business days.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40.0),
        // Continue button
        PrimaryButton(
          text: 'Continue',
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