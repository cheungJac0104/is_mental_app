import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'aws_sig_v4_client.dart'; // Import the AwsSigV4Client
import 'package:bcrypt/bcrypt.dart';
import 'dart:io';

class ApiService {
  final AwsSigV4Client _awsSigV4Client = AwsSigV4Client();

  // Base URL of your API
  static const String _baseUrl =
      'https://du4cwpwkyi.execute-api.us-east-1.amazonaws.com/dev';

  Future<Response> _requestPattern(
      {required String operation,
      required Map<String, dynamic> data,
      required String path}) async {
    final body = {
      'operation': operation,
      'data': data,
    };

    try {
      final headers = await _awsSigV4Client.signRequest(
        method: AWSHttpMethod.post,
        url: Uri.parse('$_baseUrl$path').toString(),
        body: body,
      );

      final dio = Dio()
        ..interceptors.add(LogInterceptor())
        ..options.baseUrl = _baseUrl
        ..options.headers = headers
        ..options.connectTimeout = const Duration(seconds: 30)
        ..options.receiveTimeout = const Duration(seconds: 30);

      // Add a custom HttpClient with SSL verification disabled
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          // Don't trust any certificate just because their root cert is trusted.
          final HttpClient client =
              HttpClient(context: SecurityContext(withTrustedRoots: false));
          // You can test the intermediate / root cert here. We just ignore it.
          client.badCertificateCallback = ((_, String host, int port) => true);
          return client;
        },
      );

      final response = await dio.post(path, data: body);

      return response;
    } on DioException catch (e) {
      debugPrint('''
  === DIO ERROR ===
  URL: ${e.requestOptions.uri}
  Method: ${e.requestOptions.method}
  Headers: ${e.requestOptions.headers}
  Body: ${e.requestOptions.data}
  Response: ${e.response?.data}
  Error Type: ${e.type}
  Message: ${e.message}
  ''');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Connection timed out';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw 'Receive timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        throw 'Connection error: ${e.message}';
      } else {
        throw e.response?.data['message'] ?? 'Request failed : ${e.message}';
      }
    }
  }

  // Helper method to make a userAuth request
  Future<Response> _userAuthRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userAuth'; // Replace with your API endpoint
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> _userMoodRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userMood'; // Replace with your API endpoint
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> _userStatsRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userStats'; // Replace with your API endpoint
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> _userCommuRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userCommu'; // Replace with your API endpoint
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> _userProfileRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userProfile'; // Replace with your API endpoint
    return _requestPattern(operation: operation, data: data, path: path);
  }

  // Register API
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

  // Login API
  Future<Response> login(
    String username,
    String password,
  ) async {
    return _userAuthRequest(
      operation: 'login',
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  Future<Response> createMoodRecord(Map<String, dynamic> moodEntry) async {
    return _userMoodRequest(operation: 'createMoodRecord', data: {});
  }

  Map<String, dynamic> responseBodyParse(Response response) {
    final responseBody = jsonEncode(response.data);
    debugPrint('Response Body: $responseBody');
    return jsonDecode(responseBody);
  } // Add this line to get the response body

  Map<String, dynamic> jsonBodyParse(String jsonString) =>
      jsonDecode(jsonString);
}
