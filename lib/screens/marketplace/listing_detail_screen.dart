// File: lib/screens/marketplace/listing_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/listing_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/common/primary_button.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    Key? key,
    required this.listingId,
  }) : super(key: key);

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  ListingModel? _listing;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListing();
  }

  Future<void> _loadListing() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listing = await _databaseService.getListingById(widget.listingId);

      if (mounted) {
        setState(() {
          _listing = listing;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading listing: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextImage() {
    if (_listing != null && _listing!.imageUrls.length > 1) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _listing!.imageUrls.length;
      });
    }
  }

  void _previousImage() {
    if (_listing != null && _listing!.imageUrls.length > 1) {
      setState(() {
        _currentImageIndex = (_currentImageIndex - 1 + _listing!.imageUrls.length) % _listing!.imageUrls.length;
      });
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_listing?.title ?? 'Listing Details'),
        actions: [
          if (_listing != null && _listing!.sellerId == _authService.currentUserId)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // Navigate to edit screen
                  Navigator.of(context).pushNamed(
                    '/edit-listing',
                    arguments: {'listingId': _listing!.id},
                  );
                } else if (value == 'delete') {
                  // Show delete confirmation
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Listing'),
                      content: const Text('Are you sure you want to delete this listing?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _databaseService.deleteListing(_listing!.id);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listing == null
          ? const Center(child: Text('Listing not found'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _listing!.imageUrls.isEmpty
                      ? Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64.0,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : Image.network(
                    _listing!.imageUrls[_currentImageIndex],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            size: 64.0,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_listing!.imageUrls.length > 1)
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: _previousImage,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          onPressed: _nextImage,
                        ),
                      ],
                    ),
                  ),
                // Image counter
                if (_listing!.imageUrls.length > 1)
                  Positioned(
                    bottom: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${_listing!.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Listing details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _listing!.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _listing!.price == 0
                            ? 'Free'
                            : '\$${_listing!.price.toStringAsFixed(_listing!.price.truncateToDouble() == _listing!.price ? 0 : 2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // Location and time
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _listing!.neighborhood,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Icon(
                        Icons.access_time,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _getTimeAgo(_listing!.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Category and subcategory
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          _listing!.category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_listing!.subcategory.isNotEmpty) ...[
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            _listing!.subcategory,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _listing!.description,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Tags
                  if (_listing!.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _listing!.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  // Seller info
                  Text(
                    'Seller',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          _listing!.sellerName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        _listing!.sellerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Contact buttons
                  if (_listing!.sellerId != _authService.currentUserId) ...[
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Message',
                            onPressed: () {
                              // Navigate to chat screen
                              Navigator.of(context).pushNamed(
                                '/chat',
                                arguments: {
                                  'sellerId': _listing!.sellerId,
                                  'sellerName': _listing!.sellerName,
                                  'listingId': _listing!.id,
                                  'listingTitle': _listing!.title,
                                },
                              );
                            },
                            icon: Icons.message_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
