import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<User?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<User?> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty)
      throw Exception("Email & password tidak boleh kosong");
    if (password.length < 6) throw Exception("Password minimal 6 karakter");

    _isLoading = true;
    notifyListeners();

    try {
      final user = await authRepository.register(email, password);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await authRepository.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await authRepository.signInWithFacebook();
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  Future<void> saveUsername(String username) async {
    if (username.trim().isEmpty) {
      throw Exception("Username tidak boleh kosong ya, Bro!");
    }

    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.saveUsername(username.trim());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> checkIfUsernameExists(String uid) async {
    try {
      return await authRepository.checkIfUsernameExists(uid);
    } catch (e) {
      return false;
    }
  }
}
