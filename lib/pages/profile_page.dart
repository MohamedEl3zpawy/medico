import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'favourite_doctors_page.dart';
import '../widgets/app_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String usersApi =
      'https://6a933c1825936d5660f0a59d.mockapi.io/users';

  Map<String, dynamic> user = {};

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  // =========================
  // GET USER DATA
  // =========================

  Future<void> fetchUser() async {
    try {
      if (widget.userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      final response = await http.get(
        Uri.parse('$usersApi/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          user = Map<String, dynamic>.from(data);

          nameController.text =
              user['name']?.toString() ?? '';

          emailController.text =
              user['email']?.toString() ?? '';

          phoneController.text =
              user['phone']?.toString() ?? '';

          isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load user: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load profile data',
          ),
        ),
      );
    }
  }

  // =========================
  // EDIT PROFILE
  // =========================

  Future<void> saveProfile() async {
    final newName = nameController.text.trim();
    final newEmail = emailController.text.trim();
    final newPhone = phoneController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Name and email cannot be empty',
          ),
        ),
      );
      return;
    }

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid email address',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response = await http.put(
        Uri.parse('$usersApi/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': newName,
          'email': newEmail,
          'phone': newPhone,
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser =
            jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          user =
              Map<String, dynamic>.from(updatedUser);
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated successfully',
            ),
          ),
        );
      } else {
        throw Exception(
          'Failed to update profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Profile update error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update profile',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // =========================
  // EDIT PROFILE DIALOG
  // =========================

  void showEditProfile() {
    nameController.text =
        user['name']?.toString() ?? '';

    emailController.text =
        user['email']?.toString() ?? '';

    phoneController.text =
        user['phone']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Color(0xFF142B4A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textInputAction:
                      TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: phoneController,
                  keyboardType:
                      TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                    },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);
                      await saveProfile();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF3689D8),
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                    ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // NAVIGATION
  // =========================

  void openHome() {
    Navigator.pop(context);
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

  // =========================
  // BUILD
  //========================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final String userName =
        user['name']?.toString().trim().isNotEmpty ==
                true
            ? user['name'].toString()
            : 'User';

    final String email =
        user['email']?.toString().trim().isNotEmpty ==
                true
            ? user['email'].toString()
            : 'No Email';

    final String phone =
        user['phone']?.toString().trim().isNotEmpty ==
                true
            ? user['phone'].toString()
            : 'No Phone Number';

    final String firstLetter =
        userName.trim().isNotEmpty
            ? userName.trim()[0].toUpperCase()
            : 'U';

    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.profile,
      ),

      // =========================
      // BODY
      // =========================

      body: SafeArea(
        child: Stack(
          children: [
            // Top right decoration
            Positioned(
              top: -25,
              right: -25,
              child: Container(
                width: 105,
                height: 105,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFF2867E8),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Left decoration
            Positioned(
              top: 110,
              left: -45,
              child: Container(
                width: 100,
                height: 100,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFDCEBFA),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Right decoration
            Positioned(
              top: 310,
              right: -50,
              child: Container(
                width: 110,
                height: 110,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFDCEBFA),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Bottom left decoration
            Positioned(
              bottom: 55,
              left: -45,
              child: Container(
                width: 210,
                height: 210,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFE5F0FC),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // =========================
            // SCROLLABLE CONTENT
            // =========================

            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 25,
              ),
              child: Column(
                children: [
                  // =========================
                  // TITLE
                  // =========================

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      0,
                    ),
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: const Text(
                        'My Profile',
                        style: TextStyle(
                          color:
                              Color(0xFF142B4A),
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  // =========================
                  // USER AVATAR
                  // =========================

                  Container(
                    width: 88,
                    height: 88,
                    decoration:
                        const BoxDecoration(
                      color: Color(0xFFE1EFFC),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        firstLetter,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF142B4A),
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // USER NAME
                  // =========================

                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF315875),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Patient',
                    style: TextStyle(
                      color: Color(0xFFA3AFBB),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // EDIT BUTTON
                  // =========================

                  GestureDetector(
                    onTap: showEditProfile,
                    child: Container(
                      width: 180,
                      height: 55,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF3689D8,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Edit profile',
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // =========================
                  // PERSONAL INFORMATION
                  // =========================

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        'Personal Information',
                        style: TextStyle(
                          color:
                              Color(0xFF315875),
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _infoBox(
                    'Full Name',
                    userName,
                  ),

                  const SizedBox(height: 8),

                  _infoBox(
                    'Email',
                    email,
                  ),

                  const SizedBox(height: 8),

                  _infoBox(
                    'Phone Number',
                    phone,
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INFO BOX
  // =========================

  Widget _infoBox(
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      width: double.infinity,
      constraints:
          const BoxConstraints(
        minHeight: 92,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        10,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color:
              const Color(0xFFE8EDF1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color:
                  Color(0xFF9BA8B5),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color:
                  Color(0xFF315875),
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // NAV ITEM
  // =========================

  Widget _navItem(
    IconData icon,
    String title,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 75,
        height: 78,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: active
                  ? Colors.black
                  : const Color(
                      0xFF142B4A,
                    ),
            ),

            const SizedBox(height: 2),

            Text(
              title,
              style: TextStyle(
                color: active
                    ? Colors.black
                    : const Color(
                        0xFF142B4A,
                      ),
                fontSize: 11,
                fontWeight: active
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.dispose();
  }
}