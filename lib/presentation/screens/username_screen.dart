import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'live_map_screen.dart'; // Menghidupkan import halaman map utama

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key}); // Memakai super.key agar linter senang

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak boleh kosong ya, Bro!')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Memanggil fungsi penyimpanan yang ada di auth_provider.dart kamu
      await authProvider.saveUsername(username);

      // 2. Cek 'mounted' setelah async gap untuk menghilangkan warning BuildContext
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username berhasil disimpan! 🔥')),
      );

      // 3. DIKONDISIKAN AKTIF: Berpindah ke layar peta utama setelah sukses disimpan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LiveMapScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memantau status isLoading dari AuthProvider secara langsung
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Satu Langkah Lagi! 🎯',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign:
                  TextAlign.center, // Menggunakan TextAlign.center yang valid
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan buat username unik untuk akun baru Anda.',
              style: TextStyle(color: Colors.grey),
              textAlign:
                  TextAlign.center, // Menggunakan TextAlign.center yang valid
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan & Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
