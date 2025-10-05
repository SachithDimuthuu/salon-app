import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  
  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  
  bool isFavorite(String serviceName) {
    return _favorites.any((service) => service['name'] == serviceName);
  }
  
  Future<void> toggleFavorite(Map<String, dynamic> service) async {
    final index = _favorites.indexWhere((fav) => fav['name'] == service['name']);
    
    if (index >= 0) {
      // Remove from favorites
      _favorites.removeAt(index);
    } else {
      // Add to favorites
      _favorites.add(service);
    }
    
    notifyListeners();
    await _saveFavorites();
  }
  
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites.map((service) => jsonEncode(service)).toList();
      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
  
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];
      
      _favorites.clear();
      for (final serviceJson in favoritesJson) {
        final service = jsonDecode(serviceJson) as Map<String, dynamic>;
        _favorites.add(service);
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
    _saveFavorites();
  }
  
  int get favoritesCount => _favorites.length;
}