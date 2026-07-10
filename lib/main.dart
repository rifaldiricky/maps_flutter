import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart' as di;
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/live_map_screen.dart';
import 'presentation/screens/username_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const CircleSyncApp());
}

class CircleSyncApp extends StatelessWidget {
  const CircleSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<LocationProvider>()),
      ],
      child: MaterialApp(
        title: "CircleSync",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFDFBF7),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE59898)),
        ),
        // 👇 Ganti home dari LoginScreen() menjadi AuthWrapper()
        home: const AuthWrapper(),
      ),
    );
  }
}

// 👇 TAMBAHKAN CLASS SATPAM OTOMATIS INI DI PALING BAWAH
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Cek jika status authentikasi masih memuat data
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // 1. Jika belum login sama sekali -> Lempar ke Login
        if (user == null) {
          return const LoginScreen();
        }

        // 2. Jika sudah login -> Cek apakah UID-nya sudah punya username di Firestore
        return FutureBuilder<bool>(
          future: context.read<AuthProvider>().checkIfUsernameExists(user.uid),
          builder: (context, usernameSnapshot) {
            if (usernameSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasUsername = usernameSnapshot.data ?? false;

            if (hasUsername) {
              return const LiveMapScreen(); // Sudah punya username -> Masuk dashboard peta
            } else {
              return const UsernameScreen(); // Belum punya username -> Wajib isi dulu
            }
          },
        );
      },
    );
  }
}
