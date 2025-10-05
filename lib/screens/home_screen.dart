import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_drawer.dart';
import '../widgets/luxe_animations.dart';
import 'all_services_screen.dart';
import 'service_detail_screen.dart';
import '../widgets/smooth_transitions.dart';
import '../utils/luxe_colors.dart';
import '../utils/luxe_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Category image mapping for proper asset management
  final Map<String, String> categoryImages = {
    'Hair Care': 'assets/images/hair.jpg',
    'Skin & Facial': 'assets/images/skin.jpg',
    'Nails': 'assets/images/nails.jpg',
    'Makeup': 'assets/images/makeup.jpg',
    'Waxing': 'assets/images/waxing.jpg',
    'Spa': 'assets/images/spa.jpg',
    'Eyebrow/Eyelash': 'assets/images/eyebrow.jpg',
    'Special Packages': 'assets/images/packages.jpg',
  };

  final List<_Category> categories = const [
    _Category('Hair Care', Icons.content_cut, 'assets/images/Hair_care.jpg'),
    _Category('Skin & Facial', Icons.face, 'assets/images/Skin_and_facial.jpg'),
    _Category('Nails', Icons.color_lens, 'assets/images/Nail.jpg'),
    _Category('Makeup', Icons.brush, 'assets/images/makeup.jpg'),
    _Category('Waxing', Icons.waves, 'assets/images/waxing.jpg'),
    _Category('Eyebrow/Eyelash', Icons.remove_red_eye, 'assets/images/Eyebrows&eyelashes.jpg'),
    _Category('Special Packages', Icons.card_giftcard, 'assets/images/Special_packages.jpg'),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Featured services data
  final List<Map<String, dynamic>> featuredServices = [
    {
      'name': 'Facial Treatment',
      'image': 'assets/images/Basic_Facial.jpg',
      'price': 4500.0,
      'originalPrice': 5000.0,
      'discount': '10% OFF',
    },
    {
      'name': 'Hair Cut & Style',
      'image': 'assets/images/Haircut.jpg',
      'price': 3500.0,
      'originalPrice': 4000.0,
      'discount': '12% OFF',
    },
    {
      'name': 'Manicure & Pedicure',
      'image': 'assets/images/Manicure.jpg',
      'price': 5000.0,
      'originalPrice': 5800.0,
      'discount': '14% OFF',
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) return [];
    final allServices = categorizedServices.values.expand((list) => list).toList();
    return allServices.where((service) =>
      service['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Luxe Hair Studio',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Open the nearest ancestor Scaffold (MainNavScreen) drawer
              final scaffold = context.findAncestorStateOfType<ScaffoldState>();
              scaffold?.openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Hero Banner with animations
            LuxeAnimations.slideFromTop(
              duration: const Duration(milliseconds: 800),
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LuxeColors.getHeroGradient(isDarkMode),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern or SVG
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: Opacity(
                          opacity: 0.1,
                          child: SvgPicture.asset(
                            'assets/images/luxe_banner.svg',
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => Container(),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                'assets/images/luxe_logo.svg',
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                placeholderBuilder: (context) => const Icon(
                                  Icons.content_cut,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            'Welcome to Luxe Hair Studio',
                            style: LuxeTypography.withColor(
                              LuxeTypography.headline1,
                              Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Elegant Tagline
                          Text(
                            'Transforming Beauty Into Luxury ✨',
                            style: LuxeTypography.withColor(
                              LuxeTypography.salonTagline,
                              Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Modern Search Bar with clear button and focus states
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search services…",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[500], 
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search, 
                      color: primaryColor.withOpacity(0.7),
                      size: 24,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 2),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
            ),
            
            // Search Results or "No services found"
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _filteredServices.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            "No services found",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600], 
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, idx) {
                        final service = _filteredServices[idx];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                service['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ),
                            title: Text(
                              service['name'], 
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Text(
                              "LKR ${service['price'].toStringAsFixed(0)}", 
                              style: GoogleFonts.poppins()
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailScreen(
                                    serviceName: service['name'],
                                    description: service['description'],
                                    price: service['price'],
                                    image: service['image'],
                                    category: _findCategoryForService(service['name']),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
              ),
            
            const SizedBox(height: 32),
            
            // Featured Services Carousel
            _buildFeaturedServicesSection(primaryColor),
            
            const SizedBox(height: 32),
            
            // Why Choose Us Section
            _buildWhyChooseUsSection(primaryColor),
            
            const SizedBox(height: 32),
            
            // Categories section with "See All Services" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageTransitions.fadeTransition(
                              const AllServicesScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "See All Services",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Enhanced Category Cards with animations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return LuxeAnimations.fadeInScale(
                    delay: Duration(milliseconds: 150 * index),
                    child: LuxeAnimations.elasticButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageTransitions.slideFromRight(
                            ServicesScreen(category: cat.title),
                          ),
                        );
                      },
                      child: HoverEffect(
                        scale: 1.03,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: LuxeColors.primaryPurple.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Background Image
                                Image.asset(
                                  cat.image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LuxeColors.getCardGradient(isDarkMode),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        cat.icon,
                                        color: Colors.white,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                ),
                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                // Icon in top-left corner
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      cat.icon,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                // Category Title at bottom
                                Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                  child: Text(
                                    cat.title,
                                    style: LuxeTypography.withColor(
                                      LuxeTypography.cardTitle,
                                      Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Featured Services Carousel Section
  Widget _buildFeaturedServicesSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Services",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    SmoothPageTransitions.fadeTransition(
                      const AllServicesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredServices.length,
            itemBuilder: (context, index) {
              final service = featuredServices[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        // Navigate to service detail
                        Navigator.push(
                          context,
                          SmoothPageTransitions.slideFromRight(
                            ServiceDetailScreen(
                              serviceName: service['name'],
                              description: 'Professional ${service['name'].toLowerCase()} service',
                              price: service['price'].toDouble(),
                              image: service['image'],
                              category: 'Featured',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with discount badge
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                Image.asset(
                                  service['image'],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor.withOpacity(0.8),
                                          primaryColor.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.spa,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                // Discount badge
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: LuxeColors.accentPink,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      service['discount'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Service details
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Text(
                                        'LKR ${service['price'].toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'LKR ${service['originalPrice'].toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          decoration: TextDecoration.lineThrough,
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Why Choose Us Section - Premium Design
  Widget _buildWhyChooseUsSection(Color primaryColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> reasons = [
      {
        'icon': Icons.psychology, // 👩‍🎨 Expert Stylists
        'title': 'Expert Stylists',
        'description': 'Certified professionals with years of experience',
        'gradient': isDarkMode 
          ? const LinearGradient(
              colors: [LuxeColors.darkModePrimary, LuxeColors.darkModeSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [LuxeColors.primaryPurple, Color(0xFF7A57B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      },
      {
        'icon': Icons.eco, // 🌿 Premium Products
        'title': 'Premium Products',
        'description': 'Organic, salon-grade beauty products',
        'gradient': isDarkMode 
          ? const LinearGradient(
              colors: [LuxeColors.darkModeSecondary, Color(0xFF4A2966)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [Color(0xFF7A57B3), LuxeColors.accentPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      },
      {
        'icon': Icons.spa, // 🧘 Relaxing Atmosphere
        'title': 'Relaxing Atmosphere',
        'description': 'Peaceful environment for ultimate comfort',
        'gradient': isDarkMode 
          ? const LinearGradient(
              colors: [Color(0xFF4A2966), LuxeColors.darkModePrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [LuxeColors.accentPink, LuxeColors.lightPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      },
      {
        'icon': Icons.diamond, // � Affordable Luxury
        'title': 'Affordable Luxury',
        'description': 'Premium services at accessible prices',
        'gradient': isDarkMode 
          ? const LinearGradient(
              colors: [LuxeColors.darkModePrimary, Color(0xFF6B4A7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [LuxeColors.primaryPurple, LuxeColors.deepPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Why Choose Luxe Hair Studio?",
            style: LuxeTypography.withColor(
              LuxeTypography.headline2,
              Colors.grey[800]!,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reasons.length,
            itemBuilder: (context, index) {
              final reason = reasons[index];
              return LuxeAnimations.fadeInScale(
                delay: Duration(milliseconds: 200 * index),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    gradient: reason['gradient'] as LinearGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LuxeColors.primaryPurple.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            reason['icon'],
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          reason['title'],
                          style: LuxeTypography.withColor(
                            LuxeTypography.cardTitle,
                            Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            reason['description'],
                            style: LuxeTypography.withColor(
                              LuxeTypography.bodySmall,
                              Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String? _findCategoryForService(String serviceName) {
    for (final entry in categorizedServices.entries) {
      if (entry.value.any((s) => s['name'] == serviceName)) {
        return entry.key;
      }
    }
    return null;
  }
}

class _Category {
  final String title;
  final IconData icon;
  final String image;
  const _Category(this.title, this.icon, this.image);
}
