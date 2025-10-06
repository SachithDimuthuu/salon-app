class Deal {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final DateTime validUntil;
  final String? category;
  final bool isActive;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.validUntil,
    this.category,
    this.isActive = true,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Special Deal',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      originalPrice: (json['originalPrice'] ?? json['price'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? json['salePrice'] ?? 0).toDouble(),
      discountPercentage: json['discountPercentage'] ?? json['discount'] ?? 0,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil'])
          : DateTime.now().add(const Duration(days: 30)),
      category: json['category'],
      isActive: json['isActive'] ?? json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
      'validUntil': validUntil.toIso8601String(),
      'category': category,
      'isActive': isActive,
    };
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  
  bool get isValid => isActive && !isExpired;
  
  String get discountBadge => '$discountPercentage% OFF';
  
  double get savings => originalPrice - discountedPrice;
}
