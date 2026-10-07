class Pharmacy {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final double distance;
  final bool isOpen;
  final String delivery;

  Pharmacy({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.isOpen,
    required this.delivery,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      reviews: int.tryParse(json['reviews']?.toString() ?? '') ?? 0,
      distance: double.tryParse(json['distance']?.toString() ?? '') ?? 0,
      isOpen: json['isOpen'] == true,
      delivery: json['delivery']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'reviews': reviews,
      'distance': distance,
      'isOpen': isOpen,
      'delivery': delivery,
    };
  }
}