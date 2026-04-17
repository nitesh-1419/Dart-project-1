import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/map_viewmodel.dart';
import '../models/vehicle_type.dart';
import '../widgets/ride_card.dart';
import 'search_screen.dart';
import 'ride_confirmation_screen.dart';
import '../widgets/slide_to_confirm_button.dart';

double _haversineDistance(LatLng p1, LatLng p2) {
  const double earthRadius = 6371000; // meters
  final double dLat = (p2.latitude - p1.latitude) * (math.pi / 180);
  final double dLng = (p2.longitude - p1.longitude) * (math.pi / 180);
  
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(p1.latitude * (math.pi / 180)) * math.cos(p2.latitude * (math.pi / 180)) * 
      math.sin(dLng / 2) * math.sin(dLng / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  
  return earthRadius * c / 1000; // km
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  LatLng? _startLocation;
  LatLng? _endLocation;
  bool _showStartPicker = true;
  VehicleType? _selectedVehicle;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLocationPicker() {
    setState(() {
      _showStartPicker = !_showStartPicker;
    });
  }

  void _selectVehicle(VehicleType vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
  }

  double _calculatePrice(double? dynamicDuration) {
    if (_startLocation == null || _endLocation == null || _selectedVehicle == null) return 0.0;
    final distance = _haversineDistance(_startLocation!, _endLocation!);
    final double duration = dynamicDuration ?? 10.0;
    final price = (_selectedVehicle!.basePricePerKm * distance + 
                   _selectedVehicle!.basePricePerMin * duration)
                  .clamp(_selectedVehicle!.minPrice, double.infinity);
    return price;
  }

  @override
  Widget build(BuildContext context) {
    final mapViewModel = Provider.of<MapViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapViewModel.mapController,
            options: MapOptions(
              initialCenter: const LatLng(37.7749, -122.4194),
              initialZoom: 14,
              onMapReady: () => mapViewModel.onMapCreated(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.uber_clone',
              ),
              PolylineLayer(polylines: mapViewModel.polylines),
              CircleLayer(circles: mapViewModel.circles),
              MarkerLayer(markers: mapViewModel.markers),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Location Picker Toggle
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showStartPicker ? null : _toggleLocationPicker,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Colors.white.withAlpha(20),
                                        Colors.transparent,
                                      ]),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _showStartPicker 
                                          ? Colors.green.withAlpha(100)
                                          : Colors.white.withAlpha(50),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.my_location, color: Colors.white.withAlpha(200), size: 24),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Current location', style: TextStyle(
                                                color: Colors.white.withAlpha(220),
                                                fontWeight: FontWeight.w500,
                                              )),
                                              const SizedBox(height: 4),
                                              Text(_startLocation != null 
                                                ? '${_startLocation!.latitude.toStringAsFixed(2)}, ${_startLocation!.longitude.toStringAsFixed(2)}'
                                                : 'Tap to set',
                                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_showStartPicker)
                                          Icon(Icons.check_circle, color: Colors.green, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _showStartPicker ? _toggleLocationPicker : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Colors.white.withAlpha(20),
                                      Colors.transparent,
                                    ]),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _showStartPicker 
                                        ? Colors.white.withAlpha(50)
                                        : Colors.green.withAlpha(100),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.flag, color: Colors.white.withAlpha(200), size: 24),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Destination', style: TextStyle(
                                              color: Color(0xFFE0E0E0),
                                              fontWeight: FontWeight.w500,
                                            )),
                                            const SizedBox(height: 4),
                                            Text(_endLocation != null 
                                              ? '${_endLocation!.latitude.toStringAsFixed(2)}, ${_endLocation!.longitude.toStringAsFixed(2)}'
                                              : 'Where to?',
                                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!_showStartPicker)
                                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Ride Type Selector
                        if (_startLocation != null && _endLocation != null)
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Choose ride type', style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    )),
                                    Text(
                                      '₹${_calculatePrice(mapViewModel.duration).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black45),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 200,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: VehicleType.types.map((vehicle) => PremiumRideCard(
                                      vehicleType: vehicle,
                                      distance: _startLocation != null && _endLocation != null 
                                        ? _haversineDistance(_startLocation!, _endLocation!)
                                        : 3.2,
                                      duration: mapViewModel.duration?.toDouble() ?? 10.0,
                                      price: _calculatePriceForVehicle(vehicle),
                                      isSelected: _selectedVehicle == vehicle,
                                      onTap: () => _selectVehicle(vehicle),
                                    )).toList(),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: SlideToConfirmButton(
                                    isEnabled: _selectedVehicle != null,
                                    text: 'Slide to confirm ${_selectedVehicle?.name ?? 'ride'}',
                                    onConfirm: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RideConfirmationScreen(
                                            startLocation: _startLocation!,
                                            endLocation: _endLocation!,
                                            vehicleType: _selectedVehicle!,
                                            price: _calculatePrice(mapViewModel.duration),
                                            distance: _haversineDistance(_startLocation!, _endLocation!),
                                            duration: mapViewModel.duration?.toDouble() ?? 10.0,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () => _showLocationPicker(context),
                                icon: const Icon(Icons.search, color: Colors.white),
                                label: Text(
                                  _showStartPicker ? 'Set pickup location' : 'Set destination',
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Finding Ride Overlay
          if (mapViewModel.isFindingRide)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 24),
                    const Text(
                      "Finding your ride...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'UberMove'
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connecting to drivers nearby",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SearchScreen(
        isStartLocation: _showStartPicker,
        onLocationSelected: (LatLng latLng, String address) { 
          setState(() {
            if (_showStartPicker) {
              _startLocation = latLng;
            } else {
              _endLocation = latLng;
            }
          });
          final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
          mapViewModel.setRoute(_startLocation, _endLocation);
        },
      ),
    ));
  }

  double _calculatePriceForVehicle(VehicleType vehicle) {
    if (_startLocation == null || _endLocation == null) return 0.0;
    final distance = _haversineDistance(_startLocation!, _endLocation!);
    final duration = 10.0;
    return (vehicle.basePricePerKm * distance + vehicle.basePricePerMin * duration)
           .clamp(vehicle.minPrice, double.infinity);
  }
}
