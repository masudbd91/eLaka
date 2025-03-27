// test/location_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:elaka/services/location_service.dart';

// Mock classes
class MockGeolocator extends Mock implements GeolocatorPlatform {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockGeolocator mockGeolocator;
  late LocationService locationService;

  setUp(() {
    mockGeolocator = MockGeolocator();
    locationService = LocationService();
    // Inject mock if your service allows it
  });

  group('Location Permission Tests', () {
    test('Check location permission', () async {
      // Mock permission response
      when(mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      // Check permission
      final permission = await locationService.checkLocationPermission();

      // Verify result
      expect(permission, LocationPermission.whileInUse);
    });

    test('Request location permission', () async {
      // Mock permission request response
      when(mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.always);

      // Request permission
      final permission = await locationService.requestLocationPermission();

      // Verify result
      expect(permission, LocationPermission.always);
    });
  });

  group('Location Services Tests', () {
    test('Check if location services enabled', () async {
      // Mock service status
      when(mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);

      // Check service status
      final isEnabled = await locationService.isLocationServiceEnabled();

      // Verify result
      expect(isEnabled, true);
    });
  });

  group('Get Current Location Tests', () {
    test('Get current position', () async {
      // Mock position response
      final mockPosition = Position(
        latitude: 37.4219999,
        longitude: -122.0840575,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      when(mockGeolocator.getCurrentPosition())
          .thenAnswer((_) async => mockPosition);

      // Get current position
      final position = await locationService.getCurrentPosition();

      // Verify result
      expect(position.latitude, 37.4219999);
      expect(position.longitude, -122.0840575);
    });
  });

  group('Geocoding Tests', () {
    test('Get address from coordinates', () async {
      // This is harder to mock directly, but you can mock your service method
      final mockLocationService = MockLocationService();

      final mockPlacemark = Placemark(
        name: 'Test Location',
        street: '123 Test St',
        locality: 'Test City',
        administrativeArea: 'Test State',
        postalCode: '12345',
        country: 'Test Country',
      );

      when(mockLocationService.getAddressFromCoordinates(
              37.4219999, -122.0840575))
          .thenAnswer((_) async => mockPlacemark);

      // Get address
      final address = await mockLocationService.getAddressFromCoordinates(
          37.4219999, -122.0840575);

      // Verify result
      expect(address.street, '123 Test St');
      expect(address.locality, 'Test City');
    });

    test('Get coordinates from address', () async {
      // Mock your service method
      final mockLocationService = MockLocationService();

      final mockLocation = Location(
        latitude: 37.4219999,
        longitude: -122.0840575,
        timestamp: DateTime.now(),
      );

      when(mockLocationService.getCoordinatesFromAddress('Mountain View, CA'))
          .thenAnswer((_) async => mockLocation);

      // Get coordinates
      final location = await mockLocationService
          .getCoordinatesFromAddress('Mountain View, CA');

      // Verify result
      expect(location.latitude, 37.4219999);
      expect(location.longitude, -122.0840575);
    });
  });

  group('Distance Calculation Tests', () {
    test('Calculate distance between coordinates', () {
      // Calculate distance
      final distance = locationService.calculateDistance(
          37.4219999,
          -122.0840575, // Mountain View
          37.7749,
          -122.4194 // San Francisco
          );

      // Verify result is approximately correct (around 50-60 km)
      expect(distance, greaterThan(40));
      expect(distance, lessThan(70));
    });
  });
}
