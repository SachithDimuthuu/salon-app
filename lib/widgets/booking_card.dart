import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/booking_provider.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.service,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${booking.date.day}/${booking.date.month}/${booking.date.year} at ${booking.timeSlot}",
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            if (booking.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                "Notes: ${booking.notes}",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

