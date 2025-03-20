// File: lib/screens/marketplace/improved_create_listing_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/listing_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = '';
  String _selectedSubcategory = '';
  List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  // Sample categories and subcategories (same as before)
  final List<Map<String, dynamic>> _categories = [
    // ... (same as before)
  ];

  List<String> _subcategories = [];

  @override
  void initState() {
    super.initState();
    // Initialize location with user's neighborhood
    _locationController.text = 'Your Neighborhood';
    _loadUserNeighborhood();
  }

  Future<void> _loadUserNeighborhood() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      final user = await _databaseService.getUserData(userId);
      if (user != null && mounted) {
        setState(() {
          _locationController.text = user.neighborhood;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? value) {
    // ... (same as before)
  }

  void _onSubcategoryChanged(String? value) {
    // ... (same as before)
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          // Limit to 5 images
          if (_selectedImages.length + images.length > 5) {
            _selectedImages = [..._selectedImages, ...images].take(5).toList();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 5 images allowed')),
            );
          } else {
            _selectedImages = [..._selectedImages, ...images];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _detectLocation() async {
    // In a real app, this would use the geolocator package
    // For now, we'll just use the user's neighborhood from their profile
    final userId = _authService.currentUserId;
    if (userId != null) {
      final user = await _databaseService.getUserData(userId);
      if (user != null && mounted) {
        setState(() {
          _locationController.text = user.neighborhood;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location detected')),
        );
      }
    }
  }

  Future<void> _createListing() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Get current user
        final currentUser = _authService.currentUser;
        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        // Upload images to Firebase Storage
        final List<String> imageUrls = await _storageService.uploadImages(
          _selectedImages,
          'listings/${currentUser.id}',
        );

        // Parse tags
        List<String> tags = [];
        if (_tagsController.text.isNotEmpty) {
          tags = _tagsController.text.split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }

        // Create listing
        final listing = ListingModel(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _selectedCategory,
          subcategory: _selectedSubcategory,
          imageUrls: imageUrls,
          neighborhood: _locationController.text,
          location: _locationController.text,
          tags: tags,
          sellerId: currentUser.id,
          sellerName: currentUser.name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to Firestore
        await _databaseService.addListing(listing);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully')),
        );

        // Navigate back
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating listing: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images
                Text(
                  'Photos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _selectedImages.isEmpty
                      ? Center(
                    child: TextButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Photos'),
                    ),
                  )
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: _pickImages,
                            child: Container(
                              width: 100.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: AppTheme.dividerColor,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Container(
                              width: 100.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: FileImage(File(_selectedImages[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Rest of the form (same as before)
                // ...
              ],
            ),
          ),
        ),
      ),
    );
  }
}
