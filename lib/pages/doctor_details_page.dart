import 'package:flutter/material.dart';

import '../services/doctor_service.dart';
import '../widgets/doctor_image.dart';
import 'doctor_reviews_page.dart';

class DoctorDetailsPage extends StatefulWidget {
  final dynamic doctor;

  const DoctorDetailsPage({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();

    isFavorite = widget.doctor['isFavorite'] == true;
  }

  String get doctorName {
    return widget.doctor['name']?.toString() ?? 'Doctor';
  }

  String get specialty {
    return widget.doctor['specialty']?.toString() ?? 'Specialist';
  }

  String get location {
    return widget.doctor['location']?.toString() ?? 'Cairo, Egypt';
  }

  double get rating {
    final value = double.tryParse(
          widget.doctor['rating']?.toString() ?? '',
        ) ??
        0.0;

    return value;
  }

  int get reviews {
    return int.tryParse(
          widget.doctor['reviews']?.toString() ?? '',
        ) ??
        0;
  }

  String get doctorId {
    return widget.doctor['id']?.toString() ?? '';
  }

  String get doctorImageUrl {
    final image = widget.doctor['image']?.toString() ?? '';

    if (image.startsWith('http')) {
      return image;
    }

    return '';
  }

  Future<void> toggleFavorite() async {
    if (doctorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor ID is missing'),
        ),
      );
      return;
    }

    final newValue = !isFavorite;

    setState(() {
      isFavorite = newValue;
    });

    try {
      await DoctorService.updateFavorite(
        doctorId,
        newValue,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Added to favourites ❤️'
                : 'Removed from favourites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isFavorite = !newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update favourite',
          ),
        ),
      );
    }
  }

  void openReviews() {
    if (doctorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor ID is missing'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorReviewsPage(
          doctorId: doctorId,
          doctorName: doctorName,
          doctorSpecialty: specialty,
        ),
      ),
    );
  }

  void bookAppointment() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            15,
            22,
            25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF142B4A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you would like to continue with $doctorName.',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              _bookingOption(
                icon: Icons.calendar_today_outlined,
                title: 'Choose Date & Time',
                subtitle: 'Select an available appointment',
                onTap: () {
                  Navigator.pop(context);
                  showBookingMessage();
                },
              ),
              const SizedBox(height: 12),
              _bookingOption(
                icon: Icons.video_call_outlined,
                title: 'Online Consultation',
                subtitle: 'Consult the doctor online',
                onTap: () {
                  Navigator.pop(context);
                  showBookingMessage();
                },
              ),
              const SizedBox(height: 12),
              _bookingOption(
                icon: Icons.location_on_outlined,
                title: 'Clinic Visit',
                subtitle: 'Visit the doctor at the clinic',
                onTap: () {
                  Navigator.pop(context);
                  showBookingMessage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showBookingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Booking flow will be connected next.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _bookingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2ECF5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFDDEEFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2879C8),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142B4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF7890A5),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDoctorPhoto() {
    if (doctorImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          doctorImageUrl,
          width: 150,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return buildFallbackDoctorPhoto();
          },
        ),
      );
    }

    final assetDoctor = doctorAsset(widget.doctor);

    if (assetDoctor != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 150,
          height: 190,
          color: const Color(0xFFEAF4FC),
          child: Image.asset(
            'assets/$assetDoctor',
            fit: BoxFit.contain,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return buildFallbackDoctorPhoto();
            },
          ),
        ),
      );
    }

    return buildFallbackDoctorPhoto();
  }

  Widget buildFallbackDoctorPhoto() {
    return Container(
      width: 150,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FC),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(
        Icons.person,
        size: 90,
        color: const Color(0xFF2D6FA8),
      ),
    );
  }

  Widget buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          final filled = index < rating.round();

          return Icon(
            filled
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFFFB52E),
            size: 20,
          );
        },
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5EDF4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4FC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2879C8),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142B4A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                5,
              ),
              child: Row(
                children: [
                  _topButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Doctor Details',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF142B4A),
                        ),
                      ),
                    ),
                  ),
                  _topButton(
                    icon: isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite
                        ? const Color(0xFFE74C68)
                        : const Color(0xFF142B4A),
                    onTap: toggleFavorite,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  30,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Doctor photo
                    buildDoctorPhoto(),

                    const SizedBox(height: 18),

                    // Name
                    Text(
                      doctorName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF142B4A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Specialty
                    Text(
                      specialty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF668197),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Rating
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        buildStars(),
                        const SizedBox(width: 8),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF142B4A),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '($reviews reviews)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Quick stats
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.star_rounded,
                            rating.toStringAsFixed(1),
                            'Rating',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            Icons.rate_review_outlined,
                            reviews.toString(),
                            'Reviews',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            Icons.verified_outlined,
                            '4+',
                            'Years Exp.',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // About
                    _sectionTitle(
                      'About Doctor',
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFFE5EDF4),
                        ),
                      ),
                      child: Text(
                        'Dr. $doctorName is a professional $specialty '
                        'specialist. Patients can book an appointment, '
                        'check reviews and find the clinic location '
                        'directly through Medico.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF65798B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Information
                    _sectionTitle(
                      'Clinic Information',
                    ),

                    const SizedBox(height: 10),

                    buildInfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      value: location,
                    ),

                    const SizedBox(height: 10),

                    buildInfoCard(
                      icon: Icons.access_time_outlined,
                      title: 'Working Hours',
                      value: '10:00 AM - 08:00 PM',
                    ),

                    const SizedBox(height: 10),

                    buildInfoCard(
                      icon: Icons.medical_services_outlined,
                      title: 'Consultation',
                      value: 'Available by appointment',
                    ),

                    const SizedBox(height: 25),

                    // Reviews button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: openReviews,
                        icon: const Icon(
                          Icons.rate_review_outlined,
                        ),
                        label: const Text(
                          'View Patient Reviews',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF2879C8),
                          side: const BorderSide(
                            color: Color(0xFF2879C8),
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Booking button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: bookAppointment,
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                        ),
                        label: const Text(
                          'Book Appointment',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2879C8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF142B4A),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5EDF4),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5EDF4),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFB52E),
            size: 21,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF142B4A),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF142B4A),
        ),
      ),
    );
  }
}