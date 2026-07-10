import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<User?> register(String email, String password) async {
    return await remoteDataSource.register(email, password);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<User?> signInWithGoogle() async {
    final credential = await remoteDataSource.signInWithGoogle();
    return credential?.user;
  }

  @override
  Future<User?> signInWithFacebook() async {
    final credential = await remoteDataSource.signInWithFacebook();
    return credential?.user;
  }

  // 👇 FUNGSI BARU UNTUK USERNAME
  @override
  Future<void> saveUsername(String username) async {
    return await remoteDataSource.saveUsername(username);
  }

  @override
  Future<bool> checkIfUsernameExists(String uid) async {
    return await remoteDataSource.checkIfUsernameExists(uid);
  }
}
