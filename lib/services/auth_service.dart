import '../config/api_config.dart';
import '../models/auth_models.dart';
import 'http_service.dart';
import 'secure_storage_service.dart';

/// Authentication service for managing user authentication
class AuthService {
  static final HttpService _httpService = HttpService.instance;

  /// Register a new user
  static Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _httpService.post<AuthResponse>(
        ApiConfig.register,
        data: request.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        await SecureStorageService.storeAuthResponse(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(message: 'Registration failed: $e'),
      );
    }
  }

  /// Login user
  static Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _httpService.post<AuthResponse>(
        ApiConfig.login,
        data: request.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        await SecureStorageService.storeAuthResponse(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(message: 'Login failed: $e'),
      );
    }
  }

  /// Get current user
  static Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _httpService.get<User>(
        ApiConfig.user,
        fromJson: (json) => User.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        await SecureStorageService.storeUser(response.data!);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(message: 'Failed to get user: '),
      );
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      await _httpService.post<String>(ApiConfig.logout);
    } catch (e) {
      // Ignore logout errors
    } finally {
      await SecureStorageService.clearAuthData();
    }
  }

  /// Check if authenticated
  static Future<bool> isAuthenticated() async {
    return await SecureStorageService.isAuthenticated();
  }

  /// Check authentication status and return user data if authenticated
  static Future<AuthStatusResponse> checkAuthStatus() async {
    try {
      final isAuth = await SecureStorageService.isAuthenticated();
      if (!isAuth) {
        return AuthStatusResponse(isAuthenticated: false, user: null);
      }

      final token = await SecureStorageService.getToken();
      if (token == null) {
        return AuthStatusResponse(isAuthenticated: false, user: null);
      }

      // Try to get current user from API to validate token
      final userResponse = await getCurrentUser();
      if (userResponse.isSuccess && userResponse.data != null) {
        return AuthStatusResponse(isAuthenticated: true, user: userResponse.data);
      } else {
        // Token is invalid, clear storage
        await SecureStorageService.clearAuthData();
        return AuthStatusResponse(isAuthenticated: false, user: null);
      }
    } catch (e) {
      // On error, assume not authenticated
      return AuthStatusResponse(isAuthenticated: false, user: null);
    }
  }
}
