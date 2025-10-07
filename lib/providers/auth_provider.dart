import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

/// Authentication provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  // Private fields
  User? _user;
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;
  bool get hasError => _state == AuthState.error;

  // Legacy getters for compatibility
  String? get name => _user?.name;
  String? get email => _user?.email;
  bool get isLoggedIn => isAuthenticated;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Initialize the authentication provider
  Future<void> initialize() async {
    await _setLoadingState(true);
    
    try {
      if (ApiConfig.isDebug) {
        print('🔄 Initializing AuthProvider...');
        print('🔄 Platform: ${kIsWeb ? "Web" : "Mobile"}');
      }

      // Skip authentication check on web to avoid storage issues
      if (kIsWeb) {
        if (ApiConfig.isDebug) {
          print('🌐 Web platform detected - skipping auto-authentication');
        }
        _setUnauthenticatedState();
        return;
      }

      // Check for stored authentication data with timeout
      final authStatus = await AuthService.checkAuthStatus()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        if (ApiConfig.isDebug) {
          print('⚠️ Auth check timeout - proceeding as unauthenticated');
        }
        return AuthStatusResponse(isAuthenticated: false, user: null);
      });
      
      if (authStatus.isAuthenticated && authStatus.user != null) {
        _setAuthenticatedState(authStatus.user!);
        if (ApiConfig.isDebug) {
          print('✅ User auto-authenticated: ${authStatus.user!.email}');
        }
      } else {
        _setUnauthenticatedState();
        if (ApiConfig.isDebug) {
          print('ℹ️ No valid authentication found');
        }
      }
    } catch (e) {
      if (ApiConfig.isDebug) {
        print('❌ AuthProvider initialization error: $e');
      }
      // On any error, just set as unauthenticated and continue
      _setUnauthenticatedState();
    } finally {
      await _setLoadingState(false);
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    await _setLoadingState(true);
    _clearError();

    try {
      if (ApiConfig.isDebug) {
        print(' Attempting login for: $email');
      }

      final request = LoginRequest(email: email, password: password);
      final response = await AuthService.login(request);

      if (response.isSuccess && response.data != null) {
        _setAuthenticatedState(response.data!.user);
        if (ApiConfig.isDebug) {
          print(' Login successful: ${response.data!.user.email}');
        }
        return true;
      } else {
        final error = response.error?.firstError ?? 'Login failed';
        _setErrorState(error);
        if (ApiConfig.isDebug) {
          print(' Login failed: $error');
        }
        return false;
      }
    } catch (e) {
      _setErrorState('Login failed: $e');
      if (ApiConfig.isDebug) {
        print(' Login exception: $e');
      }
      return false;
    } finally {
      await _setLoadingState(false);
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _setLoadingState(true);
    _clearError();

    try {
      if (ApiConfig.isDebug) {
        print('🔄 Attempting registration for: $email');
        print('🔄 Name: $name');
        print('🔄 Password length: ${password.length}');
        print('🔄 Passwords match: ${password == passwordConfirmation}');
      }

      // Client-side validation first
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        final errorMessage = validationErrors.join(', ');
        _setErrorState(errorMessage);
        if (ApiConfig.isDebug) {
          print('❌ Client validation failed: $errorMessage');
        }
        return false;
      }

      if (ApiConfig.isDebug) {
        print('✅ Client validation passed, sending to API...');
      }

      final response = await AuthService.register(request);

      if (response.isSuccess && response.data != null) {
        _setAuthenticatedState(response.data!.user);
        if (ApiConfig.isDebug) {
          print('✅ Registration successful: ${response.data!.user.email}');
        }
        return true;
      } else {
        final error = response.error?.firstError ?? 'Registration failed';
        _setErrorState(error);
        if (ApiConfig.isDebug) {
          print('❌ Registration failed: $error');
          if (response.error != null) {
            print('❌ Full error details: ${response.error!.allErrors}');
          }
        }
        return false;
      }
    } catch (e) {
      _setErrorState('Registration failed: $e');
      if (ApiConfig.isDebug) {
        print('❌ Registration exception: $e');
      }
      return false;
    } finally {
      await _setLoadingState(false);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    await _setLoadingState(true);

    try {
      if (ApiConfig.isDebug) {
        print(' Logging out user: ${_user?.email}');
      }

      await AuthService.logout();
      _setUnauthenticatedState();
      
      if (ApiConfig.isDebug) {
        print(' Logout successful');
      }
    } catch (e) {
      if (ApiConfig.isDebug) {
        print(' Logout error: $e');
      }
      // Still set unauthenticated state even if logout API call fails
      _setUnauthenticatedState();
    } finally {
      await _setLoadingState(false);
    }
  }

  /// Clear any error state
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Legacy method: Upload profile image (placeholder for compatibility)
  Future<String?> uploadProfileImage(String imagePath) async {
    // TODO: Implement profile image upload via API
    // For now, just return null to indicate no error
    return null;
  }

  /// Legacy method: Toggle admin status (placeholder for compatibility)
  void toggleAdminStatus() {
    // TODO: Implement admin status toggle via API
    // For now, this is a no-op
  }

  // Private helper methods
  void _setAuthenticatedState(User user) {
    _user = user;
    _state = AuthState.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void _setUnauthenticatedState() {
    _user = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void _setErrorState(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _setLoadingState(bool loading) async {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
    
    // Small delay to ensure UI updates
    if (loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = isAuthenticated ? AuthState.authenticated : AuthState.unauthenticated;
    }
  }
}
