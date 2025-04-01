// File: lib/screens/marketplace/improved_home_screen.dart

import 'package:flutter/material.dart';
import '../../models/listing_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/marketplace/listing_card.dart';
import '../../widgets/marketplace/search_bar.dart';
import '../../widgets/marketplace/section_header.dart';
import '../../widgets/marketplace/category_card.dart';
import '../../widgets/marketplace/popular_search_terms.dart';
import '../../widgets/common/custom_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  List<ListingModel> _listings = [];
  bool _isLoading = true;

  // Sample categories (same as before)
  final List<Map<String, dynamic>> _categories = [
    // ... (same as before)
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Subscribe to the listings stream
      _databaseService.getAllListings().listen((listings) {
        if (mounted) {
          setState(() {
            _listings = listings;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error loading listings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      Navigator.of(context).pushNamed('/search-results', arguments: {
        'query': query,
      });
    }
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    Navigator.of(context).pushNamed('/search-results', arguments: {
      'category': category['name'],
    });
  }

  void _onListingTap(ListingModel listing) {
    Navigator.of(context).pushNamed('/listing-detail', arguments: {
      'listingId': listing.id,
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
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

  String _getTimeAgo(DateTime dateTime) {
    // ... (same as before)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eLaka'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadListings,
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
              _isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : _listings.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No listings available yet. Be the first to create one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
                  : GridView.builder(
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
                    title: listing.title,
                    price: listing.price == 0
                        ? 'Free'
                        : '\$${listing.price.toStringAsFixed(listing.price.truncateToDouble() == listing.price ? 0 : 2)}',
                    location: listing.neighborhood,
                    timePosted: _getTimeAgo(listing.createdAt),
                    imageUrl: listing.imageUrls.isNotEmpty ? listing.imageUrls[0] : '',
                    isSold: listing.status == ListingStatus.sold,
                    onTap: () => _onListingTap(listing),
                  );
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/create-listing');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
