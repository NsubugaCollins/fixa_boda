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
    required String password,
  }) async {
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final username = email.trim().split('@').first;

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
        'phoneNumber': phone,
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
    required String pickupLocation,
    String? destinationLocation,
    String? mechanicId,
    String? estimatedCost,
  }) async {
    final payload = <String, dynamic>{
      'riderId': riderId,
      'requestType': requestType,
      'description': description,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation ?? pickupLocation,
      'estimatedCost': estimatedCost ?? '20000',
    };

    if (mechanicId != null && mechanicId.isNotEmpty) {
      payload['mechanicId'] = mechanicId;
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/rider/requests'),
      headers: _headers(),
      body: jsonEncode(payload),
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

  Future<Map<String, dynamic>> confirmRequest(String requestId) async {
    return updateRequestStatus(requestId: requestId, status: 'CONFIRMED');
  }

  Future<Map<String, dynamic>> updateMechanicAvailability({
    required String mechanicId,
    required bool available,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/mechanic/$mechanicId/availability?available=$available'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decode(response);
    }
    throw Exception('Update availability failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<List<Map<String, dynamic>>> getNearbyMechanics({
    double? latitude,
    double? longitude,
  }) async {
    final queryParams = <String, String>{};
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();

    final response = await _client.get(
      Uri.parse('$baseUrl/mechanic/nearby').replace(queryParameters: queryParams),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        final list = decoded['content'] ?? decoded;
        if (list is List) {
          return list
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
      return [];
    }
    throw Exception('Get nearby mechanics failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateMechanicLocation({
    required String mechanicId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/mechanic/$mechanicId/location')
          .replace(queryParameters: {
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
          }),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await _decode(response);
    }
    throw Exception('Update mechanic location failed: ${response.statusCode} ${await _decode(response)}');
  }

  Future<List<Map<String, dynamic>>> getLiveRouteForRider(String riderId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/rider/requests/$riderId/live'),
      headers: _headers(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return [];
    }
    throw Exception('Get live rider route failed: ${response.statusCode}');
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
