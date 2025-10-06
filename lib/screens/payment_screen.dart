import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/booking_history_provider.dart';
import '../utils/luxe_colors.dart';

class PaymentScreen extends StatefulWidget {
  final String serviceName;
  final String description;
  final double price;
  final String image;
  final String category;
  final DateTime selectedDate;
  final String timeSlot;

  const PaymentScreen({
    super.key,
    required this.serviceName,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.selectedDate,
    required this.timeSlot,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // Form keys
  final _formKey = GlobalKey<FormState>();
  
  // State
  bool _isProcessing = false;
  String _cardType = '';
  
  // Bank transfer image
  File? _bankSlipImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener for card number formatting
    _cardNumberController.addListener(_formatCardNumber);
    _expiryController.addListener(_formatExpiryDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _formatCardNumber() {
    final text = _cardNumberController.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    
    final newText = buffer.toString();
    if (newText != _cardNumberController.text) {
      _cardNumberController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    
    // Update card type
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    setState(() {
      _cardType = paymentProvider.getCardType(text);
    });
  }

  void _formatExpiryDate() {
    final text = _expiryController.text.replaceAll('/', '');
    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2, text.length > 4 ? 4 : text.length) : '';
      final formatted = year.isEmpty ? month : '$month/$year';
      
      if (formatted != _expiryController.text) {
        _expiryController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A1B9A);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.credit_card), text: 'Card'),
            Tab(icon: Icon(Icons.account_balance), text: 'Bank Transfer'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Booking Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.spa,
                            color: primaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year} at ${widget.timeSlot}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${widget.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Price',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      '\$${widget.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Fee (10%)',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '\$${(widget.price * 0.10).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining (at salon)',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '\$${(widget.price * 0.90).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are required to pay only 10% of the service price now as a non-refundable booking fee. The remaining balance is payable at the salon.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount Due Now',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${(widget.price * 0.10).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Payment Methods
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardPaymentTab(),
                _buildBankPaymentTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Consumer<PaymentProvider>(
            builder: (context, paymentProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                onPressed: _isProcessing || paymentProvider.isLoading
                    ? null
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing || paymentProvider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Processing...',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Pay Booking Fee \$${(widget.price * 0.10).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
      ), // Close SafeArea
    );
  }

  Widget _buildCardPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Bottom padding to avoid both nav bars
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Number
            Text(
              'Card Number',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
              ],
              decoration: InputDecoration(
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _cardType.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _cardType,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : null,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Card number is required';
                final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
                if (!paymentProvider.validateCardNumber(value!)) {
                  return 'Invalid card number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Expiry and CVV
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expiry Date',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
                          if (!paymentProvider.validateExpiryDate(value!)) {
                            return 'Invalid date';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CVV',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          hintText: '123',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
                          if (!paymentProvider.validateCVV(value!)) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Card Holder Name
            Text(
              'Card Holder Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'John Doe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Card holder name is required';
                if (value!.length < 2) return 'Name must be at least 2 characters';
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Security Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your payment information is secure and encrypted',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankPaymentTab() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Bottom padding to avoid both nav bars
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank details card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LuxeColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: LuxeColors.primaryPurple,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bank Transfer',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            Text(
                              'Transfer to our account',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  _buildBankDetail('Bank Name', 'Commercial Bank'),
                  _buildBankDetail('Account Name', 'Luxe Hair Studio Pvt Ltd'),
                  _buildBankDetail('Account Number', '1234567890'),
                  _buildBankDetail('Branch', 'Kandy'),
                  _buildBankDetail('Amount', 'Rs. ${widget.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Upload slip section
          Text(
            'Upload Bank Slip',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please upload a clear photo of your bank transfer slip for verification.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          // Image preview or upload button
          if (_bankSlipImage != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.file(
                      _bankSlipImage!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickBankSlipImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Change'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _bankSlipImage = null;
                              });
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: LuxeColors.primaryPurple.withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                borderRadius: BorderRadius.circular(16),
                color: LuxeColors.primaryPurple.withOpacity(0.05),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showImageSourceDialog(),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: LuxeColors.primaryPurple.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to Upload Bank Slip',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: LuxeColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Take photo or choose from gallery',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your booking will be marked as PENDING until admin verifies your bank transfer.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _bankSlipImage == null || _isProcessing
                  ? null
                  : _processBankTransferPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: LuxeColors.primaryPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _bankSlipImage == null ? 0 : 4,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit for Verification',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBankDetail(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _pickBankSlipImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      
      if (image != null) {
        setState(() {
          _bankSlipImage = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bank slip image selected successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } on Exception catch (e) {
      debugPrint('Image picker error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Unexpected error picking image: ${e.runtimeType} - ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please check camera/storage permissions.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _showImageSourceDialog() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload Bank Slip',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LuxeColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: LuxeColors.primaryPurple),
                ),
                title: Text(
                  'Camera',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Take a photo of your bank slip',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickBankSlipImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LuxeColors.accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: LuxeColors.accentPink),
                ),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Choose from your photos',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickBankSlipImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _processBankTransferPayment() async {
    if (_bankSlipImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your bank transfer slip'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      final bookingHistory = Provider.of<BookingHistoryProvider>(context, listen: false);
      
      // Create booking with PENDING status via addBooking method
      await bookingHistory.addBooking(
        serviceName: widget.serviceName,
        description: widget.description,
        price: widget.price,
        image: widget.image,
        category: widget.category,
        date: widget.selectedDate,
        timeSlot: widget.timeSlot,
      );
      
      // Update the last booking status to pending (since addBooking creates it as confirmed)
      if (bookingHistory.bookingHistory.isNotEmpty) {
        final lastBooking = bookingHistory.bookingHistory.first;
        await bookingHistory.updateBookingStatus(lastBooking['id'], 'pending');
      }
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showPendingSuccessDialog();
      }
    } on FormatException catch (e) {
      debugPrint('Format error in bank transfer: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid data format. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Bank transfer error: ${e.runtimeType} - ${e.toString()}');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        final errorMessage = e.toString().contains('Firebase')
          ? 'Network error. Please check your connection.'
          : 'Failed to submit bank transfer. Please try again.';
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _showPendingSuccessDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Pending!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your booking has been submitted and is awaiting admin verification.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive a notification once your payment is verified.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Coming Soon',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '$method integration is coming soon! For now, please use credit/debit card payment.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF6A1B9A)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_tabController.index == 0) {
      // Card payment
      if (!_formKey.currentState!.validate()) return;
      
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      
      if (!isOnline) {
        // Show offline message and save pending payment
        if (mounted) {
          _showOfflinePaymentDialog();
        }
        return;
      }
      
      setState(() => _isProcessing = true);
      
      try {
        final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
        
        // Create payment intent for 10% booking fee
        final bookingFee = widget.price * 0.10;
        final transaction = await paymentProvider.createPaymentIntent(
          bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
          serviceName: widget.serviceName,
          amount: bookingFee,
          method: PaymentMethod.creditCard,
          metadata: {
            'date': widget.selectedDate.toIso8601String(),
            'timeSlot': widget.timeSlot,
            'category': widget.category,
            'totalServicePrice': widget.price.toString(),
            'bookingFeePaid': bookingFee.toString(),
            'remainingBalance': (widget.price * 0.90).toString(),
          },
        );
        
        // Process payment
        final success = await paymentProvider.processPayment(
          transactionId: transaction.id,
          cardNumber: _cardNumberController.text,
          expiryDate: _expiryController.text,
          cvv: _cvvController.text,
          cardHolderName: _cardHolderController.text,
        );
        
        if (success) {
          await _onPaymentSuccess(transaction.id);
        } else {
          await _onPaymentFailure();
        }
        
      } on FormatException catch (e) {
        debugPrint('Format error in payment: $e');
        await _onPaymentFailure('Invalid payment data format. Please check your card details.');
      } catch (e) {
        // Catch all exceptions including FirebaseException
        debugPrint('Payment error: ${e.runtimeType} - ${e.toString()}');
        final errorMessage = e.toString().contains('Firebase') 
          ? 'Network error. Please check your connection and try again.'
          : 'Payment processing failed. Please try again.';
        await _onPaymentFailure(errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    } else {
      // Other payment methods (coming soon)
      _showComingSoonDialog('Selected payment method');
    }
  }

  Future<void> _onPaymentSuccess(String transactionId) async {
    // Save booking to history with 10% booking fee structure
    final historyProvider = Provider.of<BookingHistoryProvider>(context, listen: false);
    final bookingFee = widget.price * 0.10;
    
    await historyProvider.addBooking(
      serviceName: widget.serviceName,
      description: widget.description,
      price: bookingFee, // Only the booking fee amount
      image: widget.image,
      category: widget.category,
      date: widget.selectedDate,
      timeSlot: widget.timeSlot,
    );
    
    // Send notifications
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerName = authProvider.name ?? 'Customer';
    final dateTimeStr = '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year} at ${widget.timeSlot}';
    
    await notificationProvider.sendBookingConfirmation(
      customerName,
      widget.serviceName,
      dateTimeStr,
    );
    
    // Navigate to success screen
    if (mounted) {
      final bookingFee = widget.price * 0.10;
      final remainingBalance = widget.price * 0.90;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            transactionId: transactionId,
            serviceName: widget.serviceName,
            amount: bookingFee,
            totalServicePrice: widget.price,
            remainingBalance: remainingBalance,
            date: widget.selectedDate,
            timeSlot: widget.timeSlot,
          ),
        ),
      );
    }
  }

  Future<void> _onPaymentFailure([String? reason]) async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Payment Failed',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            reason ?? 'Your payment could not be processed. Please check your card details and try again.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(color: const Color(0xFF6A1B9A)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showOfflinePaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text(
              'No Internet Connection',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Your payment will be processed automatically once you\'re back online. Please ensure you have an active internet connection.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6A1B9A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PaymentSuccessScreen extends StatelessWidget {
  final String transactionId;
  final String serviceName;
  final double amount; // This will be the booking fee (10%)
  final double totalServicePrice;
  final double remainingBalance;
  final DateTime date;
  final String timeSlot;

  const PaymentSuccessScreen({
    super.key,
    required this.transactionId,
    required this.serviceName,
    required this.amount,
    required this.totalServicePrice,
    required this.remainingBalance,
    required this.date,
    required this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A1B9A);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Payment Successful',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Payment Successful!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Your booking has been confirmed',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Transaction Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Service', serviceName),
                  _buildDetailRow('Date', '${date.day}/${date.month}/${date.year}'),
                  _buildDetailRow('Time', timeSlot),
                  const Divider(height: 16),
                  _buildDetailRow('Service Price', '\$${totalServicePrice.toStringAsFixed(2)}'),
                  _buildDetailRow('Advance Paid (10%)', '\$${amount.toStringAsFixed(2)}', color: Colors.green),
                  _buildDetailRow('Remaining Balance', '\$${remainingBalance.toStringAsFixed(2)}', color: Colors.orange),
                  const Divider(height: 16),
                  _buildDetailRow('Transaction ID', transactionId.substring(0, 8).toUpperCase()),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Policy Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Notice',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The advance fee is non-refundable. Remaining balance of \$${remainingBalance.toStringAsFixed(2)} is payable at the salon.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to booking history
                  Navigator.popUntil(context, (route) => route.isFirst);
                  // Could add navigation to booking history here
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View Booking History',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}