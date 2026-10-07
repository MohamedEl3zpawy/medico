class Offer {
  final String id;
  final String name;
  final String description;
  final String price;
  final String oldPrice;
  final String discount;
  final String? image;

  Offer({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.discount,
    this.image,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Offer',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      oldPrice: json['oldPrice']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'discount': discount,
      'image': image,
    };
  }
}