import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:curved_navigation_bar/curved_navigation_bar.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Services
import 'services/notification_service.dart';

// Utils
import 'utils/luxe_colors.dart';
import 'utils/luxe_typography.dart';

// Widgets
import 'widgets/app_drawer.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/service_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/booking_history_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/payment_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (wrap in try-catch for web/desktop compatibility)
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const LuxeHairStudioApp());
}

class LuxeHairStudioApp extends StatelessWidget {
  const LuxeHairStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: LuxeColors.primaryPurple,
        brightness: Brightness.light,
        primary: LuxeColors.primaryPurple,
        secondary: LuxeColors.accentPink,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: LuxeColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: LuxeTypography.appBarTitle,
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: LuxeColors.primaryPurple.withOpacity(0.2),
        surfaceTintColor: LuxeColors.primaryPurple.withOpacity(0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LuxeColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: LuxeColors.primaryPurple.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: LuxeTypography.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LuxeColors.primaryPurple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: LuxeColors.darkModePrimary,
        brightness: Brightness.dark,
        primary: LuxeColors.darkModePrimary,
        secondary: LuxeColors.accentPink,
        surface: LuxeColors.darkCardBackground,
        background: LuxeColors.darkBackground,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: LuxeColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: LuxeColors.darkModePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: LuxeTypography.appBarTitle,
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        color: LuxeColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: LuxeColors.darkModePrimary.withOpacity(0.6),
        surfaceTintColor: LuxeColors.darkModePrimary.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LuxeColors.darkModePrimary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: LuxeColors.darkModePrimary.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: LuxeTypography.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LuxeColors.darkCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LuxeColors.accentPink, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LuxeColors.darkSurface, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()..fetchServices()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..loadFavorites()),
        ChangeNotifierProvider(create: (_) => BookingHistoryProvider()..loadBookings()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Luxe Hair Studio',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 500),
            themeAnimationCurve: Curves.easeInOut,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/': (context) => const MainNavScreen(),
              '/home': (context) => const HomeScreen(),
              '/services': (context) => ServicesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/home',
    '/services',
    '/booking-history',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: AppDrawer(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: Navigator(
        key: GlobalKey<NavigatorState>(),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              switch (_routes[_selectedIndex]) {
                case '/home':
                  return const HomeScreen();
                case '/services':
                  return ServicesScreen();
                case '/booking-history':
                  return const BookingHistoryScreen();
                case '/profile':
                  return const ProfileScreen();
                default:
                  return const HomeScreen();
              }
            },
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        color: LuxeColors.primaryPurple,
        buttonBackgroundColor: LuxeColors.primaryPurple,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 28, color: Colors.white),
          Icon(Icons.content_cut, size: 28, color: Colors.white),
          Icon(Icons.calendar_today, size: 28, color: Colors.white),
          Icon(Icons.person, size: 28, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
