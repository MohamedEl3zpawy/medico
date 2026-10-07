import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MedicalReportsPage();
  }
}

class MedicalReportsPage extends StatefulWidget {
  const MedicalReportsPage({super.key});

  @override
  State<MedicalReportsPage> createState() =>
      _MedicalReportsPageState();
}

class _MedicalReportsPageState
    extends State<MedicalReportsPage> {
  final Color navy =
      const Color(0xFF12365F);

  final Color blue =
      const Color(0xFF2864DA);

  final Color lightBlue =
      const Color(0xFFEAF2FF);

  List<dynamic> reports = [];

  List<dynamic> filteredReports = [];

  bool isLoading = true;

  String? errorMessage;

  final TextEditingController
      searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    loadReports();

    searchController.addListener(
      filterReports,
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD REPORTS
  // ============================================================

  Future<void> loadReports() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data =
          await ApiService.getReports();

      setState(() {
        reports = data;
        filteredReports = data;
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
  // SEARCH
  // ============================================================

  void filterReports() {
    final String query =
        searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredReports = reports;
      });

      return;
    }

    final List<dynamic> results =
        reports.where((report) {
      if (report is! Map) {
        return false;
      }

      final String title =
          report['title']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final String category =
          report['category']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final String date =
          report['date']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final String fileType =
          report['fileType']
                  ?.toString()
                  .toLowerCase() ??
              '';

      return title.contains(query) ||
          category.contains(query) ||
          date.contains(query) ||
          fileType.contains(query);
    }).toList();

    setState(() {
      filteredReports = results;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9FE),

      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: loadReports,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  25,
                  22,
                  25,
                  30,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // BACK + TITLE
                    // ==================================================

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },

                          child: Container(
                            width: 40,
                            height: 40,

                            decoration:
                                const BoxDecoration(
                              color: Colors.white,
                              shape:
                                  BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color:
                                  Color(0xFF172033),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          'Medical Reports',

                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF172033),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // SEARCH
                    // ==================================================

                    _searchBox(),

                    const SizedBox(height: 30),

                    // ==================================================
                    // RECORDS CARD
                    // ==================================================

                    _recordsCard(),

                    const SizedBox(height: 25),

                    const Text(
                      'Recent Reports',

                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF151A23),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // REPORTS
                    // ==================================================

                    if (isLoading)
                      _loadingWidget()

                    else if (errorMessage != null)
                      _errorWidget()

                    else if (filteredReports.isEmpty)
                      _emptyWidget()

                    else
                      _reportsList(),

                    const SizedBox(height: 25),

                    // ==================================================
                    // UPLOAD BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: () {
                          _showUploadMessage();
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              navy,

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
                          '+ Upload New Report',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // TOP RIGHT CIRCLE
            // ========================================================

            Positioned(
              right: -30,
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BOX
  // ============================================================

  Widget _searchBox() {
    return Container(
      height: 54,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(30),

        border: Border.all(
          color: Colors.black,
          width: 1.2,
        ),
      ),

      child: TextField(
        controller:
            searchController,

        decoration:
            const InputDecoration(
          hintText:
              'Search reports...',

          hintStyle:
              TextStyle(
            color:
                Color(0xFF9AA1AD),
            fontSize: 14,
          ),

          border:
              InputBorder.none,

          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),

          suffixIcon: Padding(
            padding:
                EdgeInsets.only(
              right: 8,
            ),

            child: Icon(
              Icons.search,
              size: 30,
              color:
                  Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECORDS CARD
  // ============================================================

  Widget _recordsCard() {
    final int totalReports =
        reports.length;

    return Container(
      width: double.infinity,
      height: 105,

      padding:
          const EdgeInsets.fromLTRB(
        15,
        15,
        20,
        10,
      ),

      decoration: BoxDecoration(
        color: navy,

        borderRadius:
            BorderRadius.circular(17),
      ),

      child: Stack(
        children: [
          const Text(
            'Your Medical Records',

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          Positioned(
            left: 17,
            top: 36,

            child: Text(
              '$totalReports reports available',

              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          Positioned(
            right: 12,
            top: 22,

            child: Text(
              '$totalReports',

              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          Positioned(
            left: 11,
            bottom: 8,

            child: Container(
              width: 128,
              height: 8,

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFF78A9F4),

                borderRadius:
                    BorderRadius.circular(8),
              ),

              child:
                  FractionallySizedBox(
                alignment:
                    Alignment.centerLeft,

                widthFactor:
                    totalReports > 0
                        ? 1.0
                        : 0.0,

                child: Container(
                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORTS LIST
  // ============================================================

  Widget _reportsList() {
    return Column(
      children: [
        for (int i = 0;
            i < filteredReports.length;
            i++) ...[
          _report(
            filteredReports[i],
          ),

          if (i !=
              filteredReports.length - 1)
            const SizedBox(height: 18),
        ],
      ],
    );
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget _report(
    dynamic report,
  ) {
    final String title =
        report['title']
                ?.toString() ??
            'Medical Report';

    final String category =
        report['category']
                ?.toString() ??
            'Medical';

    final String date =
        report['date']
                ?.toString() ??
            '';

    final String fileType =
        report['fileType']
                ?.toString() ??
            'PDF';

    final String action =
        report['action']
                ?.toString() ??
            'View report';

    return GestureDetector(
      onTap: () {
        _showReportDetails(
          report,
        );
      },

      child: Container(
        width: double.infinity,

        constraints:
            const BoxConstraints(
          minHeight: 105,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
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

        child: Row(
          children: [
            // ======================================================
            // ICON
            // ======================================================

            Container(
              width: 52,
              height: 52,

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFEAF2FF),
                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                _getReportIcon(
                  category,
                ),

                color: blue,
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            // ======================================================
            // INFO
            // ======================================================

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '$category • ${_formatDate(date)}',

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      color:
                          Color(0xFF858D99),
                      fontSize: 10.5,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    action,

                    style: TextStyle(
                      color: blue,
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ======================================================
            // PDF
            // ======================================================

            Container(
              width: 43,
              height: 25,

              alignment:
                  Alignment.center,

              decoration:
                  BoxDecoration(
                color: lightBlue,

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: Text(
                fileType,

                style: TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _getReportIcon(
    String category,
  ) {
    final String value =
        category.toLowerCase();

    if (value.contains(
          'radiology',
        ) ||
        value.contains('x-ray')) {
      return Icons.crop_square;
    }

    if (value.contains(
      'cardio',
    )) {
      return Icons.favorite;
    }

    if (value.contains(
      'laboratory',
    )) {
      return Icons.science_outlined;
    }

    return Icons.description_outlined;
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
    String date,
  ) {
    try {
      final DateTime parsed =
          DateTime.parse(date);

      const List<String>
          months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[parsed.month - 1]} '
          '${parsed.day}, '
          '${parsed.year}';
    } catch (e) {
      return date;
    }
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
        child:
            CircularProgressIndicator(
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
            color:
                Colors.red.shade400,
            size: 40,
          ),

          const SizedBox(height: 10),

          const Text(
            'Could not load reports',

            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            errorMessage ??
                'Unknown error',

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF7F8794),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: loadReports,

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
    final bool searching =
        searchController.text
            .trim()
            .isNotEmpty;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),

      child: Column(
        children: [
          Icon(
            searching
                ? Icons.search_off
                : Icons.description_outlined,

            color: blue,
            size: 45,
          ),

          const SizedBox(height: 15),

          Text(
            searching
                ? 'No reports found'
                : 'No medical reports',

            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            searching
                ? 'Try searching with another word.'
                : 'You don\'t have any medical reports yet.',

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 10,
              color:
                  Color(0xFF7F8794),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT DETAILS
  // ============================================================

  void _showReportDetails(
    dynamic report,
  ) {
    final String title =
        report['title']
                ?.toString() ??
            'Medical Report';

    final String category =
        report['category']
                ?.toString() ??
            'Medical';

    final String date =
        report['date']
                ?.toString() ??
            '';

    final String fileType =
        report['fileType']
                ?.toString() ??
            'PDF';

    final String action =
        report['action']
                ?.toString() ??
            'View report';

    showModalBottomSheet(
      context: context,

      backgroundColor:
          Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.all(25),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Report Details',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,

                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                  color: navy,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                category,

                style:
                    const TextStyle(
                  color:
                      Color(0xFF7D8694),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Date: ${_formatDate(date)}',

                style:
                    const TextStyle(
                  color:
                      Color(0xFF3C4655),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'File Type: $fileType',

                style:
                    const TextStyle(
                  color:
                      Color(0xFF3C4655),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        navy,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),

                  child: Text(
                    action,

                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // UPLOAD
  // ============================================================

  void _showUploadMessage() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Upload Report',
          ),

          content:
              const Text(
            'The upload feature will be connected when an upload API is available.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },

              child: Text(
                'OK',

                style: TextStyle(
                  color: navy,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}