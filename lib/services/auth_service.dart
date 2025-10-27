import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'http://localhost:8000/api';

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<AuthResult> login({required String email, required String password}) async {
    final response = await _client.post(
      _uri('/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    return _handleAuthResponse(response);
  }

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      _uri('/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    return _handleAuthResponse(response);
  }

  AuthResult _handleAuthResponse(http.Response response) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const AuthException('Unexpected response from the server. Please try again later.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = data['token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      if (token == null || user == null) {
        throw const AuthException('Incomplete response from the server.');
      }
      return AuthResult(token: token, user: user);
    }

    final message = data['detail'] ?? data['error'] ?? 'Authentication failed. Please check your details.';
    throw AuthException(message.toString());
  }
}
