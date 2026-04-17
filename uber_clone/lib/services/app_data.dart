import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class AppData extends ChangeNotifier {
  LatLng? pickupLocation;
  LatLng? dropOffLocation;

  void updatePickupLocation(LatLng location) {
    pickupLocation = location;
    notifyListeners();
  }
}