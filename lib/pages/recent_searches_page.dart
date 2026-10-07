import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';

class RecentSearchesPage extends StatefulWidget {
  const RecentSearchesPage({super.key});

  @override
  State<RecentSearchesPage> createState() =>
      _RecentSearchesPageState();
}

class _RecentSearchesPageState
    extends State<RecentSearchesPage> {
  final TextEditingController searchController =
      TextEditingController();

  List<String> recentSearches = [];
  List<Doctor> doctors = [];
  List<Doctor> searchResults = [];

  bool loading = true;
  bool isSearching = false;

  static const popularSpecialties = [
    'Cardiology',
    'Medicine',
    'Dentistry',
    'Neurology',
    'Pediatrics',
    'Surgery',
  ];

  static const browseSpecialties = [
    'Cardiology',
    'Medicine',
    'Dentistry',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Surgery',
    'Ophthalmology',
    'Orthopedics',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final recentData =
          await DoctorService.getRecentSearches();

      final doctorData =
          await DoctorService.getDoctors();

      if (!mounted) return;

      setState(() {
        recentSearches = recentData
            .map<String>(
              (item) => item['text'].toString(),
            )
            .toList();

        doctors = doctorData;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      debugPrint('Error loading search data: $e');
    }
  }

  void _performSearch() {
    final text =
        searchController.text.trim().toLowerCase();

    if (text.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    final results = doctors.where((doctor) {
      final name = doctor.name.toLowerCase();
      final specialty = doctor.specialty.toLowerCase();

      return name.contains(text) ||
          specialty.contains(text);
    }).toList();

    setState(() {
      searchResults = results;
      isSearching = true;
    });
  }

  void _searchText(String text) {
    searchController.text = text;
    _performSearch();
  }

  void _clearSearch() {
    searchController.clear();

    setState(() {
      searchResults = [];
      isSearching = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: -25,
              child: _backgroundCircle(75),
            ),
            Positioned(
              bottom: 80,
              left: -35,
              child: _backgroundCircle(75),
            ),
            Column(
              children: [
                const SizedBox(height: 55),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),

                        if (isSearching)
                          _buildSearchResults()
                        else ...[
                          _buildSectionTitle(
                            'Recent Searches',
                          ),
                          const SizedBox(height: 8),
                          _buildRecentSearches(),

                          const SizedBox(height: 14),

                          _buildSectionTitle(
                            'Popular Specialties',
                          ),
                          const SizedBox(height: 8),
                          _buildPopularSpecialties(),

                          const SizedBox(height: 14),

                          _buildSectionTitle(
                            'Browse by Specialty',
                          ),
                          const SizedBox(height: 8),
                          _buildBrowseSpecialties(),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          if (value.isEmpty) {
            _clearSearch();
          } else {
            _performSearch();
          }
        },
        onSubmitted: (_) {
          _performSearch();
        },
        textAlignVertical:
            TextAlignVertical.center,
        decoration: InputDecoration(
          hintText:
              'Search doctors , specialties .......',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
          suffixIcon:
              searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 22,
                      ),
                      onPressed: _clearSearch,
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black87,
                        size: 25,
                      ),
                      onPressed: _performSearch,
                    ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Search Results'),
        const SizedBox(height: 10),
        if (searchResults.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFFC7E4FA),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'No doctors found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          Column(
            children: searchResults
                .map(
                  (doctor) =>
                      _buildDoctorResult(doctor),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildDoctorResult(Doctor doctor) {
    return Container(
      width: double.infinity,
      height: 90,
      margin:
          const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF173B63),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 34,
              color: const Color(0xFF173B63),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const Text(
                  '★★★★★',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF173B63),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recentSearches.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFC7E4FA),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'No recent searches',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC7E4FA),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        children: recentSearches
            .map(
              (search) => InkWell(
                onTap: () {
                  _searchText(search);
                },
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          search,
                          style:
                              const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 27,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPopularSpecialties() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC7E4FA),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 28,
        runSpacing: 8,
        alignment:
            WrapAlignment.center,
        children:
            popularSpecialties.map(
          (specialty) {
            return GestureDetector(
              onTap: () {
                _searchText(specialty);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF173B63),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  specialty,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildBrowseSpecialties() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC7E4FA),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount:
            browseSpecialties.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 5,
          childAspectRatio: 3.1,
        ),
        itemBuilder:
            (context, index) {
          final specialty =
              browseSpecialties[index];

          return GestureDetector(
            onTap: () {
              _searchText(specialty);
            },
            child: Center(
              child: Text(
                specialty,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _backgroundCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(
        color: Color(0xFFE6F2FF),
        shape: BoxShape.circle,
      ),
    );
  }
}