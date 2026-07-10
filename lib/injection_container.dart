import 'package:circlesync/domain/usecases/save_username.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';

import 'data/datasources/location_remote_data_source.dart';
import 'data/repositories/location_repository_impl.dart';
import 'domain/repositories/location_repository.dart';
import 'presentation/providers/location_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Exteernal
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  //============AUTH FEATURE==============
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => AuthProvider(authRepository: sl()));

  //=============LOCATION FEATURE==========
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => LocationProvider(locationRepository: sl()));

  //usecase
  sl.registerLazySingleton(() => SaveUsername(sl()));
}
