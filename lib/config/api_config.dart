/// API Configuration for Luxe Hair Studio
class ApiConfig {
  // Base URLs for different environments
  static const String _localhost = 'http://127.0.0.1:8000';
  static const String _production = 'https://hair-salon-production.up.railway.app';
  
  // Environment toggle
  static const bool _useProduction = true;
  
  /// Get the appropriate base URL based on environment setting
  static String get baseUrl {
    if (_useProduction) {
      return '$_production/api';
    } else {
      return '$_localhost/api';
    }
  }
  
  /// Alternative method to get base URL with custom host IP
  /// Use this when testing on physical devices with localhost
  static String getBaseUrlWithIP(String hostIP) {
    return 'http://$hostIP:8000/api';
  }
  
  // Authentication endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String logoutAll = '/logout-all';
  static const String user = '/user';
  static const String demoToken = '/demo-token';
  
  // Services endpoints
  static const String services = '/services';
  static const String servicesPublic = '/services/public';
  
  // Deals endpoints
  static const String deals = '/deals';
  static const String dealsPublic = '/deals/public';
  
  /// Get full URL for an endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Get deal availability endpoint
  static String getDealAvailability(String dealId) {
    return '$baseUrl/deals/$dealId/availability';
  }
  
  /// Get single service endpoint
  static String getService(String serviceId) {
    return '$baseUrl/services/$serviceId';
  }
  
  /// Get single deal endpoint
  static String getDeal(String dealId) {
    return '$baseUrl/deals/$dealId';
  }
  
  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  
  // Cache durations
  static const Duration publicServicesCacheDuration = Duration(minutes: 5);
  static const Duration publicDealsCacheDuration = Duration(minutes: 5);
  
  // Pagination defaults
  static const int defaultPerPage = 15;
  static const int maxPerPage = 100;
  
  // Token storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String lastLoginKey = 'last_login';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Get authorization header with token
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
  
  // API Response status codes
  static const int successOk = 200;
  static const int successCreated = 201;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int validationError = 422;
  static const int tooManyRequests = 429;
  static const int serverError = 500;
  
  // Environment detection
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
  
  /// Log API configuration info
  static void logConfig() {
    if (isDebug) {
      print('=== API Configuration ===');
      print('Base URL: $baseUrl');
      print('========================');
    }
  }
}

/// API Endpoints enum for type safety
enum ApiEndpoint {
  register,
  login,
  logout,
  logoutAll,
  user,
  demoToken,
  services,
  servicesPublic,
  deals,
  dealsPublic,
}

extension ApiEndpointExtension on ApiEndpoint {
  String get path {
    switch (this) {
      case ApiEndpoint.register:
        return ApiConfig.register;
      case ApiEndpoint.login:
        return ApiConfig.login;
      case ApiEndpoint.logout:
        return ApiConfig.logout;
      case ApiEndpoint.logoutAll:
        return ApiConfig.logoutAll;
      case ApiEndpoint.user:
        return ApiConfig.user;
      case ApiEndpoint.demoToken:
        return ApiConfig.demoToken;
      case ApiEndpoint.services:
        return ApiConfig.services;
      case ApiEndpoint.servicesPublic:
        return ApiConfig.servicesPublic;
      case ApiEndpoint.deals:
        return ApiConfig.deals;
      case ApiEndpoint.dealsPublic:
        return ApiConfig.dealsPublic;
    }
  }
  
  String get url => ApiConfig.getUrl(path);
}
