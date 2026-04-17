import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userPasswordKey = 'user_password';

  static final Map<String, Object?> _memoryStore = <String, Object?>{};

  Future<SharedPreferences?> _getPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _getPreferences();
    return prefs?.getBool(_isLoggedInKey) ??
        (_memoryStore[_isLoggedInKey] as bool? ?? false);
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final prefs = await _getPreferences();

    if (prefs != null) {
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userPasswordKey, password);
      await prefs.setBool(_isLoggedInKey, true);
      return;
    }

    _memoryStore[_userNameKey] = name;
    _memoryStore[_userEmailKey] = email;
    _memoryStore[_userPhoneKey] = phone;
    _memoryStore[_userPasswordKey] = password;
    _memoryStore[_isLoggedInKey] = true;
  }

  Future<bool> login({
    required String credential,
    required String password,
  }) async {
    final storedUser = await getStoredUser();
    if (storedUser.isEmpty) {
      return false;
    }

    final normalizedCredential = credential.trim().toLowerCase();
    final storedEmail = (storedUser['email'] ?? '').trim().toLowerCase();
    final storedPhone = (storedUser['phone'] ?? '').trim();
    final storedPassword = storedUser['password'] ?? '';

    final canLogin =
        storedPassword == password &&
        (normalizedCredential == storedEmail ||
            credential.trim() == storedPhone);

    if (!canLogin) {
      return false;
    }

    final prefs = await _getPreferences();
    if (prefs != null) {
      await prefs.setBool(_isLoggedInKey, true);
    } else {
      _memoryStore[_isLoggedInKey] = true;
    }

    return true;
  }

  Future<void> logout() async {
    final prefs = await _getPreferences();
    if (prefs != null) {
      await prefs.setBool(_isLoggedInKey, false);
    } else {
      _memoryStore[_isLoggedInKey] = false;
    }
  }

  Future<String?> getUserPhone() async {
    final user = await getStoredUser();
    return user['phone'];
  }

  Future<Map<String, String>> getStoredUser() async {
    final prefs = await _getPreferences();

    if (prefs != null) {
      return <String, String>{
        if (prefs.getString(_userNameKey) != null)
          'name': prefs.getString(_userNameKey)!,
        if (prefs.getString(_userEmailKey) != null)
          'email': prefs.getString(_userEmailKey)!,
        if (prefs.getString(_userPhoneKey) != null)
          'phone': prefs.getString(_userPhoneKey)!,
        if (prefs.getString(_userPasswordKey) != null)
          'password': prefs.getString(_userPasswordKey)!,
      };
    }

    return <String, String>{
      if (_memoryStore[_userNameKey] is String)
        'name': _memoryStore[_userNameKey]! as String,
      if (_memoryStore[_userEmailKey] is String)
        'email': _memoryStore[_userEmailKey]! as String,
      if (_memoryStore[_userPhoneKey] is String)
        'phone': _memoryStore[_userPhoneKey]! as String,
      if (_memoryStore[_userPasswordKey] is String)
        'password': _memoryStore[_userPasswordKey]! as String,
    };
  }

  Future<Map<String, String>> getCurrentUser() async {
    final isActive = await isLoggedIn();
    if (!isActive) {
      return <String, String>{};
    }

    final storedUser = await getStoredUser();
    storedUser.remove('password');
    return storedUser;
  }
}
