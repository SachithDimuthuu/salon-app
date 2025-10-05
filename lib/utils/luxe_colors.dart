import 'package:flutter/material.dart';

class LuxeColors {
  // Primary Brand Colors
  static const Color primaryPurple = Color(0xFF5E3B8A);
  static const Color accentPink = Color(0xFFEFB7C6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Additional Brand Colors
  static const Color lightPurple = Color(0xFF8A6BB3);
  static const Color darkPurple = Color(0xFF4A2966);
  static const Color lightPink = Color(0xFFF5D4DD);
  static const Color deepPink = Color(0xFFE58FA3);
  
  // Dark Mode Specific Colors
  static const Color darkModePrimary = Color(0xFF3D2354);   // Deeper purple for dark mode
  static const Color darkModeSecondary = Color(0xFF2A1A3E); // Even deeper purple
  static const Color darkCardBackground = Color(0xFF1C1C1E); // Specified dark card color
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkBackground = Color(0xFF000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, accentPink],
  );
  
  static const LinearGradient reverseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPink, primaryPurple],
  );
  
  // Dark Mode Gradients - Deeper purple shades for elegance
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkModePrimary, darkModeSecondary, Color(0xFF8B6BB1)],
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A1A3E),
      Color(0xFF3D2354),
      Color(0xFF4A2966),
    ],
  );
  
  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0F26),  // Very deep purple
      Color(0xFF2A1A3E),  // Deep purple  
      Color(0xFF3D2354),  // Medium deep purple
    ],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightPurple, lightPink],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5E3B8A),
      Color(0xFF7A5BA3),
      Color(0xFFEFB7C6),
    ],
  );
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Utility Methods
  static Color withOpacityCustom(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Theme-aware gradient getter
  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return isDarkMode ? darkPrimaryGradient : primaryGradient;
  }
  
  static LinearGradient getCardGradient(bool isDarkMode) {
    return isDarkMode ? darkCardGradient : cardGradient;
  }
  
  static LinearGradient getHeroGradient(bool isDarkMode) {
    return isDarkMode ? darkHeroGradient : lightGradient;
  }
  
  static Color getCardBackground(bool isDarkMode) {
    return isDarkMode ? darkCardBackground : surface;
  }
  
  static BoxDecoration getGradientBoxDecoration({
    LinearGradient? gradient,
    double borderRadius = 12.0,
    Color? shadowColor,
    bool isDarkMode = false,
  }) {
    return BoxDecoration(
      gradient: gradient ?? getPrimaryGradient(isDarkMode),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadowColor != null
          ? [
              BoxShadow(
                color: shadowColor.withOpacity(isDarkMode ? 0.4 : 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}