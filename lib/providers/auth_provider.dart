import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  bool _isAdmin = false;
  bool _isLoading = false;

  String? get name => _name;
  String? get email => _email;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _name != null && _email != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('user_name');
      _email = prefs.getString('user_email');
      _isAdmin = prefs.getBool('is_admin') ?? false;
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return "Name, email, and password required";
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      
      _isAdmin = email.toLowerCase() == 'admin@salon.com';
      await prefs.setBool('is_admin', _isAdmin);
      
      _name = name;
      _email = email;
    } catch (e) {
      debugPrint('Error during registration: $e');
      _isLoading = false;
      notifyListeners();
      return "Registration failed. Please try again.";
    }
    
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email and password required";
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      
      _isAdmin = email.toLowerCase() == 'admin@salon.com';
      await prefs.setBool('is_admin', _isAdmin);
      
      _email = email;
      _name = prefs.getString('user_name') ?? 'User';
    } catch (e) {
      debugPrint('Error during login: $e');
      _isLoading = false;
      notifyListeners();
      return "Login failed. Please try again.";
    }
    
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> toggleAdminStatus() async {
    try {
      _isAdmin = !_isAdmin;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin', _isAdmin);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling admin status: $e');
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('is_admin');
      
      _name = null;
      _email = null;
      _isAdmin = false;
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
