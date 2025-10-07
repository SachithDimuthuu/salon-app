/// Service model for salon services
class Service {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String description;
  final double price;
  final int duration;
  final bool active;
  final String visibility;
  final String? image;
  final List<String> features;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.description,
    required this.price,
    required this.duration,
    required this.active,
    required this.visibility,
    this.image,
    required this.features,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Service from JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as int,
      active: json['active'] as bool,
      visibility: json['visibility'] as String,
      image: json['image'] as String?,
      features: List<String>.from(json['features'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Service to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'category': category,
      'description': description,
      'price': price,
      'duration': duration,
      'active': active,
      'visibility': visibility,
      'image': image,
      'features': features,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Service copyWith({
    String? id,
    String? name,
    String? slug,
    String? category,
    String? description,
    double? price,
    int? duration,
    bool? active,
    String? visibility,
    String? image,
    List<String>? features,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      active: active ?? this.active,
      visibility: visibility ?? this.visibility,
      image: image ?? this.image,
      features: features ?? this.features,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if service is public
  bool get isPublic => visibility == 'public';

  /// Check if service is active and public
  bool get isAvailable => active && isPublic;

  /// Get formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Get duration in hours and minutes
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    return category.replaceAll('_', ' ').toUpperCase();
  }

  /// Check if service has a specific tag
  bool hasTag(String tag) {
    return tags.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  /// Check if service matches search query
  bool matchesSearch(String query) {
    final searchQuery = query.toLowerCase();
    return name.toLowerCase().contains(searchQuery) ||
           description.toLowerCase().contains(searchQuery) ||
           category.toLowerCase().contains(searchQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(searchQuery));
  }

  @override
  String toString() {
    return 'Service(id: $id, name: $name, category: $category, price: $price)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Deal model for special offers and discounts
class Deal {
  final String id;
  final String dealName;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? serviceId;
  final String? terms;
  final int? maxUses;
  final int currentUses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Deal({
    required this.id,
    required this.dealName,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.serviceId,
    this.terms,
    this.maxUses,
    required this.currentUses,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Deal from JSON
  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['_id'] as String,
      dealName: json['DealName'] as String,
      description: json['Description'] as String,
      discountPercentage: (json['DiscountPercentage'] as num).toDouble(),
      startDate: DateTime.parse(json['StartDate'] as String),
      endDate: DateTime.parse(json['EndDate'] as String),
      isActive: json['IsActive'] as bool,
      serviceId: json['ServiceID'] as String?,
      terms: json['Terms'] as String?,
      maxUses: json['MaxUses'] as int?,
      currentUses: json['CurrentUses'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Deal to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'DealName': dealName,
      'Description': description,
      'DiscountPercentage': discountPercentage,
      'StartDate': startDate.toIso8601String().split('T')[0],
      'EndDate': endDate.toIso8601String().split('T')[0],
      'IsActive': isActive,
      'ServiceID': serviceId,
      'Terms': terms,
      'MaxUses': maxUses,
      'CurrentUses': currentUses,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Deal copyWith({
    String? id,
    String? dealName,
    String? description,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? serviceId,
    String? terms,
    int? maxUses,
    int? currentUses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deal(
      id: id ?? this.id,
      dealName: dealName ?? this.dealName,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      serviceId: serviceId ?? this.serviceId,
      terms: terms ?? this.terms,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if deal is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate.add(const Duration(days: 1))) &&
           (maxUses == null || currentUses < maxUses!);
  }

  /// Check if deal has started
  bool get hasStarted {
    return DateTime.now().isAfter(startDate);
  }

  /// Check if deal has expired
  bool get hasExpired {
    return DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
  }

  /// Check if deal has reached maximum uses
  bool get hasReachedMaxUses {
    return maxUses != null && currentUses >= maxUses!;
  }

  /// Get formatted discount percentage
  String get formattedDiscount => '${discountPercentage.toStringAsFixed(0)}%';

  /// Get days remaining in the deal
  int get daysRemaining {
    final now = DateTime.now();
    final endWithTime = endDate.add(const Duration(days: 1));
    if (now.isBefore(endWithTime)) {
      return endWithTime.difference(now).inDays;
    }
    return 0;
  }

  /// Get deal status message
  String get statusMessage {
    if (!isActive) {
      return 'Deal is inactive';
    } else if (!hasStarted) {
      return 'Deal has not started yet';
    } else if (hasExpired) {
      return 'Deal has expired';
    } else if (hasReachedMaxUses) {
      return 'Deal has reached maximum uses';
    } else if (daysRemaining <= 3) {
      return 'Deal expires in $daysRemaining days';
    } else {
      return 'Deal is active';
    }
  }

  /// Calculate discounted price
  double calculateDiscountedPrice(double originalPrice) {
    return originalPrice * (1 - discountPercentage / 100);
  }

  /// Get remaining uses
  int? get remainingUses {
    if (maxUses == null) return null;
    return maxUses! - currentUses;
  }

  @override
  String toString() {
    return 'Deal(id: $id, name: $dealName, discount: $discountPercentage%)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Service category enum
enum ServiceCategory {
  haircut,
  facial,
  waxing,
  nail,
  makeup,
  spa,
  bridal,
  packages,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.haircut:
        return 'Haircut';
      case ServiceCategory.facial:
        return 'Facial';
      case ServiceCategory.waxing:
        return 'Waxing';
      case ServiceCategory.nail:
        return 'Nail Care';
      case ServiceCategory.makeup:
        return 'Makeup';
      case ServiceCategory.spa:
        return 'Spa';
      case ServiceCategory.bridal:
        return 'Bridal';
      case ServiceCategory.packages:
        return 'Packages';
    }
  }

  String get value {
    return name.toLowerCase();
  }
}

/// Deal availability result
class DealAvailability {
  final String dealId;
  final bool isAvailable;
  final String? reason;

  const DealAvailability({
    required this.dealId,
    required this.isAvailable,
    this.reason,
  });

  /// Create DealAvailability from JSON
  factory DealAvailability.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DealAvailability(
      dealId: data['deal_id'] as String,
      isAvailable: data['is_available'] as bool,
      reason: data['reason'] as String?,
    );
  }

  @override
  String toString() {
    return 'DealAvailability(dealId: $dealId, isAvailable: $isAvailable, reason: $reason)';
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  /// Create PaginationMeta from JSON
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }

  /// Check if there's a next page
  bool get hasNextPage => currentPage < lastPage;

  /// Check if there's a previous page
  bool get hasPreviousPage => currentPage > 1;

  /// Get next page number
  int? get nextPage => hasNextPage ? currentPage + 1 : null;

  /// Get previous page number
  int? get previousPage => hasPreviousPage ? currentPage - 1 : null;

  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage/$lastPage, total: $total)';
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;
  final String? message;

  const PaginatedResponse({
    required this.data,
    required this.meta,
    this.message,
  });

  /// Create PaginatedResponse from JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List;
    final items = dataList
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      data: items,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }

  /// Check if response has data
  bool get hasData => data.isNotEmpty;

  /// Get total items count
  int get totalItems => meta.total;

  /// Check if there are more pages
  bool get hasMorePages => meta.hasNextPage;

  @override
  String toString() {
    return 'PaginatedResponse(items: ${data.length}, meta: $meta)';
  }
}