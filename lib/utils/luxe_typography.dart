import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LuxeTypography {
  // Headline Styles - Professional Hierarchy
  static TextStyle get headline1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: 0.5,
      );
      
  static TextStyle get headline2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: 0.3,
      );
      
  static TextStyle get headline3 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.2,
      );
      
  static TextStyle get headline4 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      );
      
  static TextStyle get headline5 => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
      
  static TextStyle get headline6 => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // Body Text Styles - Readable & Professional
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );
      
  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );
      
  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Special Styles
  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );
      
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.3,
      );
      
  static TextStyle get captionAccent => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.3,
      );
      
  static TextStyle get overline => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      );

  // Brand Specific Styles
  static TextStyle get brandTitle => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      );
      
  static TextStyle get brandSubtitle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.3,
        fontStyle: FontStyle.italic,
      );
      
  static TextStyle get luxeAccent => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
      );

  // App Bar Styles
  static TextStyle get appBarTitle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  // Card Styles
  static TextStyle get cardTitle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
      
  static TextStyle get cardSubtitle => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.3,
      );

  // Price & Badge Styles
  static TextStyle get priceText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
      
  static TextStyle get badgeText => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // Salon Tagline Style
  static TextStyle get salonTagline => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.3,
        height: 1.4,
      );

  // Utility Methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}