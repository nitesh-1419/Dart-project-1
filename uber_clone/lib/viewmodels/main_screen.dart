import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/vehicle_type.dart';
import '../views/account_screen.dart';
import '../views/activity_screen.dart';
import '../views/ride_confirmation_screen.dart';
import '../views/search_screen.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/adaptive_ride_map.dart';
import '../widgets/ride_card.dart';
import '../widgets/slide_to_confirm_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  int _selectedIndex = 0;
  VehicleType _selectedVehicle = VehicleType.uberX;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<MapViewModel>().ensureCurrentLocationLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSearch(BuildContext context, MapViewModel model, bool isPickup) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SearchScreen(
          isStartLocation: isPickup,
          onLocationSelected: (LatLng latLng, String address) {
            if (isPickup) {
              model.setPickup(latLng, address);
              _pickupController.text = address;
            } else {
              model.setDestination(latLng, address);
              _searchController.text = address;
            }
          },
        ),
      ),
    );
  }

  double _calculatePrice(VehicleType vehicle, MapViewModel model) {
    final distanceInKm = (model.distance ?? 3200) / 1000;
    final durationInMinutes = model.duration ?? 12;

    return (vehicle.basePricePerKm * distanceInKm +
            vehicle.basePricePerMin * durationInMinutes)
        .clamp(vehicle.minPrice, double.infinity);
  }

  void _continueToConfirmation(BuildContext context, MapViewModel model) {
    if (model.pickupLocation == null || model.destinationLocation == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RideConfirmationScreen(
          startLocation: model.pickupLocation!,
          endLocation: model.destinationLocation!,
          vehicleType: _selectedVehicle,
          price: _calculatePrice(_selectedVehicle, model),
          distance: (model.distance ?? 0) / 1000,
          duration: model.duration ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MapViewModel>();

    if (_pickupController.text.isEmpty && model.pickupAddress != null) {
      _pickupController.text = model.pickupAddress!;
    }
    if (_searchController.text.isEmpty && model.destinationAddress != null) {
      _searchController.text = model.destinationAddress!;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _buildHomeTab(context, model),
          const ActivityScreen(),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, MapViewModel model) {
    final bool hasDestination = model.destinationLocation != null;
    final mediaQuery = MediaQuery.of(context);
    final bool isCompactLayout =
        mediaQuery.size.height < 720 || mediaQuery.size.width < 1100;

    return Stack(
      children: <Widget>[
        AdaptiveRideMap(
          model: model,
          padding: EdgeInsets.only(
            top: isCompactLayout ? 148 : 180,
            bottom: isCompactLayout ? 236 : 320,
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.90),
                  Colors.white.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: isCompactLayout
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    children: <Widget>[
                      _buildTopPanel(context, model, compact: true),
                      const SizedBox(height: 16),
                      _buildBottomPanel(
                        context,
                        model,
                        hasDestination,
                        compact: true,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Column(
                    children: <Widget>[
                      _buildTopPanel(context, model),
                      const Spacer(),
                      _buildBottomPanel(context, model, hasDestination),
                    ],
                  ),
                ),
        ),
        if (isCompactLayout)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (model.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.08),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Color(0xFF133C2B)),
          ),
      ],
    );
  }

  Widget _buildTopPanel(
    BuildContext context,
    MapViewModel model, {
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(compact ? 24 : 28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: compact ? 22 : 28,
            offset: Offset(0, compact ? 10 : 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF101514),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Uber',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1E8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.flash_on, size: 16, color: Color(0xFFC68A29)),
                    SizedBox(width: 6),
                    Text(
                      'Priority pickup',
                      style: TextStyle(
                        color: Color(0xFF36413D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 16),
          Text(
            'Book a ride that feels effortless.',
            style: TextStyle(
              fontSize: compact ? 22 : 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101514),
            ),
          ),
          SizedBox(height: compact ? 14 : 18),
          _LocationField(
            icon: Icons.trip_origin,
            iconColor: const Color(0xFF2E9156),
            label: 'Pickup',
            value: _pickupController.text,
            hintText: 'Choose a pickup point',
            onTap: () => _openSearch(context, model, true),
          ),
          SizedBox(height: compact ? 10 : 12),
          _LocationField(
            icon: Icons.flag,
            iconColor: const Color(0xFF101514),
            label: 'Destination',
            value: _searchController.text,
            hintText: 'Where are you headed?',
            onTap: () => _openSearch(context, model, false),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    MapViewModel model,
    bool hasDestination, {
    bool compact = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 18),
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 20,
        compact ? 16 : 18,
        compact ? 18 : 20,
        compact ? 18 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101514),
        borderRadius: BorderRadius.circular(compact ? 26 : 30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: compact ? 24 : 32,
            offset: Offset(0, compact ? 10 : 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Ride options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 20 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasDestination
                      ? '${((model.distance ?? 0) / 1000).toStringAsFixed(1)} km'
                      : 'Set destination',
                  style: const TextStyle(
                    color: Color(0xFFE6DCCB),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            hasDestination
                ? model.destinationAddress ?? 'Destination selected'
                : 'Add a destination to unlock live route estimates and pricing.',
            style: const TextStyle(color: Color(0xFFB8C3BE), height: 1.45),
          ),
          SizedBox(height: compact ? 14 : 18),
          if (hasDestination) ...<Widget>[
            SizedBox(
              height: compact ? 138 : 156,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: VehicleType.types.length,
                separatorBuilder: (context, index) => const SizedBox(width: 2),
                itemBuilder: (context, index) {
                  final vehicle = VehicleType.types[index];
                  return PremiumRideCard(
                    vehicleType: vehicle,
                    distance: (model.distance ?? 0) / 1000,
                    duration: model.duration ?? 12,
                    price: _calculatePrice(vehicle, model),
                    isSelected: vehicle.id == _selectedVehicle.id,
                    onTap: () {
                      setState(() {
                        _selectedVehicle = vehicle;
                      });
                    },
                  );
                },
              ),
            ),
          ] else ...<Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const <Widget>[
                _InfoChip(icon: Icons.bedtime_outlined, label: 'Quiet ride'),
                _InfoChip(
                  icon: Icons.shield_outlined,
                  label: 'Trip safety tools',
                ),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  label: 'Clear fare preview',
                ),
              ],
            ),
            SizedBox(height: compact ? 14 : 18),
          ],
          SizedBox(height: compact ? 14 : 18),
          SlideToConfirmButton(
            isEnabled: hasDestination,
            text: hasDestination
                ? 'Slide to continue with ${_selectedVehicle.name}'
                : 'Select destination first',
            onConfirm: () => _continueToConfirmation(context, model),
          ),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.hintText,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value.trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4EC),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6A746F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasValue ? value : hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: hasValue
                          ? const Color(0xFF101514)
                          : const Color(0xFF84908A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6A746F)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: const Color(0xFFC68A29), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
