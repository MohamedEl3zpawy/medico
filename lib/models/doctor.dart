class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String image;
  final double price;
  final double rating;
  final int reviews;
  final double distance;
  final bool isFavorite;
  final double latitude;
  final double longitude;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.isFavorite,
        this.latitude = 0,
    this.longitude = 0,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      reviews: int.tryParse(json['reviews']?.toString() ?? '') ?? 0,
      distance: double.tryParse(json['distance']?.toString() ?? '') ?? 0,
      isFavorite: json['isFavorite'] == true,
            latitude:
          double.tryParse(json['latitude']?.toString() ?? '') ?? 0,
      longitude:
          double.tryParse(json['longitude']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'location': location,
      'image': image,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'distance': distance,
      'isFavorite': isFavorite,
    };
  }

  Doctor copyWith({bool? isFavorite}) {
    return Doctor(
      id: id,
      name: name,
      specialty: specialty,
      location: location,
      image: image,
      price: price,
      rating: rating,
      reviews: reviews,
      distance: distance,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}