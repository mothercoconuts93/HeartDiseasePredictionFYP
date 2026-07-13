import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.loginUser(email: email, password: password);

      currentUserData = await _authService.getCurrentUserData();

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

  Future<void> loadCurrentUserData() async {
    currentUserData = await _authService.getCurrentUserData();
    notifyListeners();
  }
}
