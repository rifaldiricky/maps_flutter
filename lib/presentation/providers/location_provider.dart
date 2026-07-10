import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/location_repository.dart';

class LocationProvider extends ChangeNotifier {
  final LocationRepository locationRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  bool _isTracking = false;

  LocationProvider({required this.locationRepository});

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  void startLiveTracking() {
    if (_isTracking) return;

    _isTracking = true;
    notifyListeners();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) async {
          _currentPosition = position;
          notifyListeners();

          final String? userId = _auth.currentUser?.uid;

          if (userId != null) {
            try {
              await locationRepository.updateUserLocation(
                userId,
                position.latitude,
                position.longitude,
              );
              print(
                "📍 Lokasi berhasil disinkronisasi ke Firestore: ${position.latitude}, ${position.longitude}",
              );
            } catch (e) {
              print("❌ Gagal mengirim lokasi ke Firestore: $e");
            }
          }
        });
  }

  void stopLiveTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    _currentPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopLiveTracking();
    super.dispose();
  }
}
