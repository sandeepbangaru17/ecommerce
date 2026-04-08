class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.category,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String? productName;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String?,
      productImageUrl: json['product_image_url'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final String shippingAddress;
  final String contactPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final int itemCount;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.contactPhone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.itemCount = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: items,
      itemCount: json['item_count'] as int? ?? items.length,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
      case 'shipped':
      case 'delivered':
        return 'Success';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class User {
  final String id;
  final String email;
  final String? fullName;
  final DateTime createdAt;
  final String role;

  User({
    required this.id,
    required this.email,
    this.fullName,
    required this.createdAt,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String? ?? 'user',
    );
  }
}
