import 'package:flutter/material.dart';
import '../models/trip_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Trip trip;

  const BookingDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(trip.driver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Rating: ${trip.driver.rating} ⭐'),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {},
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text('${trip.vehicle.color} ${trip.vehicle.model}'),
                      subtitle: Text('Plate: ${trip.vehicle.plate}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Booking ID: ${trip.bookingId}', style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Fare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  Text(
                    '\$${trip.fare.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CANCEL RIDE', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}