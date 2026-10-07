import 'package:flutter/material.dart';
import '../services/medicine_service.dart';

class MedicineDetailsPage extends StatefulWidget {
  final String name;
  final String image;
  final String price;
  final String category;

  const MedicineDetailsPage({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
  });

  @override
  State<MedicineDetailsPage> createState() =>
      _MedicineDetailsPageState();
}

class _MedicineDetailsPageState
    extends State<MedicineDetailsPage> {
  static const Color blue = Color(0xFF2864E8);
  static const Color darkBlue = Color(0xFF173F78);
  static const Color background = Color(0xFFF5F9FF);

  List<dynamic> pharmacies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPharmacies();
  }

  Future<void> loadPharmacies() async {
    try {
      final data =
          await MedicineService.getPharmacies();

      if (!mounted) return;

      setState(() {
        pharmacies = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading pharmacies: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
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
            Icons.arrow_back_ios_new,
            color: darkBlue,
          ),
        ),
        title: const Text(
          'Medicine Details',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ================= MEDICINE =================

            Container(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE8F1FF),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: widget.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            child: Image.network(
                              widget.image,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons
                                      .medication_outlined,
                                  color: blue,
                                  size: 45,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons
                                .medication_outlined,
                            color: blue,
                            size: 45,
                          ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style:
                              const TextStyle(
                            color: darkBlue,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          widget.category,
                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${widget.price} EGP',
                          style:
                              const TextStyle(
                            color: blue,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= PHARMACIES =================

            const Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                25,
                22,
                10,
              ),
              child: Text(
                'Available Pharmacies',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child:
                      CircularProgressIndicator(
                    color: blue,
                  ),
                ),
              )
            else if (pharmacies.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'No pharmacies available',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...pharmacies.map(
                (pharmacy) {
                  final name =
                      pharmacy['name']
                              ?.toString() ??
                          'Pharmacy';

                  final isOpen =
                      pharmacy['isOpen'] == true;

                  final rating =
                      pharmacy['rating']
                              ?.toString() ??
                          '0';

                  final reviews =
                      pharmacy['reviews']
                              ?.toString() ??
                          '0';

                  final delivery =
                      pharmacy['delivery']
                              ?.toString() ??
                          '';

                  return Container(
                    margin:
                        const EdgeInsets.fromLTRB(
                      20,
                      5,
                      20,
                      10,
                    ),
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xFFE8F1FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons
                                .local_pharmacy_outlined,
                            color: blue,
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 12),

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
                                  color: darkBlue,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Row(
                                children: [
                                  const Text(
                                    '★★★★★',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFFFFB000,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 4,
                                  ),

                                  Text(
                                    '$rating ($reviews)',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),

                              if (delivery
                                  .isNotEmpty) ...[
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  delivery,
                                  style:
                                      const TextStyle(
                                    color: blue,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: isOpen
                              ? () {
                                  showOrderMessage(
                                    context,
                                    name,
                                  );
                                }
                              : null,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            disabledBackgroundColor:
                                Colors.grey.shade300,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: Text(
                            isOpen
                                ? 'Order now'
                                : 'Closed',
                            style:
                                const TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ================= ORDER =================

  void showOrderMessage(
    BuildContext context,
    String pharmacyName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Order',
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Order ${widget.name} from $pharmacyName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.name} ordered from $pharmacyName',
                    ),
                    duration:
                        const Duration(seconds: 2),
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}