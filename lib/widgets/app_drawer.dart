import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/booking_history_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../utils/luxe_colors.dart';
// import '../utils/luxe_typography.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onNavigate;
  
  const AppDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = LuxeColors.primaryPurple;
    
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with profile info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LuxeColors.primaryPurple, LuxeColors.accentPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand logo
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(5),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                    'assets/images/luxe_logo.svg',
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Luxe Hair Studio',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          authProvider.isLoggedIn ? Icons.person : Icons.person_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Name
                      Text(
                        authProvider.isLoggedIn 
                            ? (authProvider.name ?? 'User')
                            : 'Guest User',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      // Email
                      Text(
                        authProvider.isLoggedIn 
                            ? (authProvider.email ?? 'No email')
                            : 'Not logged in',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      
                      // Admin badge
                      if (authProvider.isAdmin) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ADMIN',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            
            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Home
                  _buildDrawerItem(
                    context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to home if not already there
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  
                  // Favorites
                  _buildDrawerItem(
                    context,
                    icon: Icons.favorite,
                    title: 'Favorites',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                      );
                    },
                  ),
                  
                  // Booking History
                  _buildDrawerItem(
                    context,
                    icon: Icons.history,
                    title: 'Booking History',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingHistoryScreen()),
                      );
                    },
                  ),
                  
                  // Admin Dashboard (only for admins)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.isAdmin) {
                        return _buildDrawerItem(
                          context,
                          icon: Icons.admin_panel_settings,
                          title: 'Admin Dashboard',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const Divider(height: 32),
                  
                  // About Us Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'About Us',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Our Story',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.contact_phone,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      _showContactDialog(context);
                    },
                  ),
                  
                  const Divider(height: 32),
                  
                  // Settings header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  // Dark Mode Toggle (Optimized for performance)
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      final isDark = themeProvider.themeMode == ThemeMode.dark;
                      final textColor = isDark ? Colors.white : Colors.black87;
                      
                      return ListTile(
                        leading: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: LuxeColors.primaryPurple,
                          size: 24,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        trailing: Switch.adaptive(
                          value: isDark,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeColor: LuxeColors.primaryPurple,
                          activeTrackColor: LuxeColors.primaryPurple.withOpacity(0.3),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      );
                    },
                  ),
                  
                  // Admin Toggle (for testing)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.isLoggedIn) {
                        return _buildDrawerItemWithSwitch(
                          context,
                          icon: Icons.admin_panel_settings,
                          title: 'Admin Mode',
                          value: authProvider.isAdmin,
                          onChanged: (value) {
                            authProvider.toggleAdminStatus();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            
            // Bottom section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Logout/Login button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (authProvider.isLoggedIn) {
                              // Logout
                              await authProvider.logout();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logged out successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              // Navigate to login
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            }
                          },
                          icon: Icon(
                            authProvider.isLoggedIn ? Icons.logout : Icons.login,
                          ),
                          label: Text(
                            authProvider.isLoggedIn ? 'Logout' : 'Login',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: authProvider.isLoggedIn ? Colors.red[400] : primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // App version
                  Text(
                    'Luxe Hair Studio v1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: LuxeColors.primaryPurple,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hoverColor: LuxeColors.primaryPurple.withOpacity(0.1),
    );
  }

  Widget _buildDrawerItemWithSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: LuxeColors.primaryPurple,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: LuxeColors.primaryPurple,
        activeTrackColor: LuxeColors.primaryPurple.withOpacity(0.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.spa,
                color: LuxeColors.primaryPurple,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'About Luxe Hair Studio',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: LuxeColors.primaryPurple,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transforming Beauty Into Luxury ✨',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: LuxeColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'At Luxe Hair Studio, we combine expert craftsmanship with premium products to deliver an unparalleled salon experience. Our passionate team of stylists is dedicated to bringing out your natural beauty with personalized care and attention.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'From hair transformations to luxurious treatments, we create a relaxing atmosphere where every visit feels like a special occasion.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: LuxeColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: LuxeColors.primaryPurple,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: LuxeColors.primaryPurple,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContactItem(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: '+1 (555) 123-LUXE',
                  onTap: () {
                    // Could add URL launcher for phone calls
                  },
                ),
                const SizedBox(height: 16),
                _buildContactItem(
                  icon: Icons.email,
                  title: 'Email',
                  value: 'hello@luxehairstudio.com',
                  onTap: () {
                    // Could add URL launcher for email
                  },
                ),
                const SizedBox(height: 16),
                _buildContactItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  value: '123 Beauty Boulevard\nLuxury District, LA 90210',
                  onTap: () {
                    // Could add maps integration
                  },
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: LuxeColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LuxeColors.primaryPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: LuxeColors.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LuxeColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: LuxeColors.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LuxeColors.primaryPurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.3,
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
}