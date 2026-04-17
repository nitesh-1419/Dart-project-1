import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/vehicle_type.dart';
import 'payment_screen.dart';

class RideConfirmationScreen extends StatelessWidget {
  const RideConfirmationScreen({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.vehicleType,
    required this.price,
    required this.distance,
    required this.duration,
  });

  final LatLng startLocation;
  final LatLng endLocation;
  final VehicleType vehicleType;
  final double price;
  final double distance;
  final double duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      appBar: AppBar(
        title: const Text(
          'Confirm ride',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF10251C), Color(0xFF193729)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: vehicleType.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        vehicleType.icon,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            vehicleType.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${distance.toStringAsFixed(1)} km / ${duration.toStringAsFixed(0)} min',
                            style: const TextStyle(color: Color(0xFFD3DED8)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'INR ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _LocationSummaryCard(
                title: 'Pickup',
                icon: Icons.trip_origin,
                accent: const Color(0xFF2E9156),
                subtitle:
                    '${startLocation.latitude.toStringAsFixed(4)}, ${startLocation.longitude.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 12),
              _LocationSummaryCard(
                title: 'Destination',
                icon: Icons.flag,
                accent: const Color(0xFF101514),
                subtitle:
                    '${endLocation.latitude.toStringAsFixed(4)}, ${endLocation.longitude.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 12),
              const _LocationSummaryCard(
                title: 'Ride perks',
                icon: Icons.stars_outlined,
                accent: Color(0xFFC68A29),
                subtitle:
                    'Premium cabin, cashless checkout, live driver tracking.',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PaymentScreen(price: price, vehicleType: vehicleType),
                    ),
                  );
                },
                child: const Text(
                  'Continue to payment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  side: const BorderSide(color: Color(0xFFD8CCBC)),
                ),
                child: const Text(
                  'Back to ride options',
                  style: TextStyle(
                    color: Color(0xFF101514),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSummaryCard extends StatelessWidget {
  const _LocationSummaryCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.subtitle,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5C6762),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
