part of 'api_service.dart';

extension AuthApi on ApiService {
  Future<Response> _userAuthRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userAuth';
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final salt = BCrypt.gensalt();
    final encryptedPassword = BCrypt.hashpw(password, salt);
    return _userAuthRequest(
      operation: 'regis',
      data: {
        'username': username,
        'email': email,
        'salt': salt,
        'encrypted_password': encryptedPassword,
      },
    );
  }

  Future<Response> login(String username, String password) async {
    return _userAuthRequest(
      operation: 'login',
      data: {
        'username': username,
        'password': password,
      },
    );
  }
}
