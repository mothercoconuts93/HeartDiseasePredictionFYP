import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

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

  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    debugPrint('[Auth] Authenticated UID: ${credential.user?.uid}');
    return credential;
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserModel?> getCurrentUserData() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      debugPrint('[Auth] No authenticated Firebase user');
      return null;
    }

    debugPrint('[Auth] Reading users/${user.uid}');

    final DocumentSnapshot document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists) {
      debugPrint('[Auth] Firestore user document does not exist');
      return null;
    }

    final data = document.data() as Map<String, dynamic>;
    debugPrint('[Auth] Firestore document data: $data');
    return UserModel.fromMap(data);
  }
}
