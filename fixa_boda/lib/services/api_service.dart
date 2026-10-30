import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String baseUrl = 'http://10.0.2.2:8081/api';

  static void setBaseUrl(String url) => baseUrl = url;

  final http.Client _client = http.Client();
  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<Map<String, dynamic>> _decode(http.Response response) {
    final body = response.body;
    if (body.isNotEmpty) {
      return Future.value(jsonDecode(body) as Map<String, dynamic>);
    }
    return Future.value(<String, dynamic>{});
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String role,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decode(response);
    }
    throw Exception('Register failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = await _decode(response);
      _token = data['token'] as String?;
      return data;
    }
    throw Exception('Login failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<Map<String, dynamic>> createServiceRequest({
    required String riderId,
    required String requestType,
    required String description,
    required String location,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/rider/requests'),
      headers: _headers(),
      body: jsonEncode({
        'riderId': riderId,
        'requestType': requestType,
        'description': description,
        'location': location,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decode(response);
    }
    throw Exception('Create request failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<List<Map<String, dynamic>>> getRiderRequests(String riderId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/rider/requests/$riderId'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = await _decode(response);
      final list = body['content'] ?? body;
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    }
    throw Exception('Get rider requests failed: ${response.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getMechanicRequests(String mechanicId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/mechanic/requests/$mechanicId'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = await _decode(response);
      final list = body['content'] ?? body;
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    }
    throw Exception('Get mechanic requests failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> acceptRequest({
    required String requestId,
    required String mechanicId,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/mechanic/requests/$requestId/accept/$mechanicId'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decode(response);
    }
    throw Exception('Accept request failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<Map<String, dynamic>> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/mechanic/requests/$requestId/status?status=$status'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decode(response);
    }
    throw Exception('Update status failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = await _decode(response);
      final list = body['content'] ?? body;
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    }
    throw Exception('Get users failed: ${response.statusCode}');
  }

  void dispose() {
    _client.close();
  }
}
