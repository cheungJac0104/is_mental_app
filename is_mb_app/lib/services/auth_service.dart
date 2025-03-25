import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Save token and expiration time
  Future<void> saveToken(String token, int expiresIn) async {
    //debugPrint(token);
    await _prefs.setString('auth_token', token);
    await _prefs.setInt('token_expiration',
        DateTime.now().millisecondsSinceEpoch + expiresIn * 1000);
  }

  Future<void> saveTokenUserInfo(String token) async {
    Map<String, dynamic> payload = JwtDecoder.decode(token);
    //debugPrint(payload.toString());
    // Extract user information
    String userId = payload['userId'];
    String username = payload['username'];
    String email = payload['email'];

    await _prefs.setString('user_id', userId);
    await _prefs.setString('username', username);
    await _prefs.setString('email', email);
  }

  // Get token
  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<String?> getItem(String key) async {
    return _prefs.getString(key);
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    final expirationTime = _prefs.getInt('token_expiration');
    if (expirationTime == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime >= expirationTime;
  }

  // Clear token and expiration time
  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('token_expiration');
  }
}
