import 'package:flutter/material.dart';
import '../services/doctor_service.dart';

class DoctorReviewsPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;

  const DoctorReviewsPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
  });

  @override
  State<DoctorReviewsPage> createState() =>
      _DoctorReviewsPageState();
}

class _DoctorReviewsPageState
    extends State<DoctorReviewsPage> {
  List<dynamic> reviews = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      final result =
          await DoctorService.getReviews(
        widget.doctorId,
      );

      if (!mounted) return;

      setState(() {
        reviews = result;
        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading reviews: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  double get averageRating {
    if (reviews.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final review in reviews) {
      total +=
          (review['rating'] as num?)?.toDouble() ??
              0;
    }

    return total / reviews.length;
  }

  int ratingCount(int rating) {
    return reviews.where((review) {
      final value =
          (review['rating'] as num?)?.toInt() ??
              0;

      return value == rating;
    }).length;
  }

  Widget buildStars(
    double rating, {
    double size = 18,
  }) {
    final rounded =
        rating.round();

    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          return Icon(
            index < rounded
                ? Icons.star
                : Icons.star_border,
            color:
                Colors.amber,
            size: size,
          );
        },
      ),
    );
  }

  Widget buildDoctorHeader() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor:
                Color(0xffEAF2FF),
            child: Icon(
              Icons.person,
              color:
                  Color(0xff2864E8),
              size: 38,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style:
                      const TextStyle(
                    color:
                        Color(0xff123B68),
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.doctorSpecialty,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color:
                          Colors.amber,
                      size: 17,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      averageRating
                          .toStringAsFixed(
                        1,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xff123B68,
                        ),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.favorite_border,
            color:
                Color(0xff123B68),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget buildRatingRow(
    int rating,
  ) {
    final count =
        ratingCount(rating);

    final total =
        reviews.isEmpty
            ? 1
            : reviews.length;

    final percentage =
        count / total;

    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            rating.toString(),
            style:
                const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            margin:
                const EdgeInsets
                    .symmetric(
              horizontal: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xffE2E8F0,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: FractionallySizedBox(
              alignment:
                  Alignment.centerLeft,
              widthFactor:
                  percentage,
              child: Container(
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xff2864E8,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRatingSummary() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Column(
              children: [
                Text(
                  averageRating
                      .toStringAsFixed(
                    1,
                  ),
                  style:
                      const TextStyle(
                    color:
                        Color(0xff123B68),
                    fontSize: 38,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                buildStars(
                  averageRating,
                  size: 17,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${reviews.length} Reviews',
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              children: [
                buildRatingRow(5),
                const SizedBox(
                  height: 8,
                ),
                buildRatingRow(4),
                const SizedBox(
                  height: 8,
                ),
                buildRatingRow(3),
                const SizedBox(
                  height: 8,
                ),
                buildRatingRow(2),
                const SizedBox(
                  height: 8,
                ),
                buildRatingRow(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReviewCard(
    dynamic review,
  ) {
    final String name =
        review['patientName']
                ?.toString() ??
            'Anonymous';

    final String comment =
        review['comment']
                ?.toString() ??
            '';

    final String date =
        review['date']
                ?.toString() ??
            '';

    final int rating =
        (review['rating'] as num?)
                ?.toInt() ??
            0;

    final String initials =
        name.isNotEmpty
            ? name
                .trim()
                .split(' ')
                .map(
                  (e) => e.isNotEmpty
                      ? e[0]
                      : '',
                )
                .take(2)
                .join()
                .toUpperCase()
            : 'U';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    const Color(
                  0xffEAF2FF,
                ),
                child: Text(
                  initials,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xff2864E8,
                    ),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      name,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xff123B68,
                        ),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      date,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              buildStars(
                rating.toDouble(),
                size: 15,
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            comment,
            style:
                const TextStyle(
              color:
                  Color(0xff64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Helpful',
            style:
                TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void showWriteReviewDialog() {
    int selectedRating = 5;

    final nameController =
        TextEditingController();

    final commentController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Write a Review',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          nameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Your name',
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children:
                          List.generate(
                        5,
                        (index) {
                          return IconButton(
                            onPressed: () {
                              setDialogState(
                                () {
                                  selectedRating =
                                      index +
                                          1;
                                },
                              );
                            },
                            icon: Icon(
                              index <
                                      selectedRating
                                  ? Icons
                                      .star
                                  : Icons
                                      .star_border,
                              color:
                                  Colors.amber,
                            ),
                          );
                        },
                      ),
                    ),
                    TextField(
                      controller:
                          commentController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Your review',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController
                            .text
                            .trim()
                            .isEmpty ||
                        commentController
                            .text
                            .trim()
                            .isEmpty) {
                      return;
                    }

                    try {
                      await DoctorService
                          .addReview(
                        doctorId:
                            widget.doctorId,
                        patientName:
                            nameController
                                .text
                                .trim(),
                        rating:
                            selectedRating,
                        comment:
                            commentController
                                .text
                                .trim(),
                      );

                      if (!dialogContext
                          .mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      await loadReviews();
                    } catch (e) {
                      debugPrint(
                        'Error adding review: $e',
                      );
                    }
                  },
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xff2864E8,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  child:
                      const Text(
                    'Submit',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF5F8FE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                        const Icon(
                      Icons.arrow_back,
                      color:
                          Color(
                        0xff123B68,
                      ),
                    ),
                  ),
                  const Text(
                    'Doctor Reviews',
                    style:
                        TextStyle(
                      color:
                          Color(
                        0xff123B68,
                      ),
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.favorite_border,
                    color:
                        Color(
                      0xff123B68,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          loadReviews,
                      child:
                          SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 30,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            buildDoctorHeader(),
                            const SizedBox(
                              height: 18,
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets
                                      .symmetric(
                                horizontal:
                                    20,
                              ),
                              child:
                                  Text(
                                'Patient Ratings',
                                style:
                                    TextStyle(
                                  color:
                                      Color(
                                    0xff123B68,
                                  ),
                                  fontSize:
                                      20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            buildRatingSummary(),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    20,
                              ),
                              child:
                                  SizedBox(
                                width:
                                    double.infinity,
                                height:
                                    48,
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      showWriteReviewDialog,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xff2864E8,
                                    ),
                                    foregroundColor:
                                        Colors.white,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        25,
                                      ),
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    'Write a Review',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets
                                      .symmetric(
                                horizontal:
                                    20,
                              ),
                              child:
                                  Text(
                                'Patient Reviews',
                                style:
                                    TextStyle(
                                  color:
                                      Color(
                                    0xff123B68,
                                  ),
                                  fontSize:
                                      20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (reviews
                                .isEmpty)
                              const Padding(
                                padding:
                                    EdgeInsets
                                        .all(
                                  35,
                                ),
                                child:
                                    Center(
                                  child:
                                      Text(
                                    'No reviews yet',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize:
                                          16,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      20,
                                ),
                                child:
                                    Column(
                                  children:
                                      reviews
                                          .map(
                                            (review) =>
                                                buildReviewCard(
                                              review,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}