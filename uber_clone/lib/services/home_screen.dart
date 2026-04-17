import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/booking_service.dart';
import '../models/trip_model.dart';
import 'booking_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final BookingService _bookingService = BookingService();
  
  Position? _currentPosition;
  LatLng? _destinationLatLng;
  bool _isBooking = false;
  final List<Polyline> _polylines = [];
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    final pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _currentPosition = pos;
        final point = LatLng(pos.latitude, pos.longitude);
        _markers.add(
          Marker(
            point: point,
            child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ),
        );
      });
    }
  }

  Future<void> _handleContinue() async {
    if (_currentPosition == null || _destinationLatLng == null) return;

    setState(() => _isBooking = true);

    try {
      // Trigger the booking logic
      final result = await _bookingService.createBooking(
        pickupLocation: _currentPosition!,
        destinationLocation: Position(
          latitude: _destinationLatLng!.latitude,
          longitude: _destinationLatLng!.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          isMocked: false,
        ),
        vehicleType: 'UberX',
        estimatedFare: 25.50,
      );

      if (result != null && mounted) {
        final trip = Trip.fromMap(result);
        
        // Navigate to details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(trip: trip),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? mapCenter = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          _buildMapLayer(mapCenter),
          
          // Top Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Where to?',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (value) {
                  final mockDest = LatLng(
                    _currentPosition!.latitude + 0.02, 
                    _currentPosition!.longitude + 0.02
                  );
                  setState(() {
                    _destinationLatLng = mockDest;
                    _markers.add(
                      Marker(
                        point: mockDest,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    );
                    _polylines.add(Polyline(
                      points: [
                        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        mockDest
                      ],
                      color: Colors.black,
                      strokeWidth: 4,
                    ));
                  });
                },
              ),
            ),
          ),

          // Bottom Action Area (The "Continue" Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ElevatedButton(
                onPressed: (_isBooking || _destinationLatLng == null) ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: _isBooking 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CONTINUE', 
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayer(LatLng? center) {
    if (center == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.uber_clone',
        ),
        PolylineLayer(polylines: _polylines),
        MarkerLayer(markers: _markers),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
            ),
          ],
        ),
      ],
    );
  }
}