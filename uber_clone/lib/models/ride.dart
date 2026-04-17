import 'package:latlong2/latlong.dart';
import 'vehicle_type.dart';

class Ride {
  final String id;
  final LatLng startLocation;
  final LatLng endLocation;
  final String startAddress;
  final String endAddress;
  final VehicleType vehicleType;
  final double distance;
  final double duration;
  final double price;
  final DateTime requestedAt;
  final RideStatus status;
  final Driver? driver;

  Ride({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
    required this.vehicleType,
    required this.distance,
    required this.duration,
    required this.price,
    required this.requestedAt,
    this.status = RideStatus.pending,
    this.driver,
  });
}

enum RideStatus {
  pending, confirmed, driverAssigned, enRoute, arrived, completed, cancelled,
}

class Driver {
  final String id;
  final String name;
  final String vehicle;
  final double rating;
  final String photo;
  final LatLng currentLocation;
  final int eta;

  Driver({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.photo,
    required this.currentLocation,
    required this.eta,
  });
}
