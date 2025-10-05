import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationProvider extends ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  String? get fcmToken => _fcmToken;
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  NotificationProvider() {
    _initializeFirebaseMessaging();
    _loadNotifications();
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
        
        // Get the token each time the application loads
        _fcmToken = await _firebaseMessaging.getToken();
        debugPrint('FCM Token: $_fcmToken');
        
        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          notifyListeners();
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint('Message also contained a notification: ${message.notification}');
            _addNotification(
              title: message.notification!.title ?? 'Luxe Hair Studio',
              body: message.notification!.body ?? 'You have a new notification',
              data: message.data,
            );
          }
        });

        // Handle background/terminated app messages
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('A new onMessageOpenedApp event was published!');
          _handleNotificationTap(message);
        });

        // Check if app was opened from a terminated state via notification
        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    // Handle navigation based on notification type
    // This would typically navigate to specific screens
    _addNotification(
      title: message.notification?.title ?? 'Luxe Hair Studio',
      body: message.notification?.body ?? 'Notification opened',
      data: message.data,
      isRead: true, // Mark as read since user tapped it
    );
  }

  void _addNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    bool isRead = false,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': isRead,
      'type': data?['type'] ?? 'general',
    };

    _notifications.insert(0, notification);
    notifyListeners();
    _saveNotifications();
  }

  // Predefined notification types for the salon
  Future<void> sendBookingReminder(String customerName, String serviceName, String dateTime) async {
    _addNotification(
      title: 'Booking Reminder',
      body: 'Hi $customerName! Your $serviceName appointment is scheduled for $dateTime',
      data: {
        'type': 'booking_reminder',
        'customerName': customerName,
        'serviceName': serviceName,
        'dateTime': dateTime,
      },
    );
  }

  Future<void> sendPromotionNotification(String title, String description, String? imageUrl) async {
    _addNotification(
      title: title,
      body: description,
      data: {
        'type': 'promotion',
        'imageUrl': imageUrl,
      },
    );
  }

  Future<void> sendBookingConfirmation(String customerName, String serviceName, String dateTime) async {
    _addNotification(
      title: 'Booking Confirmed!',
      body: 'Your $serviceName appointment on $dateTime has been confirmed',
      data: {
        'type': 'booking_confirmation',
        'customerName': customerName,
        'serviceName': serviceName,
        'dateTime': dateTime,
      },
    );
  }

  Future<void> sendGeneralNotification(String title, String body) async {
    _addNotification(
      title: title,
      body: body,
      data: {'type': 'general'},
    );
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index >= 0) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
      _saveNotifications();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    notifyListeners();
    _saveNotifications();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
    _saveNotifications();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
    _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((n) => jsonEncode(n)).toList();
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      _notifications.clear();
      for (final notificationJson in notificationsJson) {
        final notification = jsonDecode(notificationJson) as Map<String, dynamic>;
        _notifications.add(notification);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Admin functions for sending notifications
  Future<void> adminSendBulkPromotion({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    // In a real app, this would send to all users via Firebase Admin SDK
    // For demo purposes, we'll just add to local notifications
    _addNotification(
      title: title,
      body: body,
      data: {
        'type': 'admin_promotion',
        'imageUrl': imageUrl,
        'isBulk': true,
      },
    );
    
    debugPrint('Admin sent bulk promotion: $title');
  }

  Future<void> adminSendBookingUpdate({
    required String customerName,
    required String serviceName,
    required String status,
    required String message,
  }) async {
    _addNotification(
      title: 'Booking Update',
      body: message,
      data: {
        'type': 'booking_update',
        'customerName': customerName,
        'serviceName': serviceName,
        'status': status,
      },
    );
    
    debugPrint('Admin sent booking update for $customerName');
  }

  // Get notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['data']['type'] == type).toList();
  }

  // Get recent notifications (last 7 days)
  List<Map<String, dynamic>> getRecentNotifications() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) {
      final timestamp = DateTime.parse(n['timestamp']);
      return timestamp.isAfter(oneWeekAgo);
    }).toList();
  }
}