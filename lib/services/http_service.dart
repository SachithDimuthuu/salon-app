import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';
import 'secure_storage_service.dart';

/// HTTP service with authentication interceptors and error handling
class HttpService {
  late final Dio _dio;
  static HttpService? _instance;

  /// Singleton instance
  static HttpService get instance {
    _instance ??= HttpService._internal();
    return _instance!;
  }

  HttpService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.connectTimeout,
      sendTimeout: ApiConfig.connectTimeout,
      headers: ApiConfig.defaultHeaders,
      validateStatus: (status) {
        // Accept all status codes to handle them manually
        return status != null && status < 600;
      },
    ));

    _setupInterceptors();
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Setup interceptors
  void _setupInterceptors() {
    // Request interceptor - Add auth token and headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token if available
          final token = await SecureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add common headers for Laravel API
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          // Log request in debug mode
          if (ApiConfig.isDebug) {
            print('🚀 REQUEST: ${options.method} ${options.uri}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode
          if (ApiConfig.isDebug) {
            print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            print('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          // Log error in debug mode
          if (ApiConfig.isDebug) {
            print('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('Error: ${error.message}');
            print('Response: ${error.response?.data}');
          }

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }

          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    if (ApiConfig.isDebug) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  /// Handle unauthorized access (token expired)
  Future<void> _handleUnauthorized() async {
    try {
      // Clear stored auth data
      await SecureStorageService.clearAuthData();
      
      // You could also trigger a logout event here
      // EventBus.instance.fire(LogoutEvent());
    } catch (e) {
      if (ApiConfig.isDebug) {
        print('Error handling unauthorized access: $e');
      }
    }
  }

  /// Make GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Make PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle successful response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (response.statusCode != null && 
        response.statusCode! >= 200 && 
        response.statusCode! < 300) {
      
      // Handle successful response
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        T? parsedData;
        
        if (fromJson != null) {
          // Parse data using provided function
          if (data.containsKey('data')) {
            parsedData = fromJson(data['data']);
          } else {
            parsedData = fromJson(data);
          }
        }
        
        return ApiResponse<T>.success(
          data: parsedData,
          rawData: data,
          message: data['message'] as String?,
          statusCode: response.statusCode!,
        );
      }
      
      return ApiResponse<T>.success(
        data: null,
        rawData: data,
        message: 'Request successful',
        statusCode: response.statusCode!,
      );
    } else {
      // Handle error response
      return _createErrorResponse<T>(response);
    }
  }

  /// Handle error response
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return _createErrorResponse<T>(error.response!);
      } else {
        // Network error
        return ApiResponse<T>.error(
          error: ApiError(
            message: _getNetworkErrorMessage(error),
            statusCode: null,
          ),
        );
      }
    }
    
    return ApiResponse<T>.error(
      error: ApiError(
        message: 'An unexpected error occurred: $error',
        statusCode: null,
      ),
    );
  }

  /// Create error response from HTTP response
  ApiResponse<T> _createErrorResponse<T>(Response response) {
    final data = response.data;
    ApiError apiError;
    
    if (data is Map<String, dynamic>) {
      apiError = ApiError.fromJson({
        ...data,
        'status_code': response.statusCode,
      });
    } else {
      apiError = ApiError(
        message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    }
    
    return ApiResponse<T>.error(error: apiError);
  }

  /// Get user-friendly network error message
  String _getNetworkErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Certificate error. Please check your connection.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please check your internet connection.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network settings.';
        }
        return 'Network error. Please try again.';
      default:
        return 'Network error occurred. Please try again.';
    }
  }

  /// Update base URL (useful for switching environments)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Set custom headers
  void setHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Clear all custom headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll(ApiConfig.defaultHeaders);
  }

  /// Add authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization header
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health', 
        options: Options(sendTimeout: const Duration(seconds: 5))
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final Map<String, dynamic>? rawData;
  final String? message;
  final ApiError? error;
  final int? statusCode;

  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.rawData,
    this.message,
    this.error,
    this.statusCode,
  });

  /// Create successful response
  factory ApiResponse.success({
    T? data,
    Map<String, dynamic>? rawData,
    String? message,
    required int statusCode,
  }) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      rawData: rawData,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    required ApiError error,
  }) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
      statusCode: error.statusCode,
    );
  }

  /// Check if response indicates success
  bool get isOk => isSuccess && error == null;

  /// Check if response is an authentication error
  bool get isAuthError => error?.isAuthError ?? false;

  /// Check if response is a validation error
  bool get isValidationError => error?.isValidationError ?? false;

  /// Check if response is a network error
  bool get isNetworkError => statusCode == null;

  /// Get error message
  String get errorMessage => error?.message ?? 'Unknown error occurred';

  /// Get first error message
  String get firstError => error?.firstError ?? errorMessage;

  /// Get all error messages
  List<String> get allErrors => error?.allErrors ?? [errorMessage];

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(statusCode: $statusCode, message: $message)';
    } else {
      return 'ApiResponse.error(error: $error)';
    }
  }
}

/// HTTP method enum
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
}

/// Request options builder
class RequestOptions {
  Map<String, dynamic>? queryParameters;
  Map<String, String>? headers;
  Duration? timeout;
  bool includeAuth;

  RequestOptions({
    this.queryParameters,
    this.headers,
    this.timeout,
    this.includeAuth = true,
  });

  /// Convert to Dio Options
  Options toDioOptions() {
    return Options(
      headers: headers,
      sendTimeout: timeout,
      receiveTimeout: timeout,
    );
  }
}