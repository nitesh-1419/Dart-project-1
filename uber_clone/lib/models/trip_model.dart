import '../services/booking_service.dart';

class Trip {
  final String bookingId;
  final BookingStatus status;
  final Driver driver;
  final Vehicle vehicle;
  final double fare;

  Trip({
    required this.bookingId,
    required this.status,
    required this.driver,
    required this.vehicle,
    required this.fare,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      bookingId: map['bookingId'],
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.searching,
      ),
      driver: Driver.fromMap(map['driver']),
      vehicle: Vehicle.fromMap(map['vehicle']),
      fare: (map['fare'] as num).toDouble(),
    );
  }
}

class Driver {
  final String name;
  final double rating;
  final String phone;

  Driver({required this.name, required this.rating, required this.phone});

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      name: map['name'],
      rating: (map['rating'] as num).toDouble(),
      phone: map['phone'],
    );
  }
}

class Vehicle {
  final String model;
  final String plate;
  final String color;

  Vehicle({required this.model, required this.plate, required this.color});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      model: map['model'],
      plate: map['plate'],
      color: map['color'],
    );
  }
}