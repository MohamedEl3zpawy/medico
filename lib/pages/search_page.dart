import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../services/location_service.dart';

enum SortOption { none, nearest, topRated, cheapest }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color navy = Color(0xFF123F6D);
  static const Color blue = Color(0xFF286DD8);

  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  bool isLoading = true;

  String searchText = '';
  String selectedSpecialty = 'All';
  double? selectedRating;
  double? selectedPrice;
  double? selectedDistance;
  SortOption sortOption = SortOption.none;

  // ==============================
  // LOCATION
  // ==============================

  double? userLat;
  double? userLng;
  bool locationDenied = false;
  bool locationLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  // ==============================
  // FETCH DOCTORS
  // ==============================

  Future<void> fetchDoctors() async {
    try {
      final data = await DoctorService.getDoctors();

      if (!mounted) return;

      setState(() {
        doctors = data;
        filteredDoctors = data;
        isLoading = false;
      });

      loadUserLocation();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==============================
  // LOCATION
  // ==============================

  Future<void> loadUserLocation() async {
    setState(() {
      locationLoading = true;
    });

    final position = await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        locationDenied = true;
        locationLoading = false;
      });
      return;
    }

    setState(() {
      userLat = position.latitude;
      userLng = position.longitude;
      locationDenied = false;
      locationLoading = false;
    });

    applyFilters();
  }

  /// Real distance if we have the user's location and the doctor
  /// has coordinates set. Falls back to the mock API distance
  /// otherwise, so the app still works without permission.
  double distanceForDoctor(Doctor doctor) {
    if (userLat != null &&
        userLng != null &&
        doctor.latitude != 0 &&
        doctor.longitude != 0) {
      return LocationService.distanceInKm(
        fromLat: userLat!,
        fromLng: userLng!,
        toLat: doctor.latitude,
        toLng: doctor.longitude,
      );
    }

    return doctor.distance;
  }

  // ==============================
  // FILTER + SORT
  // ==============================

  void applyFilters() {
    final query = searchText.toLowerCase();

    List<Doctor> result = doctors.where((doctor) {
      final name = doctor.name.toLowerCase();
      final specialty = doctor.specialty.toLowerCase();
      final distance = distanceForDoctor(doctor);

      final searchMatch =
          query.isEmpty ||
          name.contains(query) ||
          specialty.contains(query);

      final specialtyMatch =
          selectedSpecialty == 'All' ||
          specialty == selectedSpecialty.toLowerCase();

      final ratingMatch =
          selectedRating == null || doctor.rating >= selectedRating!;

      final priceMatch =
          selectedPrice == null || doctor.price <= selectedPrice!;

      final distanceMatch =
          selectedDistance == null || distance <= selectedDistance!;

      return searchMatch &&
          specialtyMatch &&
          ratingMatch &&
          priceMatch &&
          distanceMatch;
    }).toList();

    switch (sortOption) {
      case SortOption.nearest:
        result.sort(
          (a, b) => distanceForDoctor(a).compareTo(
            distanceForDoctor(b),
          ),
        );
        break;
      case SortOption.topRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.cheapest:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.none:
        break;
    }

    setState(() {
      filteredDoctors = result;
    });
  }

  String sortLabel() {
    switch (sortOption) {
      case SortOption.nearest:
        return 'Nearest';
      case SortOption.topRated:
        return 'Top Rated';
      case SortOption.cheapest:
        return 'Cheapest';
      case SortOption.none:
        return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // =========================
              // Header
              // =========================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 28,
                ),
                decoration: const BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: const Text(
                  'Find Your Doctor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // Location banner
              // =========================
              if (locationDenied)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_off_outlined,
                        color: Color(0xFFB26A00),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Enable location to see real distances to doctors near you.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A5200),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: loadUserLocation,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (locationLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Finding your location...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 15),

              // =========================
              // Search Box
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: TextField(
                  onChanged: (value) {
                    searchText = value;
                    applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search doctor or specialty',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // Filters
              // =========================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final specialties = doctors
                            .map((doctor) => doctor.specialty)
                            .where((s) => s.isNotEmpty)
                            .toSet()
                            .toList();

                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: const Text(
                                    'All Specialties',
                                  ),
                                  onTap: () {
                                    selectedSpecialty = 'All';
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ...specialties.map((specialty) {
                                  return ListTile(
                                    title: Text(specialty),
                                    onTap: () {
                                      selectedSpecialty = specialty;
                                      applyFilters();
                                      Navigator.pop(context);
                                    },
                                  );
                                }),
                              ],
                            );
                          },
                        );
                      },
                      child: filterButton(
                        selectedSpecialty == 'All'
                            ? 'Specialty'
                            : selectedSpecialty,
                        selectedSpecialty != 'All',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: const Text(
                                    'All Distances',
                                  ),
                                  onTap: () {
                                    selectedDistance = null;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '1 KM or less',
                                  ),
                                  onTap: () {
                                    selectedDistance = 1;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '2 KM or less',
                                  ),
                                  onTap: () {
                                    selectedDistance = 2;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '5 KM or less',
                                  ),
                                  onTap: () {
                                    selectedDistance = 5;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: filterButton(
                        selectedDistance == null
                            ? 'Distance'
                            : '${selectedDistance!.toInt()} KM or less',
                        selectedDistance != null,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: const Text(
                                    'All Ratings',
                                  ),
                                  onTap: () {
                                    selectedRating = null;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '4.5 ⭐ and above',
                                  ),
                                  onTap: () {
                                    selectedRating = 4.5;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '4.0 ⭐ and above',
                                  ),
                                  onTap: () {
                                    selectedRating = 4.0;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '3.5 ⭐ and above',
                                  ),
                                  onTap: () {
                                    selectedRating = 3.5;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: filterButton(
                        selectedRating == null
                            ? 'Rating'
                            : '${selectedRating!.toStringAsFixed(1)}+ ⭐',
                        selectedRating != null,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: const Text(
                                    'All Prices',
                                  ),
                                  onTap: () {
                                    selectedPrice = null;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '250 EGP or less',
                                  ),
                                  onTap: () {
                                    selectedPrice = 250;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '300 EGP or less',
                                  ),
                                  onTap: () {
                                    selectedPrice = 300;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text(
                                    '500 EGP or less',
                                  ),
                                  onTap: () {
                                    selectedPrice = 500;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: filterButton(
                        selectedPrice == null
                            ? 'Price'
                            : '${selectedPrice!.toInt()} EGP or less',
                        selectedPrice != null,
                      ),
                    ),

                    // =========================
                    // SORT (advanced option)
                    // =========================
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.sort,
                                  ),
                                  title: const Text('Default'),
                                  onTap: () {
                                    sortOption = SortOption.none;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.near_me_outlined,
                                  ),
                                  title: const Text(
                                    'Nearest to me',
                                  ),
                                  onTap: () {
                                    sortOption =
                                        SortOption.nearest;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.star_outline,
                                  ),
                                  title: const Text(
                                    'Highest rated',
                                  ),
                                  onTap: () {
                                    sortOption =
                                        SortOption.topRated;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.attach_money,
                                  ),
                                  title: const Text(
                                    'Cheapest first',
                                  ),
                                  onTap: () {
                                    sortOption =
                                        SortOption.cheapest;
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: filterButton(
                        sortLabel(),
                        sortOption != SortOption.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // Nearby Doctors
              // =========================
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    userLat != null
                        ? 'Doctors Near You'
                        : 'Doctors',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (filteredDoctors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No doctors match your filters',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...filteredDoctors.map((doctor) {
                  final distance = distanceForDoctor(doctor);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: doctorCard(
                      name: doctor.name,
                      specialty: doctor.specialty,
                      price: '${doctor.price.toStringAsFixed(0)} EGP',
                      distance: '${distance.toStringAsFixed(1)} KM',
                      rating: doctor.rating.toStringAsFixed(1),
                    ),
                  );
                }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Filter Button
  // =========================
  Widget filterButton(
    String text,
    bool selected,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: selected ? blue : const Color(0xFFE0E4EA),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF7B9CC0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF123F6D),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================
  // Doctor Card
  // =========================
  Widget doctorCard({
    required String name,
    required String specialty,
    required String price,
    required String distance,
    required String rating,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      height: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 135,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person,
              size: 65,
              color: navy,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  specialty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 17,
                    ),
                    Text(
                      distance,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorProfilePage(
                              name: name,
                              specialty: specialty,
                              price: price,
                              distance: distance,
                              rating: rating,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: navy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorProfilePage extends StatelessWidget {
  final String name;
  final String specialty;
  final String price;
  final String distance;
  final String rating;

  const DoctorProfilePage({
    super.key,
    required this.name,
    required this.specialty,
    required this.price,
    required this.distance,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123F6D),
        foregroundColor: Colors.white,
        title: const Text('Doctor Profile'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.person,
              size: 100,
              color: Color(0xFF123F6D),
            ),

            const SizedBox(height: 25),

            Text(
              name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123F6D),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              specialty,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Text('Price: $price'),
            Text('Distance: $distance'),
            Text('Rating: ⭐ $rating'),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
               onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingPage(
        doctorName: name,
      ),
    ),
  );
},
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class BookingPage extends StatefulWidget {
  final String doctorName;

  const BookingPage({
    super.key,
    required this.doctorName,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123F6D),
        foregroundColor: Colors.white,
        title: const Text('Book Appointment'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Text(
              'Doctor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.doctorName,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123F6D),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectDate,
                child: Text(
                  selectedDate == null
                      ? 'Choose Date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectTime,
                child: Text(
                  selectedTime == null
                      ? 'Choose Time'
                      : selectedTime!.format(context),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
  if (selectedDate == null ||
      selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please select date and time',
        ),
      ),
    );
    return;
  }

  Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => MyAppointmentsPage(
      appointments: [
        {
          'doctor': widget.doctorName,
          'date':
              '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          'time': selectedTime!.format(context),
        },
      ],
    ),
  ),
);
},
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
class MyAppointmentsPage extends StatelessWidget {
  final List<Map<String, String>> appointments;

  const MyAppointmentsPage({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123F6D),
        foregroundColor: Colors.white,
        title: const Text('My Appointments'),
      ),

      body: appointments.isEmpty
          ? const Center(
              child: Text(
                'No appointments yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF123F6D),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['doctor'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Date: ${appointment['date'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Time: ${appointment['time'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}