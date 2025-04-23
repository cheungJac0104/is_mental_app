import 'dart:convert';
import 'package:aws_common/aws_common.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'aws_sig_v4_client.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:io';

part 'api_service.part.auth.dart';
part 'api_service.part.mood.dart';
part 'api_service.part.stats.dart';
part 'api_service.part.community.dart';
part 'api_service.part.friend_list.dart';
part 'api_service.part.pub_challenge.dart';
part 'api_service.part.user_event.dart';

class ApiService {
  final AwsSigV4Client _awsSigV4Client = AwsSigV4Client();
  final AuthService authService;

  ApiService(this.authService);

  // Base URL of your API
  static const String _baseUrl =
      'https://du4cwpwkyi.execute-api.us-east-1.amazonaws.com/dev';

  Future<Response> _requestPattern({
    required String operation,
    required Map<String, dynamic> data,
    required String path,
  }) async {
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
          final HttpClient client =
              HttpClient(context: SecurityContext(withTrustedRoots: false));
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

  Map<String, dynamic> responseBodyParse(Response response) {
    final responseBody = jsonEncode(response.data);
    debugPrint('Response Body: $responseBody');
    return jsonDecode(responseBody);
  }

  Map<String, dynamic> jsonBodyParse(String jsonString) =>
      jsonDecode(jsonString);

  Map<String, dynamic> getResBodyJson(Response response) {
    final x = responseBodyParse(response)['body'].toString();
    return jsonBodyParse(x);
  }
}
