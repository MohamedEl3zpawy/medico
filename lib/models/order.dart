class MedOrder {
  final String id;
  final String medicineName;
  final String price;
  final String category;
  final String status;
  final String? image;
  final String quantity;
  final String createdAt;
  final String type;

  MedOrder({
    required this.id,
    required this.medicineName,
    required this.price,
    required this.category,
    required this.status,
    this.image,
    required this.quantity,
    required this.createdAt,
    required this.type,
  });

  factory MedOrder.fromJson(Map<String, dynamic> json) {
    return MedOrder(
      id: json['id']?.toString() ?? '',
      medicineName: json['medicineName']?.toString() ??
          json['name']?.toString() ??
          'Medicine',
      price: json['price']?.toString() ?? '0',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Ordered',
      image: json['image']?.toString(),
      quantity: json['quantity']?.toString() ?? '1',
      createdAt: json['createdAt']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Medicine',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'price': price,
      'category': category,
      'status': status,
      'image': image,
      'quantity': quantity,
      'createdAt': createdAt,
      'type': type,
    };
  }
}