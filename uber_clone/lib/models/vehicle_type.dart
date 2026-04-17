import 'package:flutter/material.dart';

class VehicleType {
  final String id;
  final String name;
  final String image;
  final Color color;
  final double basePricePerKm;
  final double basePricePerMin;
  final double minPrice;
  final IconData icon;

  const VehicleType({
    required this.id,
    required this.name,
    required this.image,
    required this.color,
    required this.basePricePerKm,
    required this.basePricePerMin,
    required this.minPrice,
    required this.icon,
  });

  static const List<VehicleType> types = [
    VehicleType(
      id: 'uber_x',
      name: 'UberX',
      image: 'assets/uberx.png',
      color: Color(0xFF1EB53A),
      basePricePerKm: 1.2,
      basePricePerMin: 0.3,
      minPrice: 8.0,
      icon: Icons.electrical_services,
    ),
    VehicleType(
      id: 'comfort',
      name: 'Comfort',
      image: 'assets/comfort.png',
      color: Color(0xFF2196F3),
      basePricePerKm: 1.8,
      basePricePerMin: 0.45,
      minPrice: 12.0,
      icon: Icons.local_taxi,
    ),
    VehicleType(
      id: 'black',
      name: 'Black',
      image: 'assets/black.png',
      color: Color(0xFF000000),
      basePricePerKm: 3.5,
      basePricePerMin: 0.8,
      minPrice: 25.0,
      icon: Icons.directions_car,
    ),
  ];

  static VehicleType get uberX => types[0];
  static VehicleType get uberComfort => types[1];
  static VehicleType get uberBlack => types[2];
}
