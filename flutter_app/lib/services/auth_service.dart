// Low-level Firebase Authentication and user-profile operations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Coordinates Firebase Authentication with the matching Firestore profile.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser {
    return _auth.currentUser;
  }

  /// Emits Firebase sign-in and sign-out changes used by the root auth gate.
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  /// Creates a public account and forces its Firestore role to `Patient`.
  Future<UserCredential> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

    final String uid = userCredential.user!.uid;

    final UserModel userModel = UserModel(
      uid: uid,
      fullName: fullName.trim(),
      email: email.trim(),
      role: 'Patient',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(userModel.toMap());

    return userCredential;
  }

  /// Authenticates an existing Firebase email/password account.
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    return credential;
  }

  /// Terminates the current Firebase Authentication session.
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  /// Requests Firebase's email-based password recovery flow.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Loads the signed-in user's role-bearing Firestore profile.
  Future<UserModel?> getCurrentUserData() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final DocumentSnapshot document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}
