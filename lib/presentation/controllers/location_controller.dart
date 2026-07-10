import 'package:geolocator/geolocator.dart';

enum LocationStatus { success, disabled, denied, deniedForever }

class LocationResult {
  final LocationStatus status;
  final Position? position;

  LocationResult(this.status, {this.position});
}

class LocationController {
  Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult(LocationStatus.disabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult(LocationStatus.denied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResult(LocationStatus.deniedForever);
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LocationResult(LocationStatus.success, position: position);
  }
}
