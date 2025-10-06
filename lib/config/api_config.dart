/// API Configuration for SSP Backend Integration
/// This file contains the base URLs and endpoints for the Laravel Sanctum API

class ApiConfig {
  // Base URL for SSP Laravel API (Sanctum Authentication)
  static const String sspBaseUrl = 'https://your-ssp-domain.com/api';
  
  // Base URL for Railway Deals API
  static const String dealsBaseUrl = 'https://hair-salon-production.up.railway.app';
  
  // SSP API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String userEndpoint = '/user';
  static const String bookingsEndpoint = '/bookings';
  static const String servicesEndpoint = '/services';
  static const String profileEndpoint = '/profile';
  static const String updateProfileEndpoint = '/profile/update';
  static const String uploadImageEndpoint = '/profile/upload-image';
  
  // Deals API Endpoints
  static const String dealsActiveEndpoint = '/api/deals/active';
  static const String dealsEndpoint = '/api/deals';
  static const String dealsHealthEndpoint = '/api/health';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API Configuration
  static const String apiVersion = 'v1';
  static const bool enableLogging = true;
  
  // Full URLs
  static String get loginUrl => '$sspBaseUrl$loginEndpoint';
  static String get registerUrl => '$sspBaseUrl$registerEndpoint';
  static String get logoutUrl => '$sspBaseUrl$logoutEndpoint';
  static String get userUrl => '$sspBaseUrl$userEndpoint';
  static String get bookingsUrl => '$sspBaseUrl$bookingsEndpoint';
  static String get servicesUrl => '$sspBaseUrl$servicesEndpoint';
  static String get profileUrl => '$sspBaseUrl$profileEndpoint';
  static String get updateProfileUrl => '$sspBaseUrl$updateProfileEndpoint';
  static String get uploadImageUrl => '$sspBaseUrl$uploadImageEndpoint';
  
  static String get dealsActiveUrl => '$dealsBaseUrl$dealsActiveEndpoint';
  static String get dealsUrl => '$dealsBaseUrl$dealsEndpoint';
  static String get dealsHealthUrl => '$dealsBaseUrl$dealsHealthEndpoint';
}

/// Instructions for configuring your SSP domain:
/// 
/// 1. Replace 'https://your-ssp-domain.com/api' with your actual Laravel API URL
///    Example: 'https://ssp.yourdomain.com/api' or 'http://192.168.1.100:8000/api' for local
/// 
/// 2. Make sure your Laravel API has these endpoints set up:
///    POST   /api/login       - Login with email & password
///    POST   /api/register    - Register new user
///    POST   /api/logout      - Logout (requires auth)
///    GET    /api/user        - Get authenticated user (requires auth)
///    GET    /api/bookings    - Get user bookings (requires auth)
///    GET    /api/services    - Get available services
///    GET    /api/profile     - Get user profile (requires auth)
///    POST   /api/profile/update - Update profile (requires auth)
///    POST   /api/profile/upload-image - Upload profile image (requires auth)
/// 
/// 3. Ensure Sanctum is properly configured in your Laravel app:
///    - SANCTUM_STATEFUL_DOMAINS in .env
///    - cors.php configured for your Flutter app
///    - api.php routes use auth:sanctum middleware
