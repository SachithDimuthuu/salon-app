import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/deal.dart';
import '../services/deals_service.dart';

enum DealsStatus {
  initial,
  loading,
  loaded,
  error,
  offline,
}

class DealsProvider with ChangeNotifier {
  List<Deal> _deals = [];
  DealsStatus _status = DealsStatus.initial;
  String? _errorMessage;
  DateTime? _lastFetch;
  bool _isOnline = true;

  // Getters
  List<Deal> get deals => _deals;
  DealsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  bool get hasDeals => _deals.isNotEmpty;
  bool get isLoading => _status == DealsStatus.loading;
  bool get hasError => _status == DealsStatus.error;
  DateTime? get lastFetch => _lastFetch;
  
  // Cache duration - refresh after 30 minutes
  static const Duration cacheDuration = Duration(minutes: 30);
  
  bool get needsRefresh {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > cacheDuration;
  }

  /// Initialize and fetch deals
  Future<void> initialize() async {
    await checkConnectivity();
    if (_isOnline) {
      await fetchDeals();
    } else {
      _loadMockDeals();
    }
  }

  /// Check internet connectivity
  Future<void> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;
      debugPrint('📡 Internet connectivity: ${_isOnline ? "Online" : "Offline"}');
    } catch (e) {
      _isOnline = false;
      debugPrint('❌ Error checking connectivity: $e');
    }
  }

  /// Fetch deals from API
  Future<void> fetchDeals({bool forceRefresh = false}) async {
    // Don't fetch if we have cached data and don't need refresh
    if (!forceRefresh && !needsRefresh && _deals.isNotEmpty) {
      debugPrint('✅ Using cached deals');
      return;
    }

    _status = DealsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await checkConnectivity();

      if (!_isOnline) {
        _status = DealsStatus.offline;
        _loadMockDeals();
        notifyListeners();
        return;
      }

      final fetchedDeals = await DealsService.fetchDeals();
      
      if (fetchedDeals.isEmpty) {
        debugPrint('⚠️ No deals returned from API, using mock deals');
        _loadMockDeals();
      } else {
        _deals = fetchedDeals;
        _status = DealsStatus.loaded;
        _lastFetch = DateTime.now();
        debugPrint('✅ Loaded ${_deals.length} deals from API');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching deals: $e');
      _errorMessage = _getErrorMessage(e);
      _status = DealsStatus.error;
      
      // Load mock deals as fallback
      if (_deals.isEmpty) {
        _loadMockDeals();
      }
      
      notifyListeners();
    }
  }

  /// Load mock deals (for offline mode or development)
  void _loadMockDeals() {
    _deals = DealsService.getMockDeals();
    _status = _isOnline ? DealsStatus.loaded : DealsStatus.offline;
    debugPrint('📦 Loaded ${_deals.length} mock deals');
    notifyListeners();
  }

  /// Refresh deals (pull-to-refresh)
  Future<void> refreshDeals() async {
    await checkConnectivity();
    if (_isOnline) {
      await fetchDeals(forceRefresh: true);
    } else {
      _status = DealsStatus.offline;
      notifyListeners();
    }
  }

  /// Set API key
  void setApiKey(String apiKey) {
    DealsService.setApiKey(apiKey);
    debugPrint('🔑 API key updated');
    // Refresh deals with new API key
    fetchDeals(forceRefresh: true);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Invalid API key. Please check your settings.';
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Deals service not available.';
    } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Connection timed out. Please try again.';
    } else if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'Failed to load deals. Please try again later.';
    }
  }

  /// Clear cache
  void clearCache() {
    _deals = [];
    _lastFetch = null;
    _status = DealsStatus.initial;
    notifyListeners();
    debugPrint('🗑️ Deals cache cleared');
  }
}
