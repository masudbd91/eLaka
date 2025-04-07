import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
// import 'package:marketplace/theme/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../services/preferences_service.dart';
import '../../widgets/marketplace/category_card.dart';
import '../../widgets/marketplace/listing_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _categories = [];

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
      // Get search history
      final searchHistory = await PreferencesService().getSearchHistory();

      // Get categories
      final categories = await DatabaseService().getCategories();

      setState(() {
        _searchHistory = searchHistory;
        _categories = categories.cast<Map<String, dynamic>>();
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

  void _clearSearchHistory() async {
    try {
      await PreferencesService().clearSearchHistory();
      setState(() {
        _searchHistory = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to clear search history: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'What are you looking for?',
                      onSubmitted: (value) {
                        _onSearchSubmitted(value);
                      },
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Search history
                  if (_searchHistory.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Searches',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: _clearSearchHistory,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(_searchHistory[index]),
                          onTap: () =>
                              _onSearchSubmitted(_searchHistory[index]),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                  ],
                  const SizedBox(height: 16.0),
                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return CategoryCard(
                        name: category['name'],
                        icon: IconData(
                          category['iconCodePoint'],
                          fontFamily: 'MaterialIcons',
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/category',
                            arguments: {'category': category},
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
    );
  }
}

class SearchResultsScreen extends StatefulWidget {
  final String? query;
  final String? category;

  const SearchResultsScreen({
    super.key,
    this.query,
    this.category,
  });

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _listings = [];
  String _title = 'Search Results';

  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      _searchController.text = widget.query!;
      _title = 'Results for "${widget.query}"';
    } else if (widget.category != null) {
      _title = widget.category!;
    }
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
      // Get listings based on query or category
      final listings = await DatabaseService().getListings(
        query: widget.query,
        category: widget.category,
        limit: 50,
      );

      setState(() {
        _listings = listings;
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

    // Update state and reload data
    setState(() {
      _title = 'Results for "$query"';
    });

    // Navigate to new search results
    Navigator.of(context).pushReplacementNamed(
      '/search-results',
      arguments: {'query': query},
    );
  }

  void _onListingTap(Map<String, dynamic> listing) {
    Navigator.of(context).pushNamed(
      '/listing-detail',
      arguments: {'listingId': listing['id']},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'What are you looking for?',
              onSubmitted: (value) {
                _onSearchSubmitted(value);
              },
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16.0),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_listings.length} ${_listings.length == 1 ? 'result' : 'results'} found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _listings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'No results found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Try a different search term or category.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                              timePosted: _getTimeAgo(
                                  DateTime.parse(listing['createdAt'])),
                              imageUrl: listing['imageUrls'][0],
                              isSold: listing['status'] == 'sold',
                              onTap: () => _onListingTap(listing),
                            );
                          },
                        ),
                      ),
          ),
        ],
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
