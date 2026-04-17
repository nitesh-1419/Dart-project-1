import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/map_services.dart';

class MapViewModel extends ChangeNotifier {
  static final LatLng fallbackLocation = LatLng(12.9716, 77.5946);

  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();
  final GeocodingService _searchService = GeocodingService();
  final MapController _mapController = MapController();
  StreamSubscription? _locationSubscription;
  void Function(LatLng target, double zoom)? _moveCameraTo;
  void Function(LatLngBounds bounds, double padding)? _fitCameraToBounds;

  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String? _pickupAddress;
  String? _destinationAddress;

  double? _distance; // Added missing distance getter
  double? _duration; // Added duration in minutes
  List<Polyline> _polylines = [];
  List<CircleMarker> _circles = [];
  bool _isFindingRide = false;
  Timer? _pulseTimer;
  final Map<String, Marker> _markers = {};

  List<dynamic> _searchResults = [];

  bool _isLoading = false;
  bool _hasLoadedInitialLocation = false;

  static const String _mapStyle = '''[
      {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
      {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
      {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
      {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
      {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
      {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
    ]''';

  LatLng? get currentLocation => _currentLocation;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get destinationLocation => _destinationLocation;
  String? get pickupAddress => _pickupAddress;
  String? get destinationAddress => _destinationAddress;
  double? get distance => _distance;
  double? get duration => _duration;
  List<Polyline> get polylines => _polylines;
  List<CircleMarker> get circles => _circles;
  List<Marker> get markers => _markers.values.toList();
  bool get isLoading => _isLoading;
  bool get isFindingRide => _isFindingRide;
  List<dynamic> get searchResults => _searchResults;
  String get mapStyle => _mapStyle;
  MapController get mapController => _mapController;
  LatLng get initialMapTarget =>
      _pickupLocation ?? _currentLocation ?? fallbackLocation;

  void onMapCreated() {
    attachMapCallbacks(
      moveCameraTo: (target, zoom) {
        _mapController.move(target, zoom);
      },
      fitBounds: (bounds, padding) {
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(padding)),
        );
      },
    );
  }

  void attachMapCallbacks({
    required void Function(LatLng target, double zoom) moveCameraTo,
    required void Function(LatLngBounds bounds, double padding) fitBounds,
  }) {
    _moveCameraTo = moveCameraTo;
    _fitCameraToBounds = fitBounds;
    _moveCameraTo?.call(initialMapTarget, _currentLocation == null ? 11 : 15);
  }

  void detachMapCallbacks() {
    _moveCameraTo = null;
    _fitCameraToBounds = null;
  }

  Future<void> ensureCurrentLocationLoaded() async {
    if (_hasLoadedInitialLocation || _isLoading) {
      return;
    }
    await fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final loc = await _locationService.getCurrentLocation();
      if (loc != null) {
        _currentLocation = LatLng(loc.latitude, loc.longitude);
        _pickupAddress ??= 'Current location';
      } else {
        _currentLocation ??= fallbackLocation;
        _pickupAddress ??= 'Bengaluru city center';
      }

      _pickupLocation ??= _currentLocation;
      _updateUserMarker();
      _moveCameraTo?.call(_currentLocation!, loc == null ? 11 : 15);
      _startUserPulse();
      _hasLoadedInitialLocation = true;
      _startLocationUpdates();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startUserPulse() {
    _pulseTimer?.cancel();
    double radius = 0;
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_currentLocation == null) return;
      radius = (radius + 5) % 300;
      _circles = [
        CircleMarker(
          point: _currentLocation!,
          radius: radius,
          useRadiusInMeter: true,
          color: Colors.blue.withOpacity((1 - (radius / 300)) * 0.3),
          borderColor: Colors.blue.withOpacity((1 - (radius / 300)) * 0.5),
          borderStrokeWidth: 1,
        ),
      ];
      notifyListeners();
    });
  }

  void _startLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.getLocationStream().listen(
      (position) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _pickupLocation ??= _currentLocation;
        _pickupAddress ??= 'Current location';
        _updateUserMarker();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Location stream failed: $error');
      },
    );
  }

  void _updateUserMarker() {
    if (_currentLocation == null) return;
    _markers['user'] = Marker(
      point: _currentLocation!,
      child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
    );
    notifyListeners();
  }

  void setRoute(LatLng? start, LatLng? end) {
    if (start != null && end != null) {
      _pickupLocation = start;
      _destinationLocation = end;
      _updateRoute();
    }
  }

  Future<void> startFindingRide() async {
    _isFindingRide = true;
    notifyListeners();

    // Simulate driver searching delay
    await Future.delayed(const Duration(seconds: 3));

    if (_pickupLocation != null) {
      _simulateDriverArrival();
    }
  }

  void _simulateDriverArrival() {
    // Create a driver starting point slightly offset from pickup
    final driverStart = LatLng(
      _pickupLocation!.latitude + 0.005,
      _pickupLocation!.longitude + 0.005,
    );

    int steps = 100;
    int currentStep = 0;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (currentStep >= steps) {
        timer.cancel();
        _isFindingRide = false;
        notifyListeners();
        return;
      }

      double lat =
          driverStart.latitude +
          (currentStep / steps) *
              (_pickupLocation!.latitude - driverStart.latitude);
      double lng =
          driverStart.longitude +
          (currentStep / steps) *
              (_pickupLocation!.longitude - driverStart.longitude);

      _markers['driver'] = Marker(
        point: LatLng(lat, lng),
        child: Transform.rotate(
          angle: 90 * (3.14159 / 180),
          child: const Icon(Icons.directions_car, color: Colors.yellow, size: 40),
        ),
      );

      currentStep++;
      notifyListeners();
    });
  }

  Future<void> searchPlaces(String query) async {
    if (query.length < 3) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _searchResults = await _searchService.searchAddress(query);
    notifyListeners();
  }

  void setPickup(LatLng location, String address) {
    _pickupLocation = location;
    _pickupAddress = address;
    _markers['pickup'] = Marker(
      point: _pickupLocation!,
      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
    );
    _updateRoute();
  }

  void setDestination(LatLng location, String address) {
    _destinationLocation = location;
    _destinationAddress = address;
    _markers['destination'] = Marker(
      point: _destinationLocation!,
      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
    );
    _searchResults = [];
    _updateRoute();
  }

  Future<void> _updateRoute() async {
    if (_pickupLocation != null && _destinationLocation != null) {
      _isLoading = true;
      notifyListeners();

      final start = _pickupLocation!;
      final end = _destinationLocation!;

      try {
        final routeData = await _routingService.getRoute(
          LatLng(start.latitude, start.longitude),
          LatLng(end.latitude, end.longitude),
        );

        if (routeData != null) {
          _distance = (routeData['distance'] as num).toDouble();
          _duration =
              (routeData['duration'] as num).toDouble() /
              60; // Convert seconds to minutes
          final List<LatLng> polylinePointsList = _decodePolyline(
            routeData['polyline'],
          );
          _polylines = [
            Polyline(
              points: polylinePointsList,
              color: Colors.black,
              strokeWidth: 5,
            ),
          ];

          if (start.latitude != end.latitude || start.longitude != end.longitude) {
            LatLngBounds bounds = LatLngBounds.fromPoints([start, end]);
            _fitCameraToBounds?.call(bounds, 50);
          }
        }
      } catch (e) {
        debugPrint('Error updating route: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }
}
