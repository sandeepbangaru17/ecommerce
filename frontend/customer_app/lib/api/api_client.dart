import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );
  String? _token;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final detail = body is Map ? body['detail'] ?? 'Unknown error' : 'Unknown error';
    throw ApiException(response.statusCode, detail.toString());
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: $statusCode - $message';
}
