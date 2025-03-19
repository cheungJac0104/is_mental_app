import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'dart:convert';

class AwsSigV4Client {
  final AWSSigV4Signer _signer;

  // AWS credentials and region
  static const String _accessKey = '';
  static const String _secretKey = '';
  static const String _region = 'us-east-1';
  static const AWSService _service = AWSService('execute-api');

  AwsSigV4Client()
      : _signer = const AWSSigV4Signer(
          credentialsProvider:
              AWSCredentialsProvider(AWSCredentials(_accessKey, _secretKey)),
        );

  // Helper method to sign the request
  Future<Map<String, String>> signRequest({
    required AWSHttpMethod method,
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);
    final request = AWSHttpRequest(
      method: method,
      uri: uri,
      headers: const {
        'Content-Type': 'application/json',
      },
      body: body.isNotEmpty ? utf8.encode(jsonEncode(body)) : null,
    );

    final scope = AWSCredentialScope(
      region: _region,
      service: _service,
    );

    final signedRequest = await _signer.sign(
      request,
      credentialScope: scope,
    );

    return signedRequest.headers;
  }
}
