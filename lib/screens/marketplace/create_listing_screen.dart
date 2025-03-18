import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  _CreateListingScreenState createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  List<File> _images = [];
  String _selectedCategory = '';
  String _selectedSubcategory = '';
  List<Map<String, dynamic>> _categories = [];
  List<String> _subcategories = [];
  String _neighborhood = '';
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user data to determine neighborhood
      final userId = AuthService().currentUser?.uid;
      if (userId != null) {
        final userData = await DatabaseService().getUserData(userId);
        setState(() {
          _neighborhood = userData['neighborhood'];
          _locationController.text = _neighborhood;
        });
      }

      // Get categories
      final categories = await DatabaseService().getCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images.map((image) => File(image.path)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: ${e.toString()}')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedCategory = value;
      _selectedSubcategory = '';

      // Get subcategories for selected category
      final category = _categories.firstWhere(
            (category) => category['name'] == value,
        orElse: () => {'subcategories': <String>[]},
      );

      _subcategories = List<String>.from(category['subcategories']);
    });
  }

  void _onSubcategoryChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedSubcategory = value;
    });
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current position
      final position = await LocationService().getCurrentPosition();

      // Get neighborhood from coordinates
      final neighborhood = await LocationService().getNeighborhoodFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _locationController.text = neighborhood;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to detect location: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_selectedSubcategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subcategory')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse tags
      final tags = _tagsController.text.isEmpty
          ? <String>[]
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      // Create listing
      final listingId = await DatabaseService().createListing(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory,
        subcategory: _selectedSubcategory,
        images: _images,
        neighborhood: _locationController.text,
        location: _locationController.text,
        tags: tags,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing created successfully')),
      );

      // Navigate to listing detail
      Navigator.of(context).pushReplacementNamed(
        '/listing-detail',
        arguments: {'listingId': listingId},
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create listing: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              Text(
                'Photos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 120.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add image button
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 120.0,
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: AppTheme.dividerColor,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 32.0,
                                color: AppTheme.textSecondaryColor,
                              ),
                              SizedBox(height: 8.0),
                              Text('Add Photos'),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Image preview
                      final imageIndex = index - 1;
                      return Stack(
                        children: [
                          Container(
                            width: 120.0,
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: FileImage(_images[imageIndex]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4.0,
                            right: 12.0,
                            child: GestureDetector(
                              onTap: () => _removeImage(imageIndex),
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              // Title
              CustomTextField(
                label: 'Title',
                hint: 'Enter a title for your listing',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Describe your item',
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Price
              CustomTextField(
                label: 'Price',
                hint: 'Enter price (0 for free items)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Category
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                hint: const Text('Select a category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: _onCategoryChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Subcategory
              if (_selectedCategory.isNotEmpty) ...[
                Text(
                  'Subcategory',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  value: _selectedSubcategory.isEmpty ? null : _selectedSubcategory,
                  hint: const Text('Select a subcategory'),
                  items: _subcategories.map((subcategory) {
                    return DropdownMenuItem<String>(
                      value: subcategory,
                      child: Text(subcategory),
                    );
                  }).toList(),
                  onChanged: _onSubcategoryChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              // Location
              CustomTextField(
                label: 'Location',
                hint: 'Enter your neighborhood',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _detectLocation,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Tags
              CustomTextField(
                label: 'Tags (optional)',
                hint: 'Enter tags separated by commas',
                controller: _tagsController,
              ),
              const SizedBox(height: 24.0),
              // Submit button
              PrimaryButton(
                text: 'Create Listing',
                onPressed: _createListing,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}