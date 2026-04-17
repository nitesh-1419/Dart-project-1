import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong2;

class RoutingService {
  Future<Map<String, dynamic>?> getRoute(
    latlong2.LatLng start,
    latlong2.LatLng end,
  ) async {
    // OSRM expects longitude,latitude
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          return {
            'polyline': data['routes'][0]['geometry'],
            'distance': data['routes'][0]['distance'], // meters
            'duration': data['routes'][0]['duration'], // seconds
          };
        }
      }
    } catch (e) {
      debugPrint("Routing Error: $e");
    }
    return null;
  }
}

class GeocodingService {
  Future<List<dynamic>> searchAddress(String query) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      <String, String>{
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '5',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'UberCloneApp/1.0', // Nominatim requires a user-agent
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }
    return [];
  }

  Future<List<dynamic>> searchPlaces(String query) => searchAddress(query);
}
