// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' show asin, cos, pi, sin, sqrt;

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await checkLocationPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestLocationPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get address from coordinates
  Future<Placemark> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    return placemarks.first;
  }

  // Get coordinates from address
  Future<Location> getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    return locations.first;
  }

  // Calculate distance between two coordinates in kilometers
  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const int earthRadius = 6371; // Earth's radius in kilometers

    double latDifference = _degreesToRadians(endLatitude - startLatitude);
    double lonDifference = _degreesToRadians(endLongitude - startLongitude);

    double a = sin(latDifference / 2) * sin(latDifference / 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(lonDifference / 2) *
            sin(lonDifference / 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // Helper method to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
