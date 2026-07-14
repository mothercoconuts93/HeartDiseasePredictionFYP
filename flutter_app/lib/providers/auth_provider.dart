import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<void>? _currentUserLoad;
  String? _currentUserLoadUid;

  UserModel? currentUserData;
  bool isLoading = false;
  String? errorMessage;

  User? get firebaseUser {
    return _authService.currentUser;
  }

  bool get isLoggedIn {
    return firebaseUser != null;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.registerUser(
        fullName: fullName,
        email: email,
        password: password,
      );

      currentUserData = await _authService.getCurrentUserData();
      debugPrint('[AuthProvider] Loaded role: ${currentUserData?.role}');

      isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    var authenticated = false;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.loginUser(email: email, password: password);
      authenticated = true;

      await loadCurrentUserData();

      isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      if (authenticated) {
        try {
          await _authService.logoutUser();
        } catch (logoutError) {
          debugPrint('[AuthProvider] Failed to sign out: $logoutError');
        }
      }

      currentUserData = null;
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logoutUser();
    currentUserData = null;
    notifyListeners();
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email: email);

      isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      isLoading = false;
      errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<void> loadCurrentUserData() {
    final uid = _authService.currentUser?.uid;

    if (uid == null) {
      currentUserData = null;
      return Future.value();
    }

    if (currentUserData?.uid == uid) {
      return Future.value();
    }

    if (_currentUserLoadUid == uid && _currentUserLoad != null) {
      return _currentUserLoad!;
    }

    currentUserData = null;
    _currentUserLoadUid = uid;
    final load = _loadCurrentUserData(uid);
    _currentUserLoad = load;
    return load;
  }

  Future<void> _loadCurrentUserData(String uid) async {
    try {
      final userData = await _authService.getCurrentUserData();

      if (_authService.currentUser?.uid != uid) {
        throw StateError('Authenticated user changed while loading profile');
      }

      if (userData == null) {
        throw StateError('Firestore user profile not found');
      }

      currentUserData = userData;
      debugPrint('[AuthProvider] Loaded role: ${currentUserData?.role}');
    } finally {
      if (_currentUserLoadUid == uid) {
        _currentUserLoad = null;
        _currentUserLoadUid = null;
      }
    }
  }
}
