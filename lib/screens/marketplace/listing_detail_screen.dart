import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    Key? key,
    required this.listingId,
  }) : super(key: key);

  @override
  _ListingDetailScreenState createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _listing;
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get listing details
      final listing = await DatabaseService().getListingById(widget.listingId);

      // Check if listing is in user's favorites
      final userId = AuthService().currentUser?.uid;
      if (userId != null) {
        final userData = await DatabaseService().getUserData(userId);
        final favoriteListings = List<String>.from(userData['favoriteListings']);
        setState(() {
          _isFavorite = favoriteListings.contains(widget.listingId);
        });
      }

      setState(() {
        _listing = listing;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load listing: ${e.toString()}')),
      );

      // Navigate back
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await DatabaseService().toggleFavoriteListing(widget.listingId);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _contactSeller() async {
    if (_listing == null) return;

    try {
      final chatId = await DatabaseService().getOrCreateChat(
        widget.listingId,
        _listing!['sellerId'],
      );

      Navigator.of(context).pushNamed(
        '/chat-detail',
        arguments: {'chatId': chatId},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _viewSellerProfile() {
    if (_listing == null) return;

    Navigator.of(context).pushNamed(
      '/user-profile',
      arguments: {'userId': _listing!['sellerId']},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        actions: [
          if (!_isLoading && _listing != null)
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: _toggleFavorite,
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
            // Image gallery
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  // Images
                  PageView.builder(
                    itemCount: _listing!['imageUrls'].length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        _listing!['imageUrls'][index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppTheme.textSecondaryColor,
                                size: 64.0,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Sold overlay
                  if (_listing!['status'] == 'sold')
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Text(
                            'SOLD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Image indicators
                  if (_listing!['imageUrls'].length > 1)
                    Positioned(
                      bottom: 16.0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _listing!['imageUrls'].length,
                              (index) => Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentImageIndex
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _listing!['title'],
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        _listing!['price'] == 0
                            ? 'Free'
                            : '\$${_listing!['price'].toStringAsFixed(_listing!['price'].truncateToDouble() == _listing!['price'] ? 0 : 2)}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.primaryColor,
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
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _listing!['neighborhood'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Icon(
                        Icons.access_time,
                        size: 16.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _getTimeAgo(DateTime.parse(_listing!['createdAt'])),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  // Seller info
                  GestureDetector(
                    onTap: _viewSellerProfile,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.0,
                          backgroundImage: _listing!['sellerImageUrl'].isNotEmpty
                              ? NetworkImage(_listing!['sellerImageUrl'])
                              : null,
                          child: _listing!['sellerImageUrl'].isEmpty
                              ? Text(
                            _listing!['sellerName'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _listing!['sellerName'],
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 8.0),
                                  if (_listing!['isSellerVerified'])
                                    const Icon(
                                      Icons.verified_user,
                                      size: 16.0,
                                      color: AppTheme.successColor,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'View profile',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _listing!['description'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16.0),
                  // Category
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 16.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${_listing!['category']} > ${_listing!['subcategory']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Tags
                  if (_listing!['tags'] != null && _listing!['tags'].isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List<Widget>.from(
                        _listing!['tags'].map(
                              (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: AppTheme.surfaceColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  // Stats
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 16.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${_listing!['viewCount']} ${_listing!['viewCount'] == 1 ? 'view' : 'views'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Icon(
                        Icons.favorite_border,
                        size: 16.0,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${_listing!['favoriteCount']} ${_listing!['favoriteCount'] == 1 ? 'favorite' : 'favorites'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80.0), // Space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading || _listing == null
          ? null
          : Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Favorite button
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? AppTheme.primaryColor : null,
              ),
              onPressed: _toggleFavorite,
            ),
            const SizedBox(width: 16.0),
            // Contact button
            Expanded(
              child: PrimaryButton(
                text: _listing!['status'] == 'sold'
                    ? 'Item Sold'
                    : 'Contact Seller',
                onPressed: _listing!['status'] == 'sold'
                    ? null
                    : _contactSeller,
                isLoading: false,
              ),
            ),
          ],
        ),
      ),
    );
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
}
