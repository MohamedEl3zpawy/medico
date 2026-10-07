class Booking {
  final String id;
  final String doctorName;
  final String specialty;
  final String rating;
  final String distance;
  final String date;
  final String? displayDate;
  final String time;
  final String visitType;
  final String status;

  Booking({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.date,
    this.displayDate,
    required this.time,
    required this.visitType,
    required this.status,
  });

  String get dateLabel => displayDate ?? date;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? 'Doctor',
      specialty: json['specialty']?.toString() ?? 'Specialty',
      rating: json['rating']?.toString() ?? '0.0',
      distance: json['distance']?.toString() ?? '',
      date: json['date']?.toString() ?? 'Date not available',
      displayDate: json['displayDate']?.toString(),
      time: json['time']?.toString() ?? 'Time not available',
      visitType: json['visitType']?.toString() ?? 'Clinic Visit',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'rating': rating,
      'distance': distance,
      'date': date,
      'displayDate': displayDate,
      'time': time,
      'visitType': visitType,
      'status': status,
    };
  }
}