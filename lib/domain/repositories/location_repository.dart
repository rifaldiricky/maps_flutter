abstract class LocationRepository {
  Future<void> updateUserLocation(
    String userId,
    double latitude,
    double longitude,
  );
}
