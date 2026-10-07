import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import '../widgets/app_bottom_nav.dart';

class FavouriteDoctorsPage extends StatefulWidget {
  const FavouriteDoctorsPage({super.key});

  @override
  State<FavouriteDoctorsPage> createState() => _FavouriteDoctorsPageState();
}

class _FavouriteDoctorsPageState extends State<FavouriteDoctorsPage> {
  List<Doctor> doctors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    try {
      final data = await DoctorService.getDoctors();

      setState(() {
        doctors = data
            .where((doctor) => doctor.isFavorite == true)
            .toList();

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      debugPrint('Error loading doctors: $e');
    }
  }

  Future<void> removeFavorite(int index) async {
    final doctor = doctors[index];

    try {
      await DoctorService.updateFavorite(
        doctor.id,
        false,
      );

      if (!mounted) return;

      setState(() {
        doctors.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favourites'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('Error removing favorite: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favourite'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.favorites,
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Title
            Container(
              height: 54,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF173B63),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Favourite Doctors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Doctors
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : doctors.isEmpty
                      ? const Center(
                          child: Text(
                            'No Favourite Doctors',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          itemCount: doctors.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, index) {
                            return DoctorCard(
                              doctor: doctors[index],
                              onFavoritePressed: () {
                                removeFavorite(index);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onFavoritePressed;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8F7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor letter
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1B426B),
            child: Text(
              doctor.name.isNotEmpty ? doctor.name[0] : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Doctor information
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '⭐ ${doctor.rating} • ${doctor.reviews} Reviews',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFFFA000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Favorite button
          IconButton(
            onPressed: onFavoritePressed,
            icon: const Icon(
              Icons.favorite,
              color: Color(0xFF1D4D76),
            ),
          ),
        ],
      ),
    );
  }
}