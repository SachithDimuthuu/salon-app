import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_detail_screen.dart';
import '../widgets/smooth_transitions.dart';
import '../widgets/favorite_button.dart';

final Map<String, List<Map<String, dynamic>>> categorizedServices = {
  "Hair Care": [
    {
      "name": "Haircut",
      "price": 3000.0,
      "image": "assets/images/Haircut.jpg",
      "description": "Professional haircut tailored to your style preferences and face shape."
    },
    {
      "name": "Hair Coloring",
      "price": 6000.0,
      "image": "assets/images/Hair_coloring.jpg",
      "description": "Premium hair coloring with highlights and modern techniques."
    },
    {
      "name": "Hair Spa",
      "price": 4500.0,
      "image": "assets/images/Hair_spa.jpg",
      "description": "Luxurious hair spa treatment for smooth, shiny, and healthy hair."
    },
  ],
  "Skin & Facial": [
    {
      "name": "Basic Facial",
      "price": 4000.0,
      "image": "assets/images/Facial.jpg",
      "description": "Deep cleansing and refreshing facial for all skin types."
    },
    {
      "name": "Anti-aging Facial",
      "price": 7000.0,
      "image": "assets/images/Anti_aging.jpg",
      "description": "Advanced anti-aging treatment to reduce fine lines and wrinkles."
    },
    {
      "name": "Skin Polishing",
      "price": 5500.0,
      "image": "assets/images/Skin_polishing.jpg",
      "description": "Professional exfoliation treatment for radiant, glowing skin."
    },
  ],
  "Nails": [
    {
      "name": "Manicure",
      "price": 2500.0,
      "image": "assets/images/Manicure.jpg",
      "description": "Classic manicure with cuticle care and polish of your choice."
    },
    {
      "name": "Pedicure",
      "price": 2800.0,
      "image": "assets/images/Pedicure.jpg",
      "description": "Relaxing pedicure treatment for soft, healthy feet."
    },
    {
      "name": "Nail Art",
      "price": 3500.0,
      "image": "assets/images/Nail_arts.jpg",
      "description": "Creative nail designs with trendy patterns and durable finish."
    },
  ],
  "Makeup": [
    {
      "name": "Party Makeup",
      "price": 8000.0,
      "image": "assets/images/Party_makeup.jpg",
      "description": "Glamorous party makeup for special occasions and events."
    },
    {
      "name": "Bridal Makeup",
      "price": 15000.0,
      "image": "assets/images/Bridal.jpg",
      "description": "Stunning bridal makeup that lasts all day for your special moment."
    },
    {
      "name": "Natural Makeup",
      "price": 5000.0,
      "image": "assets/images/Natural.jpg",
      "description": "Subtle, natural makeup look perfect for everyday wear."
    },
  ],
  "Waxing": [
    {
      "name": "Full Body Wax",
      "price": 9000.0,
      "image": "assets/images/Full_body_waxing.jpg",
      "description": "Complete full body waxing service for silky smooth skin."
    },
    {
      "name": "Underarm Wax",
      "price": 1500.0,
      "image": "assets/images/Underarm.jpg",
      "description": "Quick and comfortable underarm waxing with premium wax."
    },
    {
      "name": "Face Waxing",
      "price": 2000.0,
      "image": "assets/images/Face_waxing.jpg",
      "description": "Gentle facial waxing for unwanted hair removal."
    },
  ],
  "Eyebrow/Eyelash": [
    {
      "name": "Eyebrow Shaping",
      "price": 1200.0,
      "image": "assets/images/Eyebrow_shaping.jpg",
      "description": "Professional eyebrow shaping to enhance your natural beauty."
    },
    {
      "name": "Eyelash Extensions",
      "price": 6000.0,
      "image": "assets/images/Eyelashes_extensions.jpg",
      "description": "Premium eyelash extensions for naturally long, beautiful lashes."
    },
    {
      "name": "Eyebrow Tinting",
      "price": 3500.0,
      "image": "assets/images/Eyebrow_tinting.jpg",
      "description": "Long-lasting eyebrow tinting for darker, bolder brows."
    },
  ],
  "Special Packages": [
    {
      "name": "Bridal Package",
      "price": 35000.0,
      "image": "assets/images/Bridal_package.jpg",
      "description": "Complete bridal beauty package including hair, makeup, and skincare."
    },
    {
      "name": "Grooming Package",
      "price": 15000.0,
      "image": "assets/images/Groom.jpg",
      "description": "Comprehensive grooming package with hair, skin, and nail care."
    },
    {
      "name": "Festival Package",
      "price": 12000.0,
      "image": "assets/images/Festival.jpg",
      "description": "Special festival package to get you ready for celebrations."
    },
  ],
};

class ServicesScreen extends StatelessWidget {
  final String? category;
  const ServicesScreen({super.key, this.category});

  List<Map<String, dynamic>> getServices() {
    if (category != null && categorizedServices.containsKey(category)) {
      return categorizedServices[category]!;
    }
    // If no category, show all services combined
    return categorizedServices.values.expand((list) => list).toList();
  }

  @override
  Widget build(BuildContext context) {
    final services = getServices();
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            if (category != null) ...[
              Icon(_getCategoryIcon(category!), size: 24, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                category != null ? "${category!} Services" : "All Services",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: services.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No services found",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Service Image with Favorite Button
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Hero(
                            tag: 'service_image_${service["name"]}',
                            child: Image.asset(
                              service["image"],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.3),
                                      primaryColor.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.image_not_supported, 
                                  size: 64, 
                                  color: Colors.grey[400]
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Favorite Button positioned in top-right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: FavoriteButton(
                            service: {
                              ...service,
                              'category': category ?? 'Unknown',
                            },
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Service Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service["name"],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              // Price Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "LKR ${service["price"].toStringAsFixed(0)}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            service["description"],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          // View Details Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SmoothPageTransitions.scaleAndFadeTransition(
                                    ServiceDetailScreen(
                                      serviceName: service["name"],
                                      description: service["description"],
                                      price: service["price"],
                                      image: service["image"],
                                      category: category,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.visibility, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "View Details",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hair Care':
        return Icons.content_cut;
      case 'Skin & Facial':
        return Icons.face;
      case 'Nails':
        return Icons.color_lens;
      case 'Makeup':
        return Icons.brush;
      case 'Waxing':
        return Icons.waves;
      case 'Eyebrow/Eyelash':
        return Icons.remove_red_eye;
      case 'Special Packages':
        return Icons.card_giftcard;
      default:
        return Icons.star;
    }
  }
}
