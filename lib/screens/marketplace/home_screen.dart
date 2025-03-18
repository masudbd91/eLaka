import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _categories = [];
  String _neighborhood = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        });
      }

      // Get listings
      final listings = await DatabaseService().getListings(
        neighborhood: _neighborhood,
        limit: 20,
      );

      // Get categories
      final categories = await DatabaseService().getCategories();

      setState(() {
        _listings = listings;
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

  void _onSearchSubmitted(String query) {
    if (query.isEmpty) return;

    // Save search query
    PreferencesService().saveSearchQuery(query);

    // Navigate to search results
    Navigator.of(context).pushNamed(
      '/search-results',
      arguments: {'query': query},
    );
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    Navigator.of(context).pushNamed(
      '/category',
      arguments: {'category': category},
    );
  }

  void _onListingTap(Map<String, dynamic> listing) {
    Navigator.of(context).pushNamed(
      '/listing-detail',
      arguments: {'listingId': listing['id']},
    );
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Home
        setState(() {
          _currentIndex = index;
        });
        break;
      case 1: // Search
        Navigator.of(context).pushNamed('/search');
        break;
      case 2: // Sell
        Navigator.of(context).pushNamed('/create-listing');
        break;
      case 3: // Chats
        Navigator.of(context).pushNamed('/chats');
        break;
      case 4: // Profile
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_neighborhood),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchBar(
                  controller: _searchController,
                  onSearch: _onSearchSubmitted,
                  hintText: 'What are you looking for?',
                ),
              ),
              const SizedBox(height: 16.0),
              // Popular search terms
              PopularSearchTerms(
                terms: const [
                  'sofa',
                  'dresser',
                  'iphone',
                  'coffee table',
                  'tv',
                  'couch',
                  'free',
                ],
                onTermSelected: _onSearchSubmitted,
              ),
              const SizedBox(height: 24.0),
              // Categories
              SectionHeader(
                title: 'Categories',
                onSeeAll: () {
                  Navigator.of(context).pushNamed('/categories');
                },
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 120.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 100.0,
                        child: CategoryCard(
                          name: category['name'],
                          icon: IconData(
                            category['iconCodePoint'],
                            fontFamily: 'MaterialIcons',
                          ),
                          onTap: () => _onCategoryTap(category),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              // Recent listings
              SectionHeader(
                title: 'Recent Listings',
                onSeeAll: () {
                  Navigator.of(context).pushNamed('/search-results');
                },
              ),
              const SizedBox(height: 8.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: _listings.length,
                itemBuilder: (context, index) {
                  final listing = _listings[index];
                  return ListingCard(
                    title: listing['title'],
                    price: listing['price'] == 0
                        ? 'Free'
                        : '\$${listing['price'].toStringAsFixed(listing['price'].truncateToDouble() == listing['price'] ? 0 : 2)}',
                    location: listing['neighborhood'],
                    timePosted: _getTimeAgo(DateTime.parse(listing['createdAt'])),
                    imageUrl: listing['imageUrls'][0],
                    isSold: listing['status'] == 'sold',
                    onTap: () => _onListingTap(listing),
                  );
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
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
