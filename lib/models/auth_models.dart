/// User model for authentication and user data
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'customer',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is customer
  bool get isCustomer => role == 'customer';

  /// Get user display name
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

/// Authentication response model
class AuthResponse {
  final User user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  /// Create AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  /// Convert AuthResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, token: ${token.substring(0, 20)}...)';
  }
}

/// Login request model
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: ****)';
  }
}

/// Register request model
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  /// Validate the registration data
  List<String> validate() {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Name is required');
    }

    if (email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }

    if (password != passwordConfirmation) {
      errors.add('Passwords do not match');
    }

    return errors;
  }

  /// Check if the registration data is valid
  bool get isValid => validate().isEmpty;

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  String toString() {
    return 'RegisterRequest(name: $name, email: $email, password: ****, passwordConfirmation: ****)';
  }
}

/// API Error model for handling authentication errors
class ApiError {
  final String message;
  final Map<String, List<String>>? errors;
  final int? statusCode;

  const ApiError({
    required this.message,
    this.errors,
    this.statusCode,
  });

  /// Create ApiError from JSON response
  factory ApiError.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? errors;
    
    if (json['errors'] != null) {
      final errorsMap = json['errors'] as Map<String, dynamic>;
      errors = errorsMap.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => e.toString()).toList(),
        ),
      );
    }

    return ApiError(
      message: json['message'] as String? ?? 'An error occurred',
      errors: errors,
      statusCode: json['status_code'] as int?,
    );
  }

  /// Get all error messages as a flat list
  List<String> get allErrors {
    List<String> allErrors = [message];
    
    if (errors != null) {
      for (var errorList in errors!.values) {
        allErrors.addAll(errorList);
      }
    }
    
    return allErrors;
  }

  /// Get the first error message
  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.first;
    }
    return message;
  }

  /// Check if this is a validation error
  bool get isValidationError => statusCode == 422;

  /// Check if this is an authentication error
  bool get isAuthError => statusCode == 401;

  /// Check if this is a forbidden error
  bool get isForbiddenError => statusCode == 403;

  /// Check if this is a not found error
  bool get isNotFoundError => statusCode == 404;

  @override
  String toString() {
    return 'ApiError(message: $message, statusCode: $statusCode, errors: $errors)';
  }
}

/// Authentication state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Demo token response model (for testing)
class DemoTokenResponse {
  final String message;
  final User user;
  final String token;
  final Map<String, String> instructions;

  const DemoTokenResponse({
    required this.message,
    required this.user,
    required this.token,
    required this.instructions,
  });

  /// Create DemoTokenResponse from JSON
  factory DemoTokenResponse.fromJson(Map<String, dynamic> json) {
    return DemoTokenResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      instructions: Map<String, String>.from(json['instructions'] as Map),
    );
  }

  @override
  String toString() {
    return 'DemoTokenResponse(message: $message, user: $user, token: ${token.substring(0, 20)}...)';
  }
}

/// Authentication status response model
class AuthStatusResponse {
  final bool isAuthenticated;
  final User? user;

  const AuthStatusResponse({
    required this.isAuthenticated,
    this.user,
  });

  @override
  String toString() {
    return 'AuthStatusResponse(isAuthenticated: $isAuthenticated, user: $user)';
  }
}