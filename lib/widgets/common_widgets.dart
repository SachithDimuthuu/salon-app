import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final Color? color;
  
  const LoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A1B9A);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final Color? color;
  
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onButtonPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A1B9A);
    final effectiveColor = color ?? primaryColor;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: effectiveColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 60,
                      color: effectiveColor.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Title with fade animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // Message with slide animation
            TweenAnimationBuilder<Offset>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: const Offset(0, 0.5), end: Offset.zero),
              builder: (context, offset, child) {
                return SlideTransition(
                  position: AlwaysStoppedAnimation(offset),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Animated button
            if (onButtonPressed != null)
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: ElevatedButton.icon(
                      onPressed: onButtonPressed,
                      icon: Icon(
                        Icons.explore,
                        color: Colors.white,
                      ),
                      label: Text(
                        buttonText,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: effectiveColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}