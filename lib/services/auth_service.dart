import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

/// Authentication Service for SSP Laravel Sanctum API
/// Handles login, register, logout, and token management
class AuthService {
  // Dio instance for HTTP requests
  late final Dio _dio;
  
  // Secure storage for tokens
  final _storage = const FlutterSecureStorage();
  
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.sspBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));
    
    // Add interceptor for logging (optional)
    if (ApiConfig.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => print('[AuthService] $log'),
      ));
    }
    
    // Add interceptor to automatically add token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired/invalid
        if (error.response?.statusCode == 401) {
          await clearAuth();
        }
        return handler.next(error);
      },
    ));
  }
  
  /// Login with email and password
  /// Returns true if login successful, false otherwise
  /// Throws DioException on network errors
  Future<bool> login(String email, String password) async {
    try {
      print('[AuthService] Attempting login for: $email');
      
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Extract token (check multiple possible response formats)
        String? token;
        if (data is Map<String, dynamic>) {
          token = data['token'] ?? data['access_token'] ?? data['data']?['token'];
        }
        
        if (token != null && token.isNotEmpty) {
          // Store token
          await _storage.write(key: _tokenKey, value: token);
          
          // Store user data if available
          if (data['user'] != null) {
            await _storage.write(key: _userKey, value: data['user'].toString());
          }
          
          print('[AuthService] ✅ Login successful, token stored');
          return true;
        } else {
          print('[AuthService] ❌ No token in response');
          return false;
        }
      }
      
      print('[AuthService] ❌ Login failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('[AuthService] ❌ Login error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        throw Exception(errors?.values?.first?.first ?? 'Validation error');
      }
      rethrow;
    }
  }
  
  /// Register a new user
  /// Returns true if registration successful, false otherwise
  /// Throws DioException on network errors
  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      print('[AuthService] Attempting registration for: ${userData['email']}');
      
      final response = await _dio.post(
        ApiConfig.registerEndpoint,
        data: userData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Some APIs return token on registration, some require separate login
        String? token;
        if (data is Map<String, dynamic>) {
          token = data['token'] ?? data['access_token'] ?? data['data']?['token'];
        }
        
        if (token != null && token.isNotEmpty) {
          // Store token if provided
          await _storage.write(key: _tokenKey, value: token);
          
          // Store user data if available
          if (data['user'] != null) {
            await _storage.write(key: _userKey, value: data['user'].toString());
          }
          
          print('[AuthService] ✅ Registration successful with auto-login');
        } else {
          print('[AuthService] ✅ Registration successful, please login');
        }
        
        return true;
      }
      
      print('[AuthService] ❌ Registration failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('[AuthService] ❌ Registration error: ${e.message}');
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        throw Exception(errors?.values?.first?.first ?? 'Validation error');
      }
      rethrow;
    }
  }
  
  /// Logout the current user
  /// Sends logout request to API and clears local token
  Future<void> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        print('[AuthService] Attempting logout');
        
        try {
          // Send logout request to API
          await _dio.post(
            ApiConfig.logoutEndpoint,
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          );
          print('[AuthService] ✅ Logout API call successful');
        } catch (e) {
          // Continue with local logout even if API call fails
          print('[AuthService] ⚠️ Logout API call failed, proceeding with local logout');
        }
      }
      
      // Clear local storage
      await clearAuth();
      print('[AuthService] ✅ Logout complete, token cleared');
    } catch (e) {
      print('[AuthService] ❌ Logout error: $e');
      // Still clear local storage on error
      await clearAuth();
    }
  }
  
  /// Get the current authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Get the current user data from API
  /// Requires authentication token
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        print('[AuthService] ❌ No token available');
        return null;
      }
      
      print('[AuthService] Fetching current user');
      
      final response = await _dio.get(
        ApiConfig.userEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          // Store user data
          await _storage.write(key: _userKey, value: data.toString());
          print('[AuthService] ✅ User data fetched');
          return data['user'] ?? data;
        }
      }
      
      return null;
    } on DioException catch (e) {
      print('[AuthService] ❌ Get user error: ${e.message}');
      if (e.response?.statusCode == 401) {
        await clearAuth();
      }
      return null;
    }
  }
  
  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    print('[AuthService] 🗑️ Auth data cleared');
  }
  
  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('[AuthService] Updating profile');
      
      final response = await _dio.post(
        ApiConfig.updateProfileEndpoint,
        data: profileData,
      );
      
      if (response.statusCode == 200) {
        print('[AuthService] ✅ Profile updated successfully');
        return true;
      }
      
      return false;
    } on DioException catch (e) {
      print('[AuthService] ❌ Update profile error: ${e.message}');
      rethrow;
    }
  }
  
  /// Upload profile image
  /// Takes file path and uploads to server
  Future<String?> uploadProfileImage(String filePath) async {
    try {
      print('[AuthService] Uploading profile image');
      
      // Create multipart file
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      
      final response = await _dio.post(
        ApiConfig.uploadImageEndpoint,
        data: formData,
      );
      
      if (response.statusCode == 200) {
        final imageUrl = response.data['url'] ?? response.data['image_url'];
        print('[AuthService] ✅ Image uploaded: $imageUrl');
        return imageUrl;
      }
      
      return null;
    } on DioException catch (e) {
      print('[AuthService] ❌ Upload image error: ${e.message}');
      rethrow;
    }
  }
  
  /// Make authenticated API request
  /// Helper method for other services to make authenticated requests
  Future<Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = await getToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final options = Options(
      method: method,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    return await _dio.request(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
