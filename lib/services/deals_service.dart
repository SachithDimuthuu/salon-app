import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/deal.dart';

class DealsService {
  // Use centralized API configuration
  static const String baseUrl = 'https://hair-salon-production.up.railway.app';
  
  // API endpoints
  static const String dealsEndpoint = '/api/deals';
  static const String activeDealsEndpoint = '/api/deals/active';
  
  // API Key for deals endpoint (if different from auth token)
  static String? _apiKey;
  
  // Secure storage for auth token
  static const _storage = FlutterSecureStorage();
  
  // Set API key for deals endpoint
  static void setApiKey(String apiKey) {
    _apiKey = apiKey;
    debugPrint('✅ API Key configured for Deals Service');
  }
  
  // Get API key
  static String? get apiKey => _apiKey;
  
  // Headers with authentication
  static Future<Map<String, String>> get _headers async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Try to get auth token first (for SSP Sanctum)
    final authToken = await _storage.read(key: 'auth_token');
    
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
      debugPrint('🔐 Using auth token for deals request');
    } else if (_apiKey != null && _apiKey!.isNotEmpty) {
      // Fallback to API key if no auth token
      headers['Authorization'] = 'Bearer $_apiKey';
      // Or use: headers['X-API-Key'] = _apiKey!;
      debugPrint('🔑 Using API key for deals request');
    }
    
    return headers;
  }
  
  /// Fetch all active deals from the API
  static Future<List<Deal>> fetchDeals({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      debugPrint('🌐 Fetching deals from: $baseUrl$activeDealsEndpoint');
      
      final headers = await _headers;
      
      final response = await http
          .get(
            Uri.parse('$baseUrl$activeDealsEndpoint'),
            headers: headers,
          )
          .timeout(timeout);
      
      debugPrint('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> dealsJson;
        
        if (jsonData is List) {
          dealsJson = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          dealsJson = jsonData['data'] as List;
        } else if (jsonData is Map && jsonData.containsKey('deals')) {
          dealsJson = jsonData['deals'] as List;
        } else {
          debugPrint('⚠️ Unexpected response format');
          return [];
        }
        
        final deals = dealsJson
            .map((dealJson) => Deal.fromJson(dealJson as Map<String, dynamic>))
            .where((deal) => deal.isValid) // Only return active, non-expired deals
            .toList();
        
        debugPrint('✅ Successfully fetched ${deals.length} deals');
        return deals;
        
      } else if (response.statusCode == 401) {
        debugPrint('🔒 Unauthorized: Invalid or missing API key');
        throw Exception('Unauthorized: Please check your API key');
      } else if (response.statusCode == 404) {
        debugPrint('❌ Deals endpoint not found');
        throw Exception('Deals endpoint not found');
      } else {
        debugPrint('❌ Failed to fetch deals: ${response.statusCode}');
        throw Exception('Failed to fetch deals: ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('❌ Error fetching deals: $e');
      rethrow;
    }
  }
  
  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing connection to $baseUrl');
      
      final headers = await _headers;
      
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));
      
      final isConnected = response.statusCode == 200 || response.statusCode == 404;
      debugPrint(isConnected ? '✅ Connection successful' : '❌ Connection failed');
      
      return isConnected;
    } catch (e) {
      debugPrint('❌ Connection test failed: $e');
      return false;
    }
  }
  
  /// Get mock deals for development/offline mode
  static List<Deal> getMockDeals() {
    return [
      Deal(
        id: 'mock_1',
        title: 'Summer Hair Package',
        description: 'Complete hair makeover with haircut, styling, and treatment',
        imageUrl: 'assets/images/Hair_care.jpg',
        originalPrice: 8000.0,
        discountedPrice: 5600.0,
        discountPercentage: 30,
        validUntil: DateTime.now().add(const Duration(days: 15)),
        category: 'Hair Care',
      ),
      Deal(
        id: 'mock_2',
        title: 'Bridal Special',
        description: 'Complete bridal package including makeup, hair, and spa',
        imageUrl: 'assets/images/Bridal.jpg',
        originalPrice: 25000.0,
        discountedPrice: 18750.0,
        discountPercentage: 25,
        validUntil: DateTime.now().add(const Duration(days: 30)),
        category: 'Special Packages',
      ),
      Deal(
        id: 'mock_3',
        title: 'Facial Glow Treatment',
        description: 'Rejuvenating facial treatment for radiant skin',
        imageUrl: 'assets/images/Basic_Facial.jpg',
        originalPrice: 4500.0,
        discountedPrice: 3150.0,
        discountPercentage: 30,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        category: 'Skin & Facial',
      ),
    ];
  }
}
