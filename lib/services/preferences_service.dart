import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _searchHistoryKey = 'search_history';
  static const String _recentViewedListingsKey = 'recent_viewed_listings';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _darkModeEnabledKey = 'dark_mode_enabled';
  static const String _locationPermissionKey = 'location_permission';

  // Save search query
  Future<void> saveSearchQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing search history
      final searchHistory = await getSearchHistory();

      // Remove query if it already exists
      searchHistory.remove(query);

      // Add query to the beginning of the list
      searchHistory.insert(0, query);

      // Limit to 10 recent searches
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }

      // Save updated search history
      await prefs.setStringList(_searchHistoryKey, searchHistory);
    } catch (e) {
      throw Exception('Failed to save search query: $e');
    }
  }

  // Get search history
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getStringList(_searchHistoryKey) ?? [];
    } catch (e) {
      throw Exception('Failed to get search history: $e');
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(_searchHistoryKey, []);
    } catch (e) {
      throw Exception('Failed to clear search history: $e');
    }
  }

  // Save recently viewed listing
  Future<void> saveRecentlyViewedListing(String listingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing recently viewed listings
      final recentViewedListings = await getRecentlyViewedListings();

      // Remove listing if it already exists
      recentViewedListings.remove(listingId);

      // Add listing to the beginning of the list
      recentViewedListings.insert(0, listingId);

      // Limit to 20 recent listings
      if (recentViewedListings.length > 20) {
        recentViewedListings.removeLast();
      }

      // Save updated recently viewed listings
      await prefs.setStringList(_recentViewedListingsKey, recentViewedListings);
    } catch (e) {
      throw Exception('Failed to save recently viewed listing: $e');
    }
  }

  // Get recently viewed listings
  Future<List<String>> getRecentlyViewedListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getStringList(_recentViewedListingsKey) ?? [];
    } catch (e) {
      throw Exception('Failed to get recently viewed listings: $e');
    }
  }

  // Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      throw Exception('Failed to set notifications enabled: $e');
    }
  }

  // Get notifications enabled
  Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      throw Exception('Failed to get notifications enabled: $e');
    }
  }

  // Set dark mode enabled
  Future<void> setDarkModeEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_darkModeEnabledKey, enabled);
    } catch (e) {
      throw Exception('Failed to set dark mode enabled: $e');
    }
  }

  // Get dark mode enabled
  Future<bool> getDarkModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_darkModeEnabledKey) ?? false;
    } catch (e) {
      throw Exception('Failed to get dark mode enabled: $e');
    }
  }

  // Set location permission
  Future<void> setLocationPermission(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_locationPermissionKey, granted);
    } catch (e) {
      throw Exception('Failed to set location permission: $e');
    }
  }

  // Get location permission
  Future<bool> getLocationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_locationPermissionKey) ?? false;
    } catch (e) {
      throw Exception('Failed to get location permission: $e');
    }
  }
}
