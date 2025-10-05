import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

class BookingHistoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _bookingHistory = [];
  bool _isLoading = false;
  
  List<Map<String, dynamic>> get bookingHistory => List.unmodifiable(_bookingHistory);
  bool get isLoading => _isLoading;
  
  Future<void> addBooking({
    required String serviceName,
    required String description,
    required double price,
    required String image,
    required String category,
    required DateTime date,
    required String timeSlot,
  }) async {
    final bookingFee = price * 0.10; // 10% booking fee
    final remainingBalance = price - bookingFee;
    
    final booking = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'serviceName': serviceName,
      'description': description,
      'totalServicePrice': price,
      'bookingFeePaid': bookingFee,
      'remainingBalance': remainingBalance,
      'image': image,
      'category': category,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': 'confirmed', // confirmed, pending, completed, cancelled
      'bookingDate': DateTime.now().toIso8601String(),
    };
    
    _bookingHistory.insert(0, booking); // Add to beginning for newest first
    notifyListeners();
    await _saveBookings();
    
    // Schedule reminder notification 24 hours before appointment
    try {
      await NotificationService().scheduleBookingReminder(
        serviceName: serviceName,
        appointmentDate: date,
        timeSlot: timeSlot,
      );
    } catch (e) {
      debugPrint('Error scheduling booking reminder: $e');
    }
  }
  
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final index = _bookingHistory.indexWhere((booking) => booking['id'] == bookingId);
    if (index >= 0) {
      _bookingHistory[index]['status'] = newStatus;
      notifyListeners();
      await _saveBookings();
    }
  }
  
  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = _bookingHistory.map((booking) => jsonEncode(booking)).toList();
      await prefs.setStringList('booking_history', bookingsJson);
    } catch (e) {
      debugPrint('Error saving booking history: $e');
    }
  }
  
  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getStringList('booking_history') ?? [];
      
      _bookingHistory.clear();
      for (final bookingJson in bookingsJson) {
        final booking = jsonDecode(bookingJson) as Map<String, dynamic>;
        _bookingHistory.add(booking);
      }
    } catch (e) {
      debugPrint('Error loading booking history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearHistory() {
    _bookingHistory.clear();
    notifyListeners();
    _saveBookings();
  }
  
  int get historyCount => _bookingHistory.length;
  
  List<Map<String, dynamic>> getBookingsByStatus(String status) {
    return _bookingHistory.where((booking) => booking['status'] == status).toList();
  }
}