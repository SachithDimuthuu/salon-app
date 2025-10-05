import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Booking {
  final String service;
  final DateTime date;
  final String timeSlot;
  final String notes;
  final double totalServicePrice;
  final double bookingFeePaid;

  Booking({
    required this.service,
    required this.date,
    required this.timeSlot,
    required this.notes,
    required this.totalServicePrice,
    required this.bookingFeePaid,
  });

  double get remainingBalance => totalServicePrice - bookingFeePaid;

  Map<String, dynamic> toJson() => {
    'service': service,
    'date': date.toIso8601String(),
    'timeSlot': timeSlot,
    'notes': notes,
    'totalServicePrice': totalServicePrice,
    'bookingFeePaid': bookingFeePaid,
  };

  static Booking fromJson(Map<String, dynamic> json) => Booking(
    service: json['service'],
    date: DateTime.parse(json['date']),
    timeSlot: json['timeSlot'],
    notes: json['notes'] ?? '',
    totalServicePrice: (json['totalServicePrice'] ?? 0.0).toDouble(),
    bookingFeePaid: (json['bookingFeePaid'] ?? 0.0).toDouble(),
  );
}

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];

  List<Booking> get bookings => _bookings;

  BookingProvider() {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('bookings');
    if (data != null) {
      final List decoded = json.decode(data);
      _bookings = decoded.map((e) => Booking.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addBooking(Booking booking) async {
    _bookings.add(booking);
    await _saveBookings();
    notifyListeners();
  }

  Future<void> _saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_bookings.map((e) => e.toJson()).toList());
    await prefs.setString('bookings', data);
  }

  Future<void> clearBookings() async {
    _bookings.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookings');
    notifyListeners();
  }
}

