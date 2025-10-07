import 'dart:async';
import '../config/api_config.dart';
import '../models/service_models.dart';
import '../models/auth_models.dart';
import 'http_service.dart';

/// Service for managing salon services API calls
class ServicesApiService {
  static final HttpService _httpService = HttpService.instance;
  
  // Cache for public services
  static List<Service>? _cachedPublicServices;
  static DateTime? _lastPublicServicesFetch;

  /// Get all services with optional filters and pagination
  static Future<ApiResponse<PaginatedResponse<Service>>> getServices({
    String? category,
    String? searchQuery,
    List<String>? tags,
    bool? activeOnly,
    String? visibility,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        if (category != null) 'category': category,
        if (searchQuery != null) 'q': searchQuery,
        if (tags != null) 'tags': tags.join(','),
        if (activeOnly != null) 'active': activeOnly.toString(),
        if (visibility != null) 'visibility': visibility,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      final response = await _httpService.get<PaginatedResponse<Service>>(
        ApiConfig.services,
        queryParameters: queryParams,
        fromJson: (json) => PaginatedResponse.fromJson(
          json,
          (serviceJson) => Service.fromJson(serviceJson),
        ),
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to fetch services: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get public active services (cached for performance)
  static Future<ApiResponse<List<Service>>> getPublicServices({
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we have cached data and it's still fresh
      if (!forceRefresh && 
          _cachedPublicServices != null && 
          _lastPublicServicesFetch != null &&
          DateTime.now().difference(_lastPublicServicesFetch!).inMinutes < 5) {
        return ApiResponse.success(
          data: _cachedPublicServices!,
          statusCode: 200,
          message: 'Public services retrieved from cache',
        );
      }

      final response = await _httpService.get<List<Service>>(
        ApiConfig.servicesPublic,
        fromJson: (json) {
          final dataList = json['data'] as List;
          return dataList
              .map((item) => Service.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );

      if (response.isSuccess && response.data != null) {
        // Cache the results
        _cachedPublicServices = response.data!;
        _lastPublicServicesFetch = DateTime.now();
        
        if (ApiConfig.isDebug) {
          print('✅ Cached ${response.data!.length} public services');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to fetch public services: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get a single service by ID
  static Future<ApiResponse<Service>> getService(String serviceId) async {
    try {
      final response = await _httpService.get<Service>(
        ApiConfig.getService(serviceId),
        fromJson: (json) {
          final serviceData = json['data'] as Map<String, dynamic>;
          return Service.fromJson(serviceData);
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to fetch service: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Create a new service (requires authentication)
  static Future<ApiResponse<Service>> createService({
    required String name,
    required String slug,
    required String category,
    required String description,
    required double basePrice,
    List<Map<String, dynamic>>? durations,
    List<String>? tags,
    bool active = true,
    String visibility = 'public',
  }) async {
    try {
      final serviceData = {
        'name': name,
        'slug': slug,
        'category': category,
        'description': description,
        'base_price': basePrice,
        if (durations != null) 'durations': durations,
        if (tags != null) 'tags': tags,
        'active': active,
        'visibility': visibility,
      };

      final response = await _httpService.post<Service>(
        ApiConfig.services,
        data: serviceData,
        fromJson: (json) {
          final serviceData = json['data'] as Map<String, dynamic>;
          return Service.fromJson(serviceData);
        },
      );

      if (response.isSuccess) {
        // Invalidate cache
        _invalidatePublicServicesCache();
        
        if (ApiConfig.isDebug) {
          print('✅ Service created: ${response.data?.name}');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to create service: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Update an existing service (requires authentication)
  static Future<ApiResponse<Service>> updateService(
    String serviceId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _httpService.patch<Service>(
        ApiConfig.getService(serviceId),
        data: updateData,
        fromJson: (json) {
          final serviceData = json['data'] as Map<String, dynamic>;
          return Service.fromJson(serviceData);
        },
      );

      if (response.isSuccess) {
        // Invalidate cache
        _invalidatePublicServicesCache();
        
        if (ApiConfig.isDebug) {
          print('✅ Service updated: ${response.data?.name}');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to update service: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Delete a service (requires authentication)
  static Future<ApiResponse<String>> deleteService(String serviceId) async {
    try {
      final response = await _httpService.delete<String>(
        ApiConfig.getService(serviceId),
        fromJson: (json) => json['message'] as String,
      );

      if (response.isSuccess) {
        // Invalidate cache
        _invalidatePublicServicesCache();
        
        if (ApiConfig.isDebug) {
          print('✅ Service deleted: $serviceId');
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to delete service: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Search services by query
  static Future<ApiResponse<List<Service>>> searchServices(
    String query, {
    String? category,
    bool activeOnly = true,
  }) async {
    try {
      // First try to get from cached public services
      final publicServicesResponse = await getPublicServices();
      
      if (publicServicesResponse.isSuccess && publicServicesResponse.data != null) {
        final filteredServices = publicServicesResponse.data!.where((service) {
          final matchesQuery = service.matchesSearch(query);
          final matchesCategory = category == null || 
                                 service.category.toLowerCase() == category.toLowerCase();
          final isActive = !activeOnly || service.active;
          
          return matchesQuery && matchesCategory && isActive;
        }).toList();

        return ApiResponse.success(
          data: filteredServices,
          statusCode: 200,
          message: 'Search completed successfully',
        );
      }

      // Fallback to API search
      return await getServices(
        searchQuery: query,
        category: category,
        activeOnly: activeOnly,
        perPage: 100, // Get more results for search
      ).then((response) {
        if (response.isSuccess && response.data != null) {
          return ApiResponse.success(
            data: response.data!.data,
            statusCode: response.statusCode!,
            message: response.message,
          );
        }
        return ApiResponse.error(error: response.error!);
      });
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Search failed: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get services by category
  static Future<ApiResponse<List<Service>>> getServicesByCategory(
    String category, {
    bool activeOnly = true,
  }) async {
    try {
      final response = await getServices(
        category: category,
        activeOnly: activeOnly,
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
          message: 'Failed to get services by category: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get all available categories
  static Future<ApiResponse<List<String>>> getCategories() async {
    try {
      final response = await getPublicServices();
      
      if (response.isSuccess && response.data != null) {
        final categories = response.data!
            .map((service) => service.category)
            .toSet()
            .toList();
        
        categories.sort();
        
        return ApiResponse.success(
          data: categories,
          statusCode: 200,
          message: 'Categories retrieved successfully',
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to get categories: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Get featured services (services with 'featured' tag)
  static Future<ApiResponse<List<Service>>> getFeaturedServices() async {
    try {
      final response = await getPublicServices();
      
      if (response.isSuccess && response.data != null) {
        final featuredServices = response.data!
            .where((service) => service.hasTag('featured') || service.hasTag('popular'))
            .toList();
        
        return ApiResponse.success(
          data: featuredServices,
          statusCode: 200,
          message: 'Featured services retrieved successfully',
        );
      }

      return ApiResponse.error(error: response.error!);
    } catch (e) {
      return ApiResponse.error(
        error: ApiError(
          message: 'Failed to get featured services: $e',
          statusCode: null,
        ),
      );
    }
  }

  /// Clear cached public services
  static void _invalidatePublicServicesCache() {
    _cachedPublicServices = null;
    _lastPublicServicesFetch = null;
    
    if (ApiConfig.isDebug) {
      print('🗑️ Public services cache invalidated');
    }
  }

  /// Force refresh public services cache
  static Future<ApiResponse<List<Service>>> refreshPublicServices() async {
    return await getPublicServices(forceRefresh: true);
  }

  /// Get cache info for debugging
  static Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedServices': _cachedPublicServices != null,
      'cachedServicesCount': _cachedPublicServices?.length ?? 0,
      'lastFetchTime': _lastPublicServicesFetch?.toIso8601String(),
      'minutesSinceLastFetch': _lastPublicServicesFetch != null
          ? DateTime.now().difference(_lastPublicServicesFetch!).inMinutes
          : null,
      'isCacheExpired': _lastPublicServicesFetch != null
          ? DateTime.now().difference(_lastPublicServicesFetch!).inMinutes >= 5
          : true,
    };
  }

  /// Preload public services cache
  static Future<void> preloadCache() async {
    try {
      await getPublicServices();
      if (ApiConfig.isDebug) {
        print('✅ Services cache preloaded');
      }
    } catch (e) {
      if (ApiConfig.isDebug) {
        print('❌ Failed to preload services cache: $e');
      }
    }
  }
}