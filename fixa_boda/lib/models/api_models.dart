class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      userId: json['userId'] as String? ?? json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class ServiceRequest {
  final String id;
  final String riderId;
  final String requestType;
  final String description;
  final String location;
  final String status;
  final String? mechanicId;
  final String? createdAt;

  ServiceRequest({
    required this.id,
    required this.riderId,
    required this.requestType,
    required this.description,
    required this.location,
    required this.status,
    this.mechanicId,
    this.createdAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id']?.toString() ?? '',
      riderId: json['riderId']?.toString() ?? '',
      requestType: json['requestType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? '',
      mechanicId: json['mechanicId']?.toString(),
      createdAt: json['createdAt'] as String?,
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
