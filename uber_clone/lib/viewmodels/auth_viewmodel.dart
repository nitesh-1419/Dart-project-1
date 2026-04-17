import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  Map<String, String> _currentUser = <String, String>{};

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  Map<String, String> get currentUser => _currentUser;

  Future<bool> login({
    required String credential,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isAuthenticated = await _authService.login(
        credential: credential,
        password: password,
      );

      if (!isAuthenticated) {
        _errorMessage =
            'We could not sign you in. Check your email or phone and password.';
        return false;
      }

      _isLoggedIn = true;
      _currentUser = await _authService.getCurrentUser();
      return true;
    } catch (_) {
      _errorMessage =
          'Something went wrong while signing you in. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _isLoggedIn = true;
      _currentUser = await _authService.getCurrentUser();
      return true;
    } catch (_) {
      _errorMessage =
          'We could not create your account right now. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      _currentUser = _isLoggedIn
          ? await _authService.getCurrentUser()
          : <String, String>{};
      return _isLoggedIn;
    } catch (_) {
      _isLoggedIn = false;
      _currentUser = <String, String>{};
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _errorMessage = null;
    _currentUser = <String, String>{};
    notifyListeners();
  }
}
