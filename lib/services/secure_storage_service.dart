import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../config/api_config.dart';

/// Secure storage service for managing authentication tokens and user data
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Store authentication token
  static Future<void> storeToken(String token) async {
    if (kIsWeb) {
      // On web, skip secure storage as it might not work properly
      if (ApiConfig.isDebug) {
        print('🌐 Web: Skipping token storage');
      }
      return;
    }
    
    try {
      await _storage.write(key: ApiConfig.tokenKey, value: token);
      await _storage.write(
        key: ApiConfig.lastLoginKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw StorageException('Failed to store token: $e');
    }
  }

  /// Retrieve authentication token
  static Future<String?> getToken() async {
    if (kIsWeb) {
      // On web, return null as we don't store tokens
      return null;
    }
    
    try {
      return await _storage.read(key: ApiConfig.tokenKey);
    } catch (e) {
      throw StorageException('Failed to retrieve token: $e');
    }
  }

  /// Store user data
  static Future<void> storeUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: ApiConfig.userKey, value: userJson);
    } catch (e) {
      throw StorageException('Failed to store user data: $e');
    }
  }

  /// Retrieve user data
  static Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: ApiConfig.userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw StorageException('Failed to retrieve user data: $e');
    }
  }

  /// Store complete authentication response
  static Future<void> storeAuthResponse(AuthResponse authResponse) async {
    try {
      await Future.wait([
        storeToken(authResponse.token),
        storeUser(authResponse.user),
      ]);
    } catch (e) {
      throw StorageException('Failed to store authentication data: $e');
    }
  }

  /// Retrieve complete authentication data
  static Future<AuthResponse?> getAuthResponse() async {
    try {
      final token = await getToken();
      final user = await getUser();
      
      if (token != null && user != null) {
        return AuthResponse(user: user, token: token);
      }
      return null;
    } catch (e) {
      throw StorageException('Failed to retrieve authentication data: $e');
    }
  }

  /// Check if user is authenticated (has valid token and user data)
  static Future<bool> isAuthenticated() async {
    if (kIsWeb) {
      // On web, always return false for now
      return false;
    }
    
    try {
      final token = await getToken();
      final user = await getUser();
      return token != null && user != null;
    } catch (e) {
      return false;
    }
  }

  /// Get last login timestamp
  static Future<DateTime?> getLastLogin() async {
    try {
      final lastLoginStr = await _storage.read(key: ApiConfig.lastLoginKey);
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all authentication data
  static Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: ApiConfig.tokenKey),
        _storage.delete(key: ApiConfig.userKey),
        _storage.delete(key: ApiConfig.lastLoginKey),
      ]);
    } catch (e) {
      throw StorageException('Failed to clear authentication data: $e');
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }

  /// Check if token exists
  static Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get storage info for debugging
  static Future<Map<String, String?>> getStorageInfo() async {
    try {
      final allData = await _storage.readAll();
      return {
        'hasToken': (allData[ApiConfig.tokenKey] != null).toString(),
        'hasUser': (allData[ApiConfig.userKey] != null).toString(),
        'hasLastLogin': (allData[ApiConfig.lastLoginKey] != null).toString(),
        'tokenLength': allData[ApiConfig.tokenKey]?.length.toString(),
        'lastLogin': allData[ApiConfig.lastLoginKey],
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Store custom key-value pair
  static Future<void> storeCustom(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException('Failed to store custom data: $e');
    }
  }

  /// Retrieve custom value by key
  static Future<String?> getCustom(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to retrieve custom data: $e');
    }
  }

  /// Delete custom key
  static Future<void> deleteCustom(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete custom data: $e');
    }
  }

  /// Check if storage is available
  static Future<bool> isStorageAvailable() async {
    try {
      await _storage.write(key: 'test_key', value: 'test_value');
      final testValue = await _storage.read(key: 'test_key');
      await _storage.delete(key: 'test_key');
      return testValue == 'test_value';
    } catch (e) {
      return false;
    }
  }

  /// Migrate old storage keys if needed
  static Future<void> migrateStorageKeys() async {
    try {
      // Check for old keys and migrate if necessary
      final oldTokenKey = 'access_token';
      final oldUserKey = 'user_info';
      
      final oldToken = await _storage.read(key: oldTokenKey);
      final oldUser = await _storage.read(key: oldUserKey);
      
      if (oldToken != null) {
        await storeToken(oldToken);
        await _storage.delete(key: oldTokenKey);
      }
      
      if (oldUser != null) {
        try {
          final userData = jsonDecode(oldUser) as Map<String, dynamic>;
          final user = User.fromJson(userData);
          await storeUser(user);
          await _storage.delete(key: oldUserKey);
        } catch (e) {
          // If migration fails, just delete the old key
          await _storage.delete(key: oldUserKey);
        }
      }
    } catch (e) {
      // Migration errors are not critical
      if (ApiConfig.isDebug) {
        print('Storage migration warning: $e');
      }
    }
  }

  /// Get token expiry information (if available)
  static Future<Map<String, dynamic>?> getTokenInfo() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      // Basic token info
      final parts = token.split('|');
      if (parts.length >= 2) {
        return {
          'tokenId': parts[0],
          'tokenLength': token.length,
          'hasBearer': token.startsWith('Bearer '),
          'createdAt': await getLastLogin(),
        };
      }
      
      return {
        'tokenLength': token.length,
        'hasBearer': token.startsWith('Bearer '),
        'createdAt': await getLastLogin(),
      };
    } catch (e) {
      return null;
    }
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  
  const StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}

/// Storage utility methods
class StorageUtils {
  /// Format token for display (mask sensitive parts)
  static String formatTokenForDisplay(String token) {
    if (token.length <= 20) {
      return '${token.substring(0, 4)}***${token.substring(token.length - 4)}';
    }
    return '${token.substring(0, 10)}***${token.substring(token.length - 10)}';
  }
  
  /// Check if token format is valid
  static bool isValidTokenFormat(String token) {
    // Basic validation - should contain pipe separator for Sanctum tokens
    return token.contains('|') && token.length > 20;
  }
  
  /// Calculate storage usage (approximate)
  static Future<Map<String, int>> calculateStorageUsage() async {
    try {
      final token = await SecureStorageService.getToken();
      final userJson = await SecureStorageService.getCustom(ApiConfig.userKey);
      final lastLogin = await SecureStorageService.getCustom(ApiConfig.lastLoginKey);
      
      return {
        'tokenBytes': token?.length ?? 0,
        'userDataBytes': userJson?.length ?? 0,
        'lastLoginBytes': lastLogin?.length ?? 0,
        'totalBytes': (token?.length ?? 0) + 
                     (userJson?.length ?? 0) + 
                     (lastLogin?.length ?? 0),
      };
    } catch (e) {
      return {'error': -1};
    }
  }
}