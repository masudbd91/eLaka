import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get current position
  Future<Position> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get current position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      throw Exception('Failed to get current position: $e');
    }
  }

  // Get neighborhood from coordinates
  Future<String> getNeighborhoodFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        throw Exception('No placemarks found for the given coordinates.');
      }

      final placemark = placemarks.first;

      // Try to get neighborhood or sublocality
      String? neighborhood = placemark.subLocality;

      if (neighborhood == null || neighborhood.isEmpty) {
        // Fall back to locality (city)
        neighborhood = placemark.locality;
      }

      if (neighborhood == null || neighborhood.isEmpty) {
        // Fall back to administrative area (state/province)
        neighborhood = placemark.administrativeArea;
      }

      return neighborhood ?? 'Unknown location';
    } catch (e) {
      throw Exception('Failed to get neighborhood: $e');
    }
  }

  // Get coordinates from address
  Future<Position> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        throw Exception('No locations found for the given address.');
      }

      final location = locations.first;

      return Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } catch (e) {
      throw Exception('Failed to get coordinates: $e');
    }
  }
}
