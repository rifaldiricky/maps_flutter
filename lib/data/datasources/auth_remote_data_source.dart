import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class AuthRemoteDataSource {
  Future<User?> login(String email, String password);
  Future<User?> register(String email, String password);
  Future<void> logout();
  Future<UserCredential?> signInWithGoogle();
  Future<UserCredential?> signInWithFacebook();

  Future<void> saveUsername(String username);
  Future<bool> checkIfUsernameExists(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthRemoteDataSourceImpl({required this.auth});

  @override
  Future<User?> login(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<User?> register(String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = credential.user;

    if (user != null) {
      final db = FirebaseFirestore.instance;

      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'profile_data': {
          'email': user.email,
          'name': 'User Baru',
          'username': '',
          'photoUrl': '',
          'loginMethod': 'Email_Password',
        },
        'login_data': {
          'lastLogin': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'location_data': {},
      });
    }
    return user;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await auth.signInWithCredential(
      credential,
    );
    final User? user = userCredential.user;

    if (user != null) {
      final db = FirebaseFirestore.instance;

      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'profile_data': {
          'email': user.email,
          'name': user.displayName ?? 'User Google',
          'username': '',
          'photoUrl': user.photoURL ?? '',
          'loginMethod': 'Google',
        },
        'login_data': {
          'lastLogin': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'location_data': {},
      }, SetOptions(merge: true));
    }

    return userCredential;
  }

  @override
  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final db = FirebaseFirestore.instance;

        await db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'profile_data': {
            'email': user.email,
            'name': user.displayName ?? 'User Facebook',
            'username': '',
            'photoUrl': user.photoURL ?? '',
            'loginMethod': 'Facebook',
          },
          'login_data': {
            'lastLogin': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          'location_data': {},
        }, SetOptions(merge: true));
      }
      return userCredential;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
    await googleSignIn.signOut();
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print("Facebook logout diabaikan: $e");
    }
  }

  @override
  Future<void> saveUsername(String username) async {
    final user = auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(username);
      final db = FirebaseFirestore.instance;

      await db.collection('users').doc(user.uid).update({
        FieldPath(['profile_data', 'username']): username,
        FieldPath(['profile_data', 'name']): username,
        FieldPath(['login_data', 'updatedAt']): FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Gagal menyimpan, user tidak terdeteksi aktif.');
    }
  }

  @override
  Future<bool> checkIfUsernameExists(String uid) async {
    final db = FirebaseFirestore.instance;
    final doc = await db.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['profile_data'] != null) {
        final profileData = data['profile_data'] as Map<String, dynamic>;
        return profileData['username'] != null &&
            profileData['username'].toString().trim().isNotEmpty;
      }
    }
    return false;
  }
}
