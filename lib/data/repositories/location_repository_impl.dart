import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateUserLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    await remoteDataSource.uploadLocation(userId, latitude, longitude);
  }
}
