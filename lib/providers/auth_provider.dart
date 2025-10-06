import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

/// Authentication Provider with SSP Sanctum Integration
/// Manages user authentication state and integrates with Laravel Sanctum API
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  String? _name;
  String? _email;
  String? _phone;
  String? _profileImage;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get profileImage => _profileImage;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _name != null && _email != null;

  AuthProvider() {
    _loadUser();
  }

  /// Load user data from local storage and verify token
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check if user has valid token
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        // Try to fetch current user from API
        final user = await _authService.getCurrentUser();
        
        if (user != null) {
          _userData = user;
          _name = user['name'] ?? user['username'];
          _email = user['email'];
          _phone = user['phone'];
          _profileImage = user['profile_image'] ?? user['avatar'];
          _isAdmin = user['is_admin'] == true || 
                     user['role'] == 'admin' ||
                     _email?.toLowerCase() == 'admin@salon.com';
        } else {
          // Fallback to SharedPreferences if API fails
          await _loadFromPrefs();
        }
      } else {
        // No token, load from local prefs
        await _loadFromPrefs();
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error loading user data: $e');
      // Fallback to SharedPreferences
      await _loadFromPrefs();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Fallback method to load from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('user_name');
      _email = prefs.getString('user_email');
      _phone = prefs.getString('user_phone');
      _profileImage = prefs.getString('profile_image');
      _isAdmin = prefs.getBool('is_admin') ?? false;
    } catch (e) {
      debugPrint('[AuthProvider] Error loading from prefs: $e');
    }
  }

  /// Save user data to SharedPreferences (for offline access)
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_name != null) await prefs.setString('user_name', _name!);
      if (_email != null) await prefs.setString('user_email', _email!);
      if (_phone != null) await prefs.setString('user_phone', _phone!);
      if (_profileImage != null) await prefs.setString('profile_image', _profileImage!);
      await prefs.setBool('is_admin', _isAdmin);
    } catch (e) {
      debugPrint('[AuthProvider] Error saving to prefs: $e');
    }
  }

  /// Register a new user with SSP Sanctum API
  /// Returns null on success, error message on failure
  Future<String?> register(String name, String email, String password, {String? phone}) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return "Name, email, and password required";
    }
    
    // Email validation
    if (!email.contains('@') || !email.contains('.')) {
      return "Invalid email format";
    }
    
    // Password validation
    if (password.length < 8) {
      return "Password must be at least 8 characters";
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password, // Laravel validation requirement
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };
      
      final success = await _authService.register(userData);
      
      if (success) {
        // Check if auto-login happened (token was returned)
        final isAuth = await _authService.isAuthenticated();
        
        if (isAuth) {
          // Fetch user data from API
          final user = await _authService.getCurrentUser();
          if (user != null) {
            _userData = user;
            _name = user['name'] ?? name;
            _email = user['email'] ?? email;
            _phone = user['phone'] ?? phone;
            _profileImage = user['profile_image'];
            _isAdmin = user['is_admin'] == true || user['role'] == 'admin';
          } else {
            // Manual data set if API doesn't return user
            _name = name;
            _email = email;
            _phone = phone;
            _isAdmin = email.toLowerCase() == 'admin@salon.com';
          }
        } else {
          // Registration successful but need to login separately
          _name = name;
          _email = email;
          _phone = phone;
          _isAdmin = email.toLowerCase() == 'admin@salon.com';
        }
        
        // Save to SharedPreferences for offline access
        await _saveToPrefs();
        
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        _errorMessage = "Registration failed. Please try again.";
        notifyListeners();
        return _errorMessage;
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error during registration: $e');
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _errorMessage ?? "Registration failed. Please try again.";
    }
  }

  /// Login with email and password using SSP Sanctum API
  /// Returns null on success, error message on failure
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email and password required";
    }
    
    // Email validation
    if (!email.contains('@')) {
      return "Invalid email format";
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _authService.login(email, password);
      
      if (success) {
        // Fetch user data from API
        final user = await _authService.getCurrentUser();
        
        if (user != null) {
          _userData = user;
          _name = user['name'] ?? user['username'] ?? 'User';
          _email = user['email'] ?? email;
          _phone = user['phone'];
          _profileImage = user['profile_image'] ?? user['avatar'];
          _isAdmin = user['is_admin'] == true || 
                     user['role'] == 'admin' ||
                     email.toLowerCase() == 'admin@salon.com';
        } else {
          // Fallback if user fetch fails
          _email = email;
          _name = email.split('@')[0]; // Use email prefix as name
          _isAdmin = email.toLowerCase() == 'admin@salon.com';
        }
        
        // Save to SharedPreferences for offline access
        await _saveToPrefs();
        
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        _errorMessage = "Invalid credentials";
        notifyListeners();
        return _errorMessage;
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error during login: $e');
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _errorMessage ?? "Login failed. Please check your credentials.";
    }
  }

  /// Logout user from SSP Sanctum API and clear local data
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Call API logout endpoint
      await _authService.logout();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_phone');
      await prefs.remove('profile_image');
      await prefs.remove('is_admin');
      
      // Clear provider state
      _name = null;
      _email = null;
      _phone = null;
      _profileImage = null;
      _isAdmin = false;
      _userData = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('[AuthProvider] Error during logout: $e');
      // Clear local data even if API call fails
      _name = null;
      _email = null;
      _phone = null;
      _profileImage = null;
      _isAdmin = false;
      _userData = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Toggle admin status (for testing/demo purposes)
  Future<void> toggleAdminStatus() async {
    try {
      _isAdmin = !_isAdmin;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin', _isAdmin);
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthProvider] Error toggling admin status: $e');
    }
  }

  /// Update user profile
  Future<String?> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final profileData = <String, dynamic>{};
      if (name != null && name.isNotEmpty) profileData['name'] = name;
      if (phone != null && phone.isNotEmpty) profileData['phone'] = phone;
      if (profileImage != null && profileImage.isNotEmpty) profileData['profile_image'] = profileImage;
      
      final success = await _authService.updateProfile(profileData);
      
      if (success) {
        // Update local state
        if (name != null) _name = name;
        if (phone != null) _phone = phone;
        if (profileImage != null) _profileImage = profileImage;
        
        // Save to SharedPreferences
        await _saveToPrefs();
        
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        _errorMessage = "Profile update failed";
        notifyListeners();
        return _errorMessage;
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error updating profile: $e');
      _isLoading = false;
      _errorMessage = "Profile update failed";
      notifyListeners();
      return _errorMessage;
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage(String filePath) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final imageUrl = await _authService.uploadProfileImage(filePath);
      
      if (imageUrl != null) {
        _profileImage = imageUrl;
        await _saveToPrefs();
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        return "Image upload failed";
      }
    } catch (e) {
      debugPrint('[AuthProvider] Error uploading image: $e');
      _isLoading = false;
      return "Image upload failed";
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get authentication token (for other services to use)
  Future<String?> getAuthToken() async {
    return await _authService.getToken();
  }
}
