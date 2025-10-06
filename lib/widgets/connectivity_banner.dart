import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/luxe_colors.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> with SingleTickerProviderStateMixin {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late final Connectivity _connectivity;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _connectionStatus = result;
        });
        
        if (result == ConnectivityResult.none) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    });
    
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
      
      if (result == ConnectivityResult.none) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getConnectionMessage() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Connected via WiFi';
      case ConnectivityResult.mobile:
        return 'Connected via Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected via Ethernet';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.none:
        return 'No Internet Connection';
      default:
        return 'Connection Status Unknown';
    }
  }

  IconData _getConnectionIcon() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_alt;
      case ConnectivityResult.ethernet:
        return Icons.settings_ethernet;
      case ConnectivityResult.vpn:
        return Icons.vpn_key;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.none:
        return Icons.wifi_off;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConnectionColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return isDark ? LuxeColors.success : LuxeColors.successLight;
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
      case ConnectivityResult.bluetooth:
        return isDark ? LuxeColors.warning : LuxeColors.warningLight;
      case ConnectivityResult.none:
        return isDark ? LuxeColors.error : LuxeColors.errorLight;
      default:
        return isDark ? LuxeColors.info : LuxeColors.infoLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show banner when offline or on limited connection
    if (_connectionStatus != ConnectivityResult.none && 
        _connectionStatus != ConnectivityResult.bluetooth) {
      return const SizedBox.shrink();
    }

    return SizeTransition(
      sizeFactor: _slideAnimation,
      axisAlignment: -1.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _getConnectionColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              _getConnectionIcon(),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getConnectionMessage(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (_connectionStatus == ConnectivityResult.none)
                    Text(
                      'Some features may be limited',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (_connectionStatus == ConnectivityResult.none)
              TextButton.icon(
                onPressed: _checkInitialStatus,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

