import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Requests permission (if needed) and returns the device's
  /// current position. Returns null if permission is denied
  /// or location services are off.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 8),
      );
    } catch (e) {
      return null;
    }
  }

  /// Returns the distance in kilometers between the device
  /// and a given doctor's coordinates.
  static double distanceInKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final meters = Geolocator.distanceBetween(
      fromLat,
      fromLng,
      toLat,
      toLng,
    );

    return meters / 1000;
  }
}