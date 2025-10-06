import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/booking_card.dart';
import '../widgets/connectivity_banner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImagePath;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  
  // Salon location coordinates - 542 Peradeniya Rd, Kandy 20000
  static const LatLng _salonLocation = LatLng(7.2906, 80.6337);
  static const String _salonPhone = '+94112345678'; // Update with actual salon phone number
  static const String _salonName = 'Luxe Hair Studio';
  static const String _salonAddress = '542 Peradeniya Rd, Kandy 20000';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permissions are permanently denied'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Move camera to show both user location and salon
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                _currentPosition!.latitude < _salonLocation.latitude 
                    ? _currentPosition!.latitude 
                    : _salonLocation.latitude,
                _currentPosition!.longitude < _salonLocation.longitude 
                    ? _currentPosition!.longitude 
                    : _salonLocation.longitude,
              ),
              northeast: LatLng(
                _currentPosition!.latitude > _salonLocation.latitude 
                    ? _currentPosition!.latitude 
                    : _salonLocation.latitude,
                _currentPosition!.longitude > _salonLocation.longitude 
                    ? _currentPosition!.longitude 
                    : _salonLocation.longitude,
              ),
            ),
            100,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _salonPhone);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error making call: $e')),
        );
      }
    }
  }

  Future<void> _openMapsNavigation() async {
    // Open Google Maps with directions to salon
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_salonLocation.latitude},${_salonLocation.longitude}',
    );
    
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }

  double? _getDistanceToSalon() {
    if (_currentPosition == null) return null;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _salonLocation.latitude,
      _salonLocation.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final auth = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Profile', style: GoogleFonts.poppins(color: Colors.white)),
        actions: [
          // Enhanced theme toggle with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: IconButton(
              key: ValueKey<IconData>(themeProvider.getThemeIcon()),
              icon: Icon(
                themeProvider.getThemeIcon(),
                color: Colors.white,
              ),
              onPressed: themeProvider.toggleTheme,
              tooltip: themeProvider.getThemeStatusText(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfileAvatar(
                      imagePath: _profileImagePath,
                      onImageChanged: (path) {
                        setState(() {
                          _profileImagePath = path;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(auth.name ?? '', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(auth.email ?? '', style: GoogleFonts.poppins(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Booking History', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 8),
                  if (bookingProvider.bookings.isEmpty)
                    Text('No bookings yet.', style: GoogleFonts.poppins()),
                  ...bookingProvider.bookings.reversed.map((b) => BookingCard(booking: b)),
                  const SizedBox(height: 24),
                  Text('Salon Location', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 8),
                  
                  // Address display
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _salonAddress,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Distance indicator
                  if (_currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Distance: ${(_getDistanceToSalon()! / 1000).toStringAsFixed(2)} km away',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  
                  // Map
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: _salonLocation,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('salon'),
                                position: _salonLocation,
                                infoWindow: const InfoWindow(
                                  title: 'Luxe Hair Studio',
                                  snippet: '542 Peradeniya Rd, Kandy 20000',
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                              ),
                              if (_currentPosition != null)
                                Marker(
                                  markerId: const MarkerId('user'),
                                  position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                  infoWindow: const InfoWindow(title: 'Your Location'),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                                ),
                            },
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                          ),
                          
                          // Refresh location button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: FloatingActionButton.small(
                              backgroundColor: Colors.white,
                              onPressed: _getCurrentLocation,
                              child: Icon(Icons.my_location, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openMapsNavigation,
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _makePhoneCall,
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Salon'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
