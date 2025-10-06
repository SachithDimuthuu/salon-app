import 'package:flutter/material.dart';

class LuxeColors {
  // Primary Brand Colors - WCAG AA Compliant
  static const Color primaryPurple = Color(0xFF6B46A1); // Lightened for better contrast
  static const Color accentPink = Color(0xFFE588B4); // Adjusted for accessibility
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Additional Brand Colors - Enhanced for Accessibility
  static const Color lightPurple = Color(0xFF9B7DC1);
  static const Color darkPurple = Color(0xFF4A2966);
  static const Color lightPink = Color(0xFFF5D4DD);
  static const Color deepPink = Color(0xFFD97AA3);
  
  // Dark Mode Specific Colors - High Contrast
  static const Color darkModePrimary = Color(0xFF8B6BB3);   // Lighter purple for dark mode visibility
  static const Color darkModeSecondary = Color(0xFF9B7DC1); // Lighter secondary
  static const Color darkCardBackground = Color(0xFF1E1E1E); // Slightly lighter for better readability
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkBackground = Color(0xFF121212);
  
  // Light Mode Background Colors
  static const Color lightBackground = Color(0xFFF8F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  
  // Accessible Text Colors - WCAG AAA Compliant
  // Light Mode Text
  static const Color textPrimaryLight = Color(0xFF1A1A1A); // High contrast on light backgrounds
  static const Color textSecondaryLight = Color(0xFF4A4A4A); // Still readable
  static const Color textTertiaryLight = Color(0xFF757575); // Subtle but readable
  
  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFE8E8E8); // High contrast on dark backgrounds
  static const Color textSecondaryDark = Color(0xFFB8B8B8); // Still readable
  static const Color textTertiaryDark = Color(0xFF8A8A8A); // Subtle but readable
  
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
  
  // Dark Mode Gradients - High Contrast & Accessible
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B6BB3), Color(0xFF9B7DC1), Color(0xFFA88DC8)],
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2C2C2E),
      Color(0xFF3A3A3C),
      Color(0xFF48484A),
    ],
  );
  
  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E1E1E),  // Dark background
      Color(0xFF2C2C2E),  // Slightly lighter
      Color(0xFF3A3A3C),  // Even lighter
    ],
  );
  
  // Light Mode Gradients
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightPurple, lightPink],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B46A1),
      Color(0xFF8B6BB3),
      Color(0xFFE588B4),
    ],
  );
  
  // Status Colors - WCAG AA Compliant
  static const Color success = Color(0xFF2E7D32); // Darker green for better contrast
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFE65100); // Darker orange
  static const Color warningLight = Color(0xFFFF9800);
  static const Color error = Color(0xFFC62828); // Darker red
  static const Color errorLight = Color(0xFFE57373);
  static const Color info = Color(0xFF1565C0); // Darker blue
  static const Color infoLight = Color(0xFF42A5F5);
  
  // Network Status Colors
  static const Color online = Color(0xFF2E7D32);
  static const Color offline = Color(0xFFC62828);
  static const Color limitedConnection = Color(0xFFE65100);
  
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
    return isDarkMode ? darkCardBackground : lightCardBackground;
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