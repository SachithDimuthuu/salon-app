import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  digitalWallet,
  bankTransfer,
}

class PaymentTransaction {
  final String id;
  final String bookingId;
  final String serviceName;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  PaymentTransaction({
    required this.id,
    required this.bookingId,
    required this.serviceName,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.metadata = const {},
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      bookingId: json['bookingId'],
      serviceName: json['serviceName'],
      amount: json['amount'].toDouble(),
      method: PaymentMethod.values[json['method']],
      status: PaymentStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      failureReason: json['failureReason'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'serviceName': serviceName,
      'amount': amount,
      'method': method.index,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  PaymentTransaction copyWith({
    PaymentStatus? status,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return PaymentTransaction(
      id: id,
      bookingId: bookingId,
      serviceName: serviceName,
      amount: amount,
      method: method,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata,
    );
  }
}

class PaymentProvider extends ChangeNotifier {
  final List<PaymentTransaction> _transactions = [];
  bool _isLoading = false;
  PaymentTransaction? _currentTransaction;

  List<PaymentTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  PaymentTransaction? get currentTransaction => _currentTransaction;

  PaymentProvider() {
    _loadTransactions();
  }

  // Create a new payment transaction
  Future<PaymentTransaction> createPaymentIntent({
    required String bookingId,
    required String serviceName,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = PaymentTransaction(
        id: const Uuid().v4(),
        bookingId: bookingId,
        serviceName: serviceName,
        amount: amount,
        method: method,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      _currentTransaction = transaction;
      _transactions.insert(0, transaction);
      await _saveTransactions();

      debugPrint('Payment intent created: ${transaction.id}');
      return transaction;
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process payment (simulated)
  Future<bool> processPayment({
    required String transactionId,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
      if (transactionIndex == -1) {
        throw Exception('Transaction not found');
      }

      final transaction = _transactions[transactionIndex];
      
      // Update status to processing
      _transactions[transactionIndex] = transaction.copyWith(
        status: PaymentStatus.processing,
      );
      notifyListeners();

      // Simulate longer processing time
      await Future.delayed(const Duration(seconds: 3));

      // Simulate payment success/failure (90% success rate for demo)
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (isSuccess) {
        _transactions[transactionIndex] = transaction.copyWith(
          status: PaymentStatus.completed,
          completedAt: DateTime.now(),
        );
        
        debugPrint('Payment successful: $transactionId');
      } else {
        _transactions[transactionIndex] = transaction.copyWith(
          status: PaymentStatus.failed,
          failureReason: 'Payment declined by card issuer',
        );
        
        debugPrint('Payment failed: $transactionId');
      }

      _currentTransaction = _transactions[transactionIndex];
      await _saveTransactions();
      return isSuccess;

    } catch (e) {
      debugPrint('Error processing payment: $e');
      
      // Update transaction status to failed
      final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
      if (transactionIndex >= 0) {
        _transactions[transactionIndex] = _transactions[transactionIndex].copyWith(
          status: PaymentStatus.failed,
          failureReason: e.toString(),
        );
        _currentTransaction = _transactions[transactionIndex];
        await _saveTransactions();
      }
      
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel payment
  Future<void> cancelPayment(String transactionId) async {
    try {
      final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
      if (transactionIndex >= 0) {
        _transactions[transactionIndex] = _transactions[transactionIndex].copyWith(
          status: PaymentStatus.cancelled,
        );
        
        if (_currentTransaction?.id == transactionId) {
          _currentTransaction = _transactions[transactionIndex];
        }
        
        await _saveTransactions();
        notifyListeners();
        debugPrint('Payment cancelled: $transactionId');
      }
    } catch (e) {
      debugPrint('Error cancelling payment: $e');
    }
  }

  // Refund payment (admin only)
  Future<bool> refundPayment(String transactionId, {String? reason}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
      if (transactionIndex == -1) {
        throw Exception('Transaction not found');
      }

      final transaction = _transactions[transactionIndex];
      if (transaction.status != PaymentStatus.completed) {
        throw Exception('Can only refund completed payments');
      }

      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 2));

      _transactions[transactionIndex] = transaction.copyWith(
        status: PaymentStatus.refunded,
      );

      await _saveTransactions();
      debugPrint('Payment refunded: $transactionId');
      return true;

    } catch (e) {
      debugPrint('Error refunding payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get transactions by status
  List<PaymentTransaction> getTransactionsByStatus(PaymentStatus status) {
    return _transactions.where((t) => t.status == status).toList();
  }

  // Get transaction by booking ID
  PaymentTransaction? getTransactionByBookingId(String bookingId) {
    try {
      return _transactions.firstWhere((t) => t.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Calculate revenue statistics
  Map<String, double> getRevenueStats() {
    final completedTransactions = getTransactionsByStatus(PaymentStatus.completed);
    
    final today = DateTime.now();
    final thisMonth = DateTime(today.year, today.month);
    final lastMonth = DateTime(today.year, today.month - 1);
    
    double totalRevenue = 0;
    double monthlyRevenue = 0;
    double lastMonthRevenue = 0;
    
    for (final transaction in completedTransactions) {
      totalRevenue += transaction.amount;
      
      if (transaction.completedAt?.isAfter(thisMonth) == true) {
        monthlyRevenue += transaction.amount;
      } else if (transaction.completedAt?.isAfter(lastMonth) == true && 
                 transaction.completedAt?.isBefore(thisMonth) == true) {
        lastMonthRevenue += transaction.amount;
      }
    }
    
    return {
      'total': totalRevenue,
      'monthly': monthlyRevenue,
      'lastMonth': lastMonthRevenue,
      'transactionCount': completedTransactions.length.toDouble(),
    };
  }

  // Clear current transaction
  void clearCurrentTransaction() {
    _currentTransaction = null;
    notifyListeners();
  }

  // Validate card number (basic Luhn algorithm)
  bool validateCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;

    int sum = 0;
    bool isEven = false;

    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  // Validate expiry date
  bool validateExpiryDate(String expiryDate) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;

    final parts = expiryDate.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final expiry = DateTime(2000 + year, month + 1);

    return expiry.isAfter(now);
  }

  // Validate CVV
  bool validateCVV(String cvv) {
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

  // Get card type from number
  String getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.startsWith('4')) return 'Visa';
    if (cleanNumber.startsWith(RegExp(r'^5[1-5]'))) return 'MasterCard';
    if (cleanNumber.startsWith(RegExp(r'^3[47]'))) return 'American Express';
    if (cleanNumber.startsWith('6011')) return 'Discover';
    
    return 'Unknown';
  }

  // Save transactions to local storage
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = _transactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('payment_transactions', transactionsJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // Load transactions from local storage
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList('payment_transactions') ?? [];
      
      _transactions.clear();
      for (final transactionJson in transactionsJson) {
        final transactionData = jsonDecode(transactionJson) as Map<String, dynamic>;
        final transaction = PaymentTransaction.fromJson(transactionData);
        _transactions.add(transaction);
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}