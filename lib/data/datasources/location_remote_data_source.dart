import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LocationRemoteDataSource {
  Future<void> uploadLocation(String userId, double latitude, double longitude);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final FirebaseFirestore firestore;

  LocationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> uploadLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    await firestore.collection('users').doc(userId).set({
      'location_data': {'latitude': latitude, 'longitude': longitude},
      'login_data': {'updatedAt': FieldValue.serverTimestamp()},
    }, SetOptions(merge: true));
  }
}
