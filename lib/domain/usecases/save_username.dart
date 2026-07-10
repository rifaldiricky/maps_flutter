import '../repositories/auth_repository.dart';

class SaveUsername {
  final AuthRepository repository;

  SaveUsername(this.repository);

  Future<void> call(String username) async {
    if (username.isEmpty) {
      throw Exception('Username tidak boleh kosong, Bro!');
    }
    if (username.length < 3) {
      throw Exception('Username minimal 3 karakter ya!');
    }
    return await repository.saveUsername(username);
  }
}
