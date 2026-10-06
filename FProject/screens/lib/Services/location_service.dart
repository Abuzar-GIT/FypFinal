import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized service for all geolocation, coordinate parsing,
/// distance calculation, and tracking functionality.
class LocationService {
  /// Check if location service is enabled and request permissions if needed.
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current GPS position with high accuracy.
  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint("Error fetching current position: $e");
      return null;
    }
  }

  /// Format a Position to "lat,lng" string.
  static String formatPosition(Position? pos) {
    if (pos == null) return "Unknown";
    return "${pos.latitude.toStringAsFixed(6)},${pos.longitude.toStringAsFixed(6)}";
  }

  /// Parse coordinates from either "lat,lng" or "https://www.google.com/maps?q=lat,lng".
  static ({double lat, double lng})? parseCoordinates(String? locationStr) {
    if (locationStr == null || locationStr.trim().isEmpty) return null;

    String clean = locationStr.trim();

    // Check if it is a Google Maps URL
    if (clean.contains("q=")) {
      final queryPart = clean.split("q=").last;
      clean = queryPart.split("&").first;
    }

    if (clean.contains(",")) {
      final parts = clean.split(",");
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          return (lat: lat, lng: lng);
        }
      }
    }

    return null;
  }

  /// Calculate distance between two coordinates in kilometers using the Haversine formula.
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Generate a Google Maps web search link for standard external viewing.
  static String getGoogleMapsUrl(double lat, double lng) {
    return "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
  }

  /// Open Google Maps application or browser with coordinates.
  static Future<bool> openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching Google Maps: $e");
      return false;
    }
  }

  /// Open Google Maps using a location string (parses coordinates or raw string).
  static Future<bool> openGoogleMapsWithLocation(String locationStr) async {
    final coords = parseCoordinates(locationStr);
    final Uri uri;
    if (coords != null) {
      uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${coords.lat},${coords.lng}");
    } else {
      uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationStr.trim())}");
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching Google Maps URL: $e");
      return false;
    }
  }
}

