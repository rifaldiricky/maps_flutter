import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../controllers/location_controller.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import 'login_screen.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final LocationController _locationController = LocationController();
  GoogleMapController? mapController;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  LatLng _currentPosition = const LatLng(1.0828, 104.0321);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });

    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.disabled && mounted) {
        _showGpsDialog(
          "GPS Kamu Mati! 📍",
          "Aplikasi CircleSync butuh GPS aktif. Yuk, nyalain dulu!",
          true,
        );
      }
    });
  }

  @override
  void dispose() {
    _serviceStatusStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (mapController == null && !_isLoading) return;

    final result = await _locationController.getCurrentLocation();

    if (!mounted) return;

    switch (result.status) {
      case LocationStatus.success:
        if (result.position != null) {
          setState(() {
            _currentPosition = LatLng(
              result.position!.latitude,
              result.position!.longitude,
            );
            _isLoading = false;
          });
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition, 16.0),
          );

          context.read<LocationProvider>().startLiveTracking();
        }
        break;

      case LocationStatus.disabled:
        setState(() => _isLoading = false);
        _showGpsDialog(
          "GPS Mati 📍",
          "Nyalakan layanan lokasi (GPS) kamu biar bisa pakai peta.",
          true,
        );
        break;

      case LocationStatus.denied:
        setState(() => _isLoading = false);
        _showGpsDialog(
          "Izin Ditolak ❌",
          "Aplikasi butuh izin lokasi untuk melacak memorimu.",
          false,
        );
        break;

      case LocationStatus.deniedForever:
        setState(() => _isLoading = false);
        _showGpsDialog(
          "Izin Ditolak Permanen 🔒",
          "Izin lokasi diblokir. Tolong aktifkan manual di pengaturan HP kamu ya.",
          true,
        );
        break;
    }
  }

  void _showGpsDialog(String title, String message, bool openSettings) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (openSettings) {
                Geolocator.openLocationSettings();
              } else {
                _initLocation();
              }
            },
            child: Text(openSettings ? "Buka Pengaturan" : "Coba Lagi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Map Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2D42),
          ),
        ),
        backgroundColor: const Color(0xFFB5E4CA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF2B2D42)),
            onPressed: _initLocation,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE59898)),
            onPressed: () async {
              context.read<LocationProvider>().stopLiveTracking();
              await context.read<AuthProvider>().logout();

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          setState(() {
            _isLoading = false;
          });
          _initLocation();
        },
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 16.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
