import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/luxe_colors.dart';

/// A widget that shows real-time network connectivity status
/// Can be placed anywhere in the app to display connection info
class NetworkStatusIndicator extends StatefulWidget {
  final bool showWhenConnected;
  final EdgeInsets padding;
  
  const NetworkStatusIndicator({
    super.key,
    this.showWhenConnected = false,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _connectionStatus = result;
        });
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
    }
  }

  String _getConnectionText() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'Offline';
      default:
        return 'Unknown';
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
        return isDark ? LuxeColors.successLight : LuxeColors.success;
      case ConnectivityResult.mobile:
        return isDark ? LuxeColors.warningLight : LuxeColors.warning;
      case ConnectivityResult.none:
        return isDark ? LuxeColors.errorLight : LuxeColors.error;
      default:
        return isDark ? LuxeColors.infoLight : LuxeColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide when connected if showWhenConnected is false
    if (!widget.showWhenConnected && _connectionStatus != ConnectivityResult.none) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getConnectionIcon(),
            size: 16,
            color: _getConnectionColor(context),
          ),
          const SizedBox(width: 6),
          Text(
            _getConnectionText(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getConnectionColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
