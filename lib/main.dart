import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'pages/medicine_page.dart';
import 'pages/favourite_doctors_page.dart';

import 'services/doctor_service.dart';
import 'pages/doctor_reviews_page.dart';
import 'pages/profile_page.dart';
import 'pages/bookings.dart';
import 'constants/app_constants.dart';
import 'widgets/doctor_image.dart';
import 'auth/splash_page.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'pages/search_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const Medico(),
    ),
  );
}

// ============================================================
// OPEN DOCTOR REVIEWS
// ============================================================

Future<void> openDoctorReviews(
  BuildContext context,
  dynamic doctor,
) async {
  try {
    String? doctorId = doctor['id']?.toString();

    if (doctorId == null ||
        doctorId == 'null' ||
        doctorId.isEmpty) {
      final allDoctors = await DoctorService.getDoctors();

      final doctorName = doctor['name']?.toString();

      for (final item in allDoctors) {
        if (item.name == doctorName) {
          doctorId = item.id;
          doctor['id'] = doctorId;
          break;
        }
      }
    }

    if (doctorId == null ||
        doctorId == 'null' ||
        doctorId.isEmpty) {
      throw Exception('Doctor ID not found');
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorReviewsPage(
          doctorId: doctorId!,
          doctorName: doctor['name']?.toString() ?? '',
          doctorSpecialty: doctor['specialty']?.toString() ?? '',
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error opening doctor reviews: $e');

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open doctor profile'),
      ),
    );
  }
}

// ============================================================
// MEDICO APP
// ============================================================

class Medico extends StatelessWidget {
  const Medico({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medico',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    final userEmail = email.text.trim();
    final userPassword = password.text;

    if (userEmail.isEmpty || userPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(usersApi),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load users');
      }

      final data = jsonDecode(response.body) as List;

      dynamic user;

      for (final item in data) {
        final itemEmail =
            item['email']?.toString().toLowerCase() ?? '';

        final itemPassword =
            item['password']?.toString() ?? '';

        if (itemEmail == userEmail.toLowerCase() &&
            itemPassword == userPassword) {
          user = item;
          break;
        }
      }

      if (user == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );
        return;
      }

      context.read<UserProvider>().setUser(
            name: user['name']?.toString() ?? 'User',
            userId: user['id']?.toString() ?? '',
          );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Login error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: 145,
                ),

                const SizedBox(height: 18),

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to continue your healthcare journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: navy,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: password,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: navy,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: navy,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SignUpPage(),
                                ),
                              );
                            },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SIGN UP PAGE
// ============================================================

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> signUp() async {
    final userName = name.text.trim();
    final userEmail = email.text.trim();
    final userPassword = password.text;
    final confirm = confirmPassword.text;

    if (userName.isEmpty ||
        userEmail.isEmpty ||
        userPassword.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(userEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid email address',
          ),
        ),
      );
      return;
    }

    if (userPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters',
          ),
        ),
      );
      return;
    }

    if (userPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final existingResponse = await http.get(
        Uri.parse(usersApi),
      );

      if (existingResponse.statusCode == 200) {
        final data =
            jsonDecode(existingResponse.body) as List;

        final exists = data.any(
          (item) =>
              item['email']
                  ?.toString()
                  .toLowerCase() ==
              userEmail.toLowerCase(),
        );

        if (exists) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already exists'),
            ),
          );
          return;
        }
      }

      final response = await http.post(
        Uri.parse(usersApi),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': userName,
          'email': userEmail,
          'password': userPassword,
        }),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception('Failed to create account');
      }

      final createdUser = jsonDecode(response.body);

      context.read<UserProvider>().setUser(
            name: userName,
            userId: createdUser['id']?.toString() ?? '',
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Sign up error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to create account. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: 135,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Create your Medico account',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: navy,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: navy,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: password,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: navy,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: navy,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: confirmPassword,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(
                      Icons.lock_reset_outlined,
                      color: navy,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                              !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: navy,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final search = TextEditingController();

  List doctors = [];

  bool loadingDoctors = true;
  bool searchFocused = false;

  @override
  void initState() {
    super.initState();
    getDoctors();
  }

  Future<void> getDoctors() async {
    try {
      final response = await http.get(
        Uri.parse(doctorsApi),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          doctors = data;
          loadingDoctors = false;
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      debugPrint('Error loading doctors: $e');

      if (!mounted) return;

      setState(() {
        loadingDoctors = false;
      });
    }
  }

  bool isMedicine(String value) {
    return value.contains('medicine') ||
        value.contains('medicines');
  }

  bool isReports(String value) {
    return value.contains('report') ||
        value.contains('reports');
  }

  bool isSpecialty(String value) {
    return value.contains('specialty') ||
        value.contains('speciality');
  }

  bool isDoctor(String value) {
    return value.contains('doctor') ||
        value.contains('doctors');
  }

  void openMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicinePage(),
      ),
    );
  }

  void openReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalReportsPage(),
      ),
    );
  }

  void openSpecialty() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  void openBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingsPage(),
      ),
    );
  }

  void openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const FavouriteDoctorsPage(),
      ),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userId: context.read<UserProvider>().userId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = search.text.trim().toLowerCase();
    final searching = value.isNotEmpty;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            25,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: .06,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: navy,
                      size: 29,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${context.watch<UserProvider>().name.isEmpty ? 'User' : context.watch<UserProvider>().name} 👋',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff24458d),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: openNotifications,
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: navy,
                      size: 29,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SEARCH
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: .05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: search,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Search doctors or specialties',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: navy,
                    ),
                    suffixIcon: value.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              search.clear();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (!searching)
                buildNormalHome()
              else
                buildSearchResults(value),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(),
    );
  }

  // ==========================================================
  // NORMAL HOME
  // ==========================================================

  Widget buildNormalHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BANNER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff2f62e8),
                Color(0xff24458d),
              ],
            ),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Medical Help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Find the right doctor\nfor your needs.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: openSpecialty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor: navy,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Find a Doctor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 70,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            category(
              'category_specialty.svg',
              'Speciality',
              openSpecialty,
            ),
            category(
              'category_medicine.svg',
              'Medicine',
              openMedicine,
            ),
            category(
              'category_reports.svg',
              'Reports',
              openReports,
            ),
            category(
              'category_doctor.svg',
              'Doctor',
              openSpecialty,
            ),
          ],
        ),

        const SizedBox(height: 28),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearest Doctors',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: openSpecialty,
              child: const Text(
                'View all',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        if (loadingDoctors)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: CircularProgressIndicator(),
            ),
          )
        else if (doctors.isEmpty)
          emptyDoctors()
        else
          ...doctors
              .take(3)
              .map(
                (doctor) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
                  child: doctorCard(doctor),
                ),
              ),
      ],
    );
  }

  // ==========================================================
  // SEARCH RESULTS
  // ==========================================================

  Widget buildSearchResults(String value) {
    if (isMedicine(value)) {
      return searchCategoryResult(
        'category_medicine.svg',
        'Medicine',
        'Open Medicine',
        openMedicine,
      );
    }

    if (isReports(value)) {
      return searchCategoryResult(
        'category_reports.svg',
        'Reports',
        'Open Reports',
        openReports,
      );
    }

    if (isSpecialty(value)) {
      return searchCategoryResult(
        'category_specialty.svg',
        'Speciality',
        'View Specialities',
        openSpecialty,
      );
    }

    return doctorSearchResults(
      searchText: value,
    );
  }

  Widget doctorSearchResults({
    String? searchText,
  }) {
    final text =
        searchText?.toLowerCase() ?? '';

    final filtered = doctors.where(
      (doctor) {
        final name =
            (doctor['name'] ?? '')
                .toString()
                .toLowerCase();

        final specialty =
            (doctor['specialty'] ?? '')
                .toString()
                .toLowerCase();

        return name.contains(text) ||
            specialty.contains(text);
      },
    ).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 55,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No doctors found',
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Try another doctor name or specialty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          '${filtered.length} doctor${filtered.length == 1 ? '' : 's'} found',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        ...filtered.map(
          (doctor) => Padding(
            padding:
                const EdgeInsets.only(bottom: 12),
            child: doctorCard(doctor),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SEARCH CATEGORY CARD
  // ==========================================================

  Widget searchCategoryResult(
    String image,
    String title,
    String buttonText,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/$image',
            width: 75,
            height: 75,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Find everything you need here.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CATEGORY
  // ==========================================================

  Widget category(
    String image,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: .05,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/$image',
                  width: 34,
                  height: 34,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DOCTOR CARD
  // ==========================================================

  Widget doctorCard(dynamic doctor) {
    final bool isFavorite =
        doctor['isFavorite'] == true;

    final rating =
        doctor['rating']?.toString() ?? '0.0';

    final reviews =
        doctor['reviews']?.toString() ?? '0';

    return GestureDetector(
      onTap: () {
        openDoctorReviews(
          context,
          doctor,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: navy,
          borderRadius:
              BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(
                alpha: .15,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Center(
                child: buildDoctorImage(
                  doctor,
                  radius: 31,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name']
                            ?.toString() ??
                        '',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    doctor['specialty']
                            ?.toString() ??
                        '',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($reviews reviews)',
                        style:
                            const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () async {
                await toggleFavorite(
                  doctor,
                  isFavorite,
                );
              },
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? Colors.redAccent
                    : Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FAVORITE
  // ==========================================================

  Future<void> toggleFavorite(
    dynamic doctor,
    bool currentValue,
  ) async {
    final newValue = !currentValue;

    try {
      String? id =
          doctor['id']?.toString();

      if (id == null ||
          id == 'null' ||
          id.isEmpty) {
        final allDoctors =
            await DoctorService.getDoctors();

        for (final item in allDoctors) {
          if (item.name ==
              doctor['name']?.toString()) {
            id = item.id;
            doctor['id'] = id;
            break;
          }
        }
      }

      if (id == null ||
          id == 'null' ||
          id.isEmpty) {
        throw Exception(
          'Doctor ID not found',
        );
      }

      await DoctorService.updateFavorite(
        id,
        newValue,
      );

      if (!mounted) return;

      setState(() {
        doctor['isFavorite'] = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Added to favourites ❤️'
                : 'Removed from favourites',
          ),
          duration:
              const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint(
        'Error updating favourite: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update favourite',
          ),
          duration:
              Duration(seconds: 2),
        ),
      );
    }
  }

  // ==========================================================
  // EMPTY DOCTORS
  // ==========================================================

  Widget emptyDoctors() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 45,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            'No doctors available',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  void openNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Icon(
                  Icons.notifications_active_outlined,
                  color: navy,
                  size: 45,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'You are all caught up!',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      height: 58,
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .06,
            ),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          navItem(
            Icons.home_rounded,
            'Home',
            () {},
            active: true,
          ),

          navItem(
            Icons.calendar_month_outlined,
            'Booking',
            openBookings,
          ),

          navItem(
            Icons.favorite_border_rounded,
            'Favorite',
            openFavorites,
          ),

          navItem(
            Icons.person_outline_rounded,
            'Profile',
            openProfile,
          ),
        ],
      ),
    );
  }

  Widget navItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 58,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: active
                  ? navy
                  : Colors.black87,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    active
                        ? FontWeight.bold
                        : FontWeight.w500,
                color: active
                    ? navy
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SPECIALTY PAGE
// ============================================================

class SpecialtyPage extends StatefulWidget {
  const SpecialtyPage({
    super.key,
  });

  @override
  State<SpecialtyPage> createState() =>
      _SpecialtyPageState();
}

class _SpecialtyPageState
    extends State<SpecialtyPage> {
  List doctors = [];
  List filteredDoctors = [];

  final TextEditingController search =
      TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();

    getDoctors();

    search.addListener(
      filterDoctors,
    );
  }

  Future<void> getDoctors() async {
    try {
      final response = await http.get(
        Uri.parse(doctorsApi),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load doctors',
        );
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        doctors = data;
        filteredDoctors = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading doctors: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void filterDoctors() {
    final text =
        search.text.trim().toLowerCase();

    final result = doctors.where(
      (doctor) {
        final name =
            (doctor['name'] ?? '')
                .toString()
                .toLowerCase();

        final specialty =
            (doctor['specialty'] ?? '')
                .toString()
                .toLowerCase();

        return name.contains(text) ||
            specialty.contains(text);
      },
    ).toList();

    if (!mounted) return;

    setState(() {
      filteredDoctors = result;
    });
  }

  Future<void> toggleFavorite(
    dynamic doctor,
  ) async {
    final currentValue =
        doctor['isFavorite'] == true;

    final newValue = !currentValue;

    try {
      String? id =
          doctor['id']?.toString();

      if (id == null ||
          id == 'null' ||
          id.isEmpty) {
        final allDoctors =
            await DoctorService.getDoctors();

        for (final item in allDoctors) {
          if (item.name ==
              doctor['name']?.toString()) {
            id = item.id;
            doctor['id'] = id;
            break;
          }
        }
      }

      if (id == null ||
          id == 'null' ||
          id.isEmpty) {
        throw Exception(
          'Doctor ID not found',
        );
      }

      await DoctorService.updateFavorite(
        id,
        newValue,
      );

      if (!mounted) return;

      setState(() {
        doctor['isFavorite'] = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Added to favourites ❤️'
                : 'Removed from favourites',
          ),
          duration:
              const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint(
        'Error updating favourite: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update favourite',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: navy,
          ),
        ),
        title: const Text(
          'Find a Doctor',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              15,
            ),
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText:
                    'Search by doctor or specialty',
                prefixIcon: const Icon(
                  Icons.search,
                  color: navy,
                ),
                suffixIcon: search.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          search.clear();
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : filteredDoctors.isEmpty
                    ? const Center(
                        child: Text(
                          'No doctors found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        itemCount:
                            filteredDoctors.length,
                        itemBuilder:
                            (context, index) {
                          return specialtyDoctorCard(
                            filteredDoctors[index],
                          );
                        },
                      ),
          ),
        ],
      ),

      bottomNavigationBar:
          buildSpecialtyBottomNavigation(),
    );
  }

  Widget specialtyDoctorCard(
    dynamic doctor,
  ) {
    final isFavorite =
        doctor['isFavorite'] == true;

    final rating =
        doctor['rating']?.toString() ?? '0.0';

    final reviews =
        doctor['reviews']?.toString() ?? '0';

    return GestureDetector(
      onTap: () {
        openDoctorReviews(
          context,
          doctor,
        );
      },
      child: Container(
        height: 110,
        margin:
            const EdgeInsets.only(bottom: 14),
        padding:
            const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: navy,
          borderRadius:
              BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Center(
                child: buildDoctorImage(
                  doctor,
                  radius: 30,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name']
                            ?.toString() ??
                        '',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    doctor['specialty']
                            ?.toString() ??
                        '',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 17,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '($reviews)',
                        style:
                            const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {
                toggleFavorite(
                  doctor,
                );
              },
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? Colors.redAccent
                    : Colors.white,
                size: 27,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSpecialtyBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      height: 58,
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          specialtyNavItem(
            Icons.home_outlined,
            'Home',
            () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const HomePage(),
                ),
                (route) => false,
              );
            },
          ),

          specialtyNavItem(
            Icons.calendar_month_outlined,
            'Booking',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingsPage(),
                ),
              );
            },
          ),

          specialtyNavItem(
            Icons.favorite_border,
            'Favorite',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FavouriteDoctorsPage(),
                ),
              );
            },
          ),

          specialtyNavItem(
            Icons.person_outline,
            'Profile',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(
                    userId: context.read<UserProvider>().userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget specialtyNavItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 58,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: Colors.black87,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MEDICAL REPORTS PLACEHOLDER
// ============================================================

class MedicalReportsPage extends StatelessWidget {
  MedicalReportsPage({super.key});

  final List<Map<String, String>> reports = [
    {
      'title': 'Blood Test',
      'date': 'Recently added',
      'icon': 'blood',
    },
    {
      'title': 'Medical Checkup',
      'date': 'No recent report',
      'icon': 'check',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: navy,
          ),
        ),
        title: const Text(
          'Medical Reports',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: navy,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 45,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Medical Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Keep track of your medical reports.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 14),

            ...reports.map(
              (report) => Container(
                margin:
                    const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: navy,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['title']!,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report['date']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: navy,
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
}