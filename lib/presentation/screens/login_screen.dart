import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'live_map_screen.dart';
import 'register_screen.dart';
import 'username_screen.dart'; // Tambah import ini

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    try {
      final user = await context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        // Cek apakah user sudah punya username di Firestore
        final hasUsername = await context
            .read<AuthProvider>()
            .checkIfUsernameExists(user.uid);

        if (!mounted) return;

        if (hasUsername) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LiveMapScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UsernameScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception:", ""))),
        );
      }
    }
  }

  void _handleGoogleLogin() async {
    try {
      await context.read<AuthProvider>().signInWithGoogle();

      if (mounted) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final hasUsername = await context
              .read<AuthProvider>()
              .checkIfUsernameExists(uid);

          if (!mounted) return;

          if (hasUsername) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LiveMapScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UsernameScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal login dengan Google: ${e.toString().replaceAll("Exception:", "")}",
            ),
          ),
        );
      }
    }
  }

  void _handleFacebookLogin() async {
    try {
      final result = await context.read<AuthProvider>().signInWithFacebook();

      if (result != null && mounted) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final hasUsername = await context
              .read<AuthProvider>()
              .checkIfUsernameExists(uid);

          if (!mounted) return;

          if (hasUsername) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LiveMapScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UsernameScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal login dengan Facebook: ${e.toString().replaceAll("Exception:", "")}",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masuk untuk melihat posisi sirkelmu.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: const Color(0xFFF1ECE4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: const Color(0xFFF1ECE4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE59898),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _handleLogin,
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "atau masuk dengan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 36,
                  color: Colors.red,
                ),
                label: const Text(
                  "Masuk dengan Google",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: isLoading ? null : _handleGoogleLogin,
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF1877F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.facebook, size: 24, color: Colors.white),
                label: const Text(
                  "Masuk dengan Facebook",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: isLoading ? null : _handleFacebookLogin,
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                child: const Text(
                  "Belum punya akun? Daftar di sini",
                  style: TextStyle(color: Color(0xFFE59898)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
