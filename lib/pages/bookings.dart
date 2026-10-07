import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/booking.dart';
import 'medical.dart';
import '../widgets/app_bottom_nav.dart';


class BookingsApp extends StatelessWidget {
  const BookingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookingsPage();
  }
}

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  bool upcomingSelected = true;

  List<Booking> bookings = [];

  bool isLoading = true;

  String? errorMessage;

  final Color navy = const Color(0xFF12365F);
  final Color blue = const Color(0xFF2864DA);
  final Color lightBlue = const Color(0xFFEAF2FF);

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  // ============================================================
  // LOAD BOOKINGS FROM API
  // ============================================================

  Future<void> loadBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getBookings();

      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FE),

      bottomNavigationBar: const AppBottomNav(
        currentTab: AppTab.bookings,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: loadBookings,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  25,
                  35,
                  25,
                  30,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Text(
                      'Bookings',

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Manage your doctor appointments',

                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8794),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // TABS
                    // ==================================================

                    _tabs(),

                    const SizedBox(height: 22),

                    // ==================================================
                    // SECTION TITLE
                    // ==================================================

                    Text(
                      upcomingSelected
                          ? 'Upcoming Appointments'
                          : 'Past Appointments',

                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF151A23),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // BOOKINGS
                    // ==================================================

                    if (isLoading)
                      _loadingWidget()

                    else if (errorMessage != null)
                      _errorWidget()

                    else
                      _bookingsList(),

                    const SizedBox(height: 24),

                    // ==================================================
                    // MEDICAL REPORTS BUTTON
                    // ==================================================

                    _medicalReportsButton(),

                    const SizedBox(height: 20),

                    // ==================================================
                    // BOOK NEW APPOINTMENT
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 56,

                      child: ElevatedButton(
                        onPressed: () {},

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),

                        child: const Text(
                          '+ Book New Appointment',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 23),

                    // ==================================================
                    // REMINDER
                    // ==================================================

                    _reminder(),
                  ],
                ),
              ),
            ),

            // ========================================================
            // TOP RIGHT CIRCLE
            // ========================================================

            Positioned(
              right: -28,
              top: -38,

              child: Container(
                width: 95,
                height: 95,

                decoration:
                    const BoxDecoration(
                  color: Color(0xFFB8D9F6),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ========================================================
            // HEART BUTTON
            // ========================================================

            Positioned(
              right: 24,
              top: 45,

              child: Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF0F9),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color:
                        const Color(0xFFD7DEE9),
                  ),
                ),

                child: Icon(
                  Icons.favorite_border,
                  color: blue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _tabs() {
    return Container(
      height: 48,

      padding: const EdgeInsets.all(2),

      decoration: BoxDecoration(
        color: const Color(0xFFE7F0FF),

        borderRadius:
            BorderRadius.circular(25),
      ),

      child: Row(
        children: [
          _tab(
            'Upcoming',
            true,
          ),

          _tab(
            'Past',
            false,
          ),
        ],
      ),
    );
  }

  Widget _tab(
    String text,
    bool upcoming,
  ) {
    final bool selected =
        upcomingSelected == upcoming;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            upcomingSelected =
                upcoming;
          });
        },

        child: Container(
          alignment:
              Alignment.center,

          decoration:
              BoxDecoration(
            color: selected
                ? navy
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(24),
          ),

          child: Text(
            text,

            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF596273),

              fontSize: 12,

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER BOOKINGS
  // ============================================================

  Widget _bookingsList() {
    final String selectedStatus =
        upcomingSelected
            ? 'Upcoming'
            : 'Past';

    final List<Booking>
        filteredBookings =
        bookings.where((booking) {
      return booking.status == selectedStatus;
    }).toList();

    if (filteredBookings.isEmpty) {
      return _emptyWidget();
    }

    return Column(
      children: [
        for (int i = 0;
            i < filteredBookings.length;
            i++) ...[
          _appointment(
            booking:
                filteredBookings[i],
          ),

          if (i !=
              filteredBookings.length - 1)
            const SizedBox(height: 18),
        ],
      ],
    );
  }

  // ============================================================
  // APPOINTMENT CARD
  // ============================================================

  Widget _appointment({
    required Booking booking,
  }) {
    final String doctorName = booking.doctorName;
    final String specialty = booking.specialty;
    final String rating = booking.rating;
    final String distance = booking.distance;
    final String displayDate = booking.dateLabel;
    final String time = booking.time;
    final String visitType = booking.visitType;

    return Container(
      width: double.infinity,

      constraints:
          const BoxConstraints(
        minHeight: 167,
      ),

      padding:
          const EdgeInsets.fromLTRB(
        13,
        16,
        22,
        10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color:
              const Color(0xFFDDE2EA),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              // ==================================================
              // DOCTOR ICON
              // ==================================================

              Container(
                width: 57,
                height: 57,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFEAF2FF),
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  doctorName
                          .toLowerCase()
                          .contains('sara')
                      ? Icons.favorite
                      : Icons.add,

                  color: blue,
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // DOCTOR INFO
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      doctorName,

                      style: TextStyle(
                        color: navy,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      specialty,

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF7D8694),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: blue,
                          size: 12,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          '$rating • $distance',

                          style: TextStyle(
                            color: blue,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            height: 1,
            color:
                const Color(0xFFE9EDF2),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      displayDate,

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF3C4655),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$time • $visitType',

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF808895),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 77,
                height: 34,

                alignment:
                    Alignment.center,

                decoration:
                    BoxDecoration(
                  color: lightBlue,

                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),

                child: Text(
                  'View',

                  style: TextStyle(
                    color: blue,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MEDICAL REPORTS BUTTON
  // ============================================================

  Widget _medicalReportsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) =>
                 MedicalApp(),
          ),
        );
      },

      child: Container(
        width: double.infinity,
        height: 58,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        decoration: BoxDecoration(
          color: lightBlue,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color:
                const Color(0xFFD4E3FA),
          ),
        ),

        child: Row(
          children: [
            // ==================================================
            // ICON
            // ==================================================

            Container(
              width: 40,
              height: 40,

              decoration:
                  const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.description_outlined,
                color: blue,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // ==================================================
            // TEXT
            // ==================================================

            const Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Medical Reports',

                    style: TextStyle(
                      color:
                          Color(0xFF173B73),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'View your medical records',

                    style: TextStyle(
                      color:
                          Color(0xFF7B8798),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // ARROW
            // ==================================================

            Icon(
              Icons.arrow_forward_ios,
              color: blue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REMINDER
  // ============================================================

  Widget _reminder() {
    return Container(
      width: double.infinity,
      height: 86,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFE7F0FF),

        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,

            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.info_outline,
              color: blue,
              size: 18,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Appointment Reminder',

                  style: TextStyle(
                    color:
                        Color(0xFF173B73),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'You have an appointment today at 10:30 AM.',

                  style: TextStyle(
                    color:
                        Color(0xFF758093),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingWidget() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 50,
      ),

      child: Center(
        child: CircularProgressIndicator(
          color: blue,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorWidget() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color:
              const Color(0xFFDDE2EA),
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 40,
          ),

          const SizedBox(height: 10),

          const Text(
            'Could not load bookings',

            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            errorMessage ??
                'Unknown error',

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF7F8794),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: loadBookings,

            style:
                ElevatedButton.styleFrom(
              backgroundColor: navy,
            ),

            child: const Text(
              'Try Again',

              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyWidget() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 40,
      ),

      child: const Center(
        child: Text(
          'No appointments found.',

          style: TextStyle(
            color:
                Color(0xFF7F8794),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}