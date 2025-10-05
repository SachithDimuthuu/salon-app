import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.nightlight : Icons.wb_sunny,
              color: Colors.white,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle Dark Mode',
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
                  ...bookingProvider.bookings.reversed.map((b) => BookingCard(booking: b)).toList(),
                  const SizedBox(height: 24),
                  Text('Salon Location', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(6.9271, 79.8612), // Example: Colombo
                        zoom: 15,
                      ),
                      markers: {
                        const Marker(
                          markerId: MarkerId('salon'),
                          position: LatLng(6.9271, 79.8612),
                          infoWindow: InfoWindow(title: 'Luxe Hair Studio'),
                        ),
                      },
                      onMapCreated: (controller) {},
                      myLocationButtonEnabled: false,
                    ),
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
