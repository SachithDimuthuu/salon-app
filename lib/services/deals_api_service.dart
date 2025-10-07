import 'dart:async';
import '../config/api_config.dart';
import '../models/service_models.dart';
import '../models/auth_models.dart';
import 'http_service.dart';

/// Service for managing deals/offers API calls
class DealsApiService {
  static final HttpService _httpService = HttpService.instance;
  
  // Cache for active deals
  static List<Deal>? _cachedActiveDeals;
  static DateTime? _lastActiveDealsFetch;

  /// Get all deals with optional filters and pagination
  static Future<ApiResponse<PaginatedResponse<Deal>>> getDeals({
    String? serviceId,
    bool activeOnly = true,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        if (serviceId != null) 'service_id': serviceId,
        'active_only': activeOnly.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      final response = await _httpService.get<PaginatedResponse<Deal>>(
        ApiConfig.deals,
        queryParameters: queryParams,
        fromJson: (json) => PaginatedResponse.fromJson(
          json,
          (dealJson) => Deal.fromJson(dealJson),
        ),
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to fetch deals: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get active deals (cached for performance)
  static Future<ApiResponse<List<Deal>>> getActiveDeals({
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we have cached data and it's still fresh
      if (!forceRefresh && 
          _cachedActiveDeals != null && 
          _lastActiveDealsFetch != null &&
          DateTime.now().difference(_lastActiveDealsFetch!).inMinutes < 5) {
        return ApiResponse.success(
          data: _cachedActiveDeals!,
          statusCode: 200,
          message: 'Active deals retrieved from cache',
        );
      }

      final response = await _httpService.get<List<Deal>>(
        ApiConfig.dealsPublic,
        fromJson: (json) {
          final dataList = json['data'] as List;
          return dataList
              .map((item) => Deal.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );

      if (response.isSuccess && response.data != null) {
        // Filter to only include truly valid deals
        final validDeals = response.data!.where((deal) => deal.isValid).toList();
        
        // Cache the results
        _cachedActiveDeals = validDeals;
        _lastActiveDealsFetch = DateTime.now();
        
        if (ApiConfig.isDebug) {
          print('✅ Cached ${validDeals.length} active deals');
        }
        
        return ApiResponse.success(
          data: validDeals,
          statusCode: response.statusCode!,
          message: response.message,
        );
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to fetch active deals: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get a single deal by ID
  static Future<ApiResponse<Deal>> getDeal(String dealId) async {
    try {
      final response = await _httpService.get<Deal>(
        ApiConfig.getDeal(dealId),
        fromJson: (json) {
          final dealData = json['data'] as Map<String, dynamic>;
          return Deal.fromJson(dealData);
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to fetch deal: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Check if a deal is available for use
  static Future<ApiResponse<DealAvailability>> checkDealAvailability(String dealId) async {
    try {
      final response = await _httpService.get<DealAvailability>(
        ApiConfig.getDealAvailability(dealId),
        fromJson: (json) => DealAvailability.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to check deal availability: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Create a new deal (requires authentication)
  static Future<ApiResponse<Deal>> createDeal({
    required String dealName,
    required String description,
    required double discountPercentage,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = true,
    String? serviceId,
    String? terms,
    int? maxUses,
    int currentUses = 0,
  }) async {
    try {
      final dealData = {
        'DealName': dealName,
        'Description': description,
        'DiscountPercentage': discountPercentage,
        'StartDate': startDate.toIso8601String().split('T')[0],
        'EndDate': endDate.toIso8601String().split('T')[0],
        'IsActive': isActive,
        if (serviceId != null) 'ServiceID': serviceId,
        if (terms != null) 'Terms': terms,
        if (maxUses != null) 'MaxUses': maxUses,
        'CurrentUses': currentUses,
      };

      final response = await _httpService.post<Deal>(
        ApiConfig.deals,
        data: dealData,
        fromJson: (json) {
          final dealData = json['data'] as Map<String, dynamic>;
          return Deal.fromJson(dealData);
        },
      );

      if (response.isSuccess) {
        // Invalidate cache
        _invalidateActiveDealsCache();
        
        if (ApiConfig.isDebug) {
          print('✅ Deal created: ${response.data?.dealName}');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to create deal: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Update an existing deal (requires authentication)
  static Future<ApiResponse<Deal>> updateDeal(
    String dealId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _httpService.patch<Deal>(
        ApiConfig.getDeal(dealId),
        data: updateData,
        fromJson: (json) {
          final dealData = json['data'] as Map<String, dynamic>;
          return Deal.fromJson(dealData);
        },
      );

      if (response.isSuccess) {
        // Invalidate cache
        _invalidateActiveDealsCache();
        
        if (ApiConfig.isDebug) {
          print('✅ Deal updated: ${response.data?.dealName}');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to update deal: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Delete a deal (requires authentication)
  static Future<ApiResponse<String>> deleteDeal(String dealId) async {
    try {
      final response = await _httpService.delete<String>(
        ApiConfig.getDeal(dealId),
        fromJson: (json) => json['message'] as String,
      );

      if (response.isSuccess) {
        // Invalidate cache
        _invalidateActiveDealsCache();
        
        if (ApiConfig.isDebug) {
          print('✅ Deal deleted: $dealId');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to delete deal: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get deals for a specific service
  static Future<ApiResponse<List<Deal>>> getDealsForService(String serviceId) async {
    try {
      final response = await getDeals(
        serviceId: serviceId,
        activeOnly: true,
        perPage: 100,
      );

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(
          data: response.data!.data,
          statusCode: response.statusCode!,
          message: response.message,
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to get deals for service: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get expiring deals (deals that expire within a specified number of days)
  static Future<ApiResponse<List<Deal>>> getExpiringDeals({
    int daysThreshold = 7,
  }) async {
    try {
      final response = await getActiveDeals();
      
      if (response.isSuccess && response.data != null) {
        final expiringDeals = response.data!
            .where((deal) => deal.daysRemaining <= daysThreshold && deal.daysRemaining > 0)
            .toList();
        
        // Sort by days remaining (most urgent first)
        expiringDeals.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
        
        return ApiResponse.success(
          data: expiringDeals,
          statusCode: 200,
          message: 'Expiring deals retrieved successfully',
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to get expiring deals: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get best deals (highest discount percentage)
  static Future<ApiResponse<List<Deal>>> getBestDeals({
    int limit = 5,
  }) async {
    try {
      final response = await getActiveDeals();
      
      if (response.isSuccess && response.data != null) {
        final bestDeals = response.data!.toList()
          ..sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
        
        final limitedDeals = bestDeals.take(limit).toList();
        
        return ApiResponse.success(
          data: limitedDeals,
          statusCode: 200,
          message: 'Best deals retrieved successfully',
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to get best deals: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Calculate potential savings for a service with available deals
  static Future<ApiResponse<Map<String, dynamic>>> calculateSavings(
    String serviceId,
    double originalPrice,
  ) async {
    try {
      final response = await getDealsForService(serviceId);
      
      if (response.isSuccess && response.data != null) {
        if (response.data!.isEmpty) {
          return ApiResponse.success(
            data: {
              'originalPrice': originalPrice,
              'bestPrice': originalPrice,
              'savings': 0.0,
              'savingsPercentage': 0.0,
              'appliedDeal': null,
            },
            statusCode: 200,
            message: 'No deals available for this service',
          );
        }

        // Find the best deal (highest discount)
        final bestDeal = response.data!.reduce(
          (a, b) => a.discountPercentage > b.discountPercentage ? a : b,
        );

        final discountedPrice = bestDeal.calculateDiscountedPrice(originalPrice);
        final savings = originalPrice - discountedPrice;
        final savingsPercentage = (savings / originalPrice) * 100;

        return ApiResponse.success(
          data: {
            'originalPrice': originalPrice,
            'bestPrice': discountedPrice,
            'savings': savings,
            'savingsPercentage': savingsPercentage,
            'appliedDeal': bestDeal.toJson(),
          },
          statusCode: 200,
          message: 'Savings calculated successfully',
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to calculate savings: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get deal usage statistics
  static Future<ApiResponse<Map<String, dynamic>>> getDealStats(String dealId) async {
    try {
      final response = await getDeal(dealId);
      
      if (response.isSuccess && response.data != null) {
        final deal = response.data!;
        final usagePercentage = deal.maxUses != null 
            ? (deal.currentUses / deal.maxUses!) * 100 
            : null;

        return ApiResponse.success(
          data: {
            'dealId': dealId,
            'currentUses': deal.currentUses,
            'maxUses': deal.maxUses,
            'remainingUses': deal.remainingUses,
            'usagePercentage': usagePercentage,
            'daysRemaining': deal.daysRemaining,
            'isValid': deal.isValid,
            'status': deal.statusMessage,
          },
          statusCode: 200,
          message: 'Deal statistics retrieved successfully',
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to get deal statistics: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Clear cached active deals
  static void _invalidateActiveDealsCache() {
    _cachedActiveDeals = null;
    _lastActiveDealsFetch = null;
    
    if (ApiConfig.isDebug) {
      print('🗑️ Active deals cache invalidated');
    }
  }

  /// Force refresh active deals cache
  static Future<ApiResponse<List<Deal>>> refreshActiveDeals() async {
    return await getActiveDeals(forceRefresh: true);
  }

  /// Get cache info for debugging
  static Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedDeals': _cachedActiveDeals != null,
      'cachedDealsCount': _cachedActiveDeals?.length ?? 0,
      'lastFetchTime': _lastActiveDealsFetch?.toIso8601String(),
      'minutesSinceLastFetch': _lastActiveDealsFetch != null
          ? DateTime.now().difference(_lastActiveDealsFetch!).inMinutes
          : null,
      'isCacheExpired': _lastActiveDealsFetch != null
          ? DateTime.now().difference(_lastActiveDealsFetch!).inMinutes >= 5
          : true,
    };
  }

  /// Preload active deals cache
  static Future<void> preloadCache() async {
    try {
      await getActiveDeals();
      if (ApiConfig.isDebug) {
        print('✅ Deals cache preloaded');
      }
    } catch (e) {
      if (ApiConfig.isDebug) {
        print('❌ Failed to preload deals cache: $e');
      }
    }
  }

  /// Get combined cache info for both services and deals
  static Map<String, dynamic> getAllCacheInfo() {
    return {
      'deals': getCacheInfo(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}