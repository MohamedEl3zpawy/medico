import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medicine.dart';
import '../models/pharmacy.dart';
import '../models/offer.dart';
import '../models/order.dart';
import '../services/medicine_service.dart';
import '../widgets/app_bottom_nav.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  static const Color blue = Color(0xFF2864E8);
  static const Color darkBlue = Color(0xFF173F78);
  static const Color lightBlue = Color(0xFFE8F1FF);
  static const Color background = Color(0xFFF5F9FF);

  final TextEditingController searchController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  List<Medicine> medicines = [];
  List<Medicine> filteredMedicines = [];

  List<Pharmacy> pharmacies = [];
  List<Offer> offers = [];
  List<MedOrder> orders = [];

  bool loadingMedicines = true;
  bool loadingPharmacies = true;
  bool loadingOffers = true;
  bool loadingOrders = false;

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Pain Relief',
    'Vitamins',
    'Diabetes',
    'Skin Care',
    'Cold & Flu',
  ];

  @override
  void initState() {
    super.initState();

    loadMedicines();
    loadPharmacies();
    loadOffers();

    searchController.addListener(() {
      if (mounted) {
        applyMedicineFilter();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD MEDICINES
  // ============================================================

  Future<void> loadMedicines() async {
    try {
      final data = await MedicineService.getMedicines();

      medicines = data;
      filteredMedicines = List.from(medicines);
    } catch (e) {
      debugPrint('Error loading medicines: $e');
    }

    if (!mounted) return;

    setState(() {
      loadingMedicines = false;
    });
  }

  // ============================================================
  // LOAD PHARMACIES
  // ============================================================

  Future<void> loadPharmacies() async {
    try {
      final data = await MedicineService.getPharmacies();

      pharmacies = data;
    } catch (e) {
      debugPrint('Error loading pharmacies: $e');
    }

    if (!mounted) return;

    setState(() {
      loadingPharmacies = false;
    });
  }

  // ============================================================
  // LOAD OFFERS
  // ============================================================

  Future<void> loadOffers() async {
    try {
      final data = await MedicineService.getOffers();

      offers = data;

      debugPrint('Offers loaded: ${offers.length}');
    } catch (e) {
      debugPrint('Error loading offers: $e');
    }

    if (!mounted) return;

    setState(() {
      loadingOffers = false;
    });
  }

  // ============================================================
  // LOAD ORDERS
  // ============================================================

  Future<void> loadOrders() async {
    if (!mounted) return;

    setState(() {
      loadingOrders = true;
    });

    try {
      final data = await MedicineService.getOrders();

      orders = data;

      debugPrint('Orders loaded: ${orders.length}');
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    if (!mounted) return;

    setState(() {
      loadingOrders = false;
    });
  }

  // ============================================================
  // CREATE ORDER
  // ============================================================

  Future<void> createOrder(
    Medicine medicine,
  ) async {
    try {
      await MedicineService.createOrder(medicine);

      await loadOrders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${medicine.name} ordered successfully',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Create Order Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong',
          ),
        ),
      );
    }
  }

  // ============================================================
  // MY ORDERS
  // ============================================================

  Future<void> showMyOrders() async {
    await loadOrders();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (
            context,
            scrollController,
          ) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'My Orders',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (loadingOrders)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: blue,
                      ),
                    ),
                  )
                else if (orders.isEmpty)
                  _buildEmptyOrders()
                else
                  ...orders.map(
                    (order) => _buildOrderCard(order),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Future<void> showHistory() async {
    await loadOrders();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (
            context,
            scrollController,
          ) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.history,
                      color: blue,
                      size: 25,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'History',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (loadingOrders)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: blue,
                      ),
                    ),
                  )
                else if (orders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(35),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.grey,
                          size: 55,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No history yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Your previous orders will appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...orders.map(
                    (order) => _buildHistoryCard(order),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _buildHistoryCard(
    MedOrder order,
  ) {
    final name = order.medicineName;
    final price = order.price;
    final category = order.category;
    final status = order.status;
    final image = order.image;
    final quantity = order.quantity;
    final createdAt = order.createdAt;

    String dateText = '';

    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);

        dateText =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      } catch (_) {
        dateText = createdAt;
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: image != null &&
                    image.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.medication_outlined,
                          color: blue,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.medication_outlined,
                    color: blue,
                    size: 30,
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],

                const SizedBox(height: 5),

                Text(
                  '$price EGP',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),

                if (dateText.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Ordered on: $dateText',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],

                const SizedBox(height: 5),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
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
  // EMPTY ORDERS
  // ============================================================

  Widget _buildEmptyOrders() {
    return Container(
      padding: const EdgeInsets.all(35),
      child: const Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.grey,
            size: 55,
          ),
          SizedBox(height: 12),
          Text(
            'No orders yet',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your orders will appear here',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard(
    MedOrder order,
  ) {
    final name = order.medicineName;
    final price = order.price;
    final category = order.category;
    final status = order.status;
    final image = order.image;
    final quantity = order.quantity;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: image != null &&
                    image.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.medication_outlined,
                          color: blue,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.medication_outlined,
                    color: blue,
                    size: 30,
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (category.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],

                const SizedBox(height: 5),

                Text(
                  '$price EGP',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
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
  // SHOW ALL OFFERS
  // ============================================================

  void showAllOffers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (
            context,
            scrollController,
          ) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'Offers',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (loadingOffers)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: blue,
                      ),
                    ),
                  )
                else if (offers.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.all(30),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: Colors.grey,
                          size: 50,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No offers available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...offers.map(
                    (offer) {
                      final name = offer.name;
                      final description = offer.description;
                      final price = offer.price;
                      final oldPrice = offer.oldPrice;
                      final discount = offer.discount;
                      final image = offer.image;

                      return Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                              child: image != null &&
                                      image.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                      child:
                                          Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons
                                                .local_offer_outlined,
                                            color: blue,
                                            size: 30,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons
                                          .local_offer_outlined,
                                      color: blue,
                                      size: 30,
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
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color: darkBlue,
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  if (description
                                      .isNotEmpty) ...[
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      description,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                        '$price EGP',
                                        style:
                                            const TextStyle(
                                          color: blue,
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      if (oldPrice
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          '$oldPrice EGP',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration
                                                    .lineThrough,
                                          ),
                                        ),
                                      ],

                                      if (discount
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                Colors.white,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '$discount% OFF',
                                            style:
                                                const TextStyle(
                                              color: blue,
                                              fontSize: 9,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SEARCH + CATEGORY FILTER
  // ============================================================

  void applyMedicineFilter() {
    final query =
        searchController.text.trim().toLowerCase();

    List<Medicine> result =
        List.from(medicines);

    if (selectedCategory != 'All') {
      result = result.where((medicine) {
        final category =
            medicine.category.toLowerCase();

        return category ==
            selectedCategory.toLowerCase();
      }).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((medicine) {
        final name = medicine.name.toLowerCase();
        final category = medicine.category.toLowerCase();
        final description =
            medicine.description.toLowerCase();

        return name.contains(query) ||
            category.contains(query) ||
            description.contains(query);
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      filteredMedicines = result;
    });
  }

  // ============================================================
  // SEARCH BUTTON
  // ============================================================

  void searchMedicine() {
    FocusScope.of(context).unfocus();
    applyMedicineFilter();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void selectCategory(String category) {
    FocusScope.of(context).unfocus();

    setState(() {
      selectedCategory = category;
    });

    applyMedicineFilter();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void clearSearch() {
    searchController.clear();

    setState(() {
      selectedCategory = 'All';
      filteredMedicines = List.from(medicines);
    });
  }

  // ============================================================
  // UPLOAD PRESCRIPTION
  // ============================================================

  Future<void> uploadPrescription() async {
    try {
      final XFile? image =
          await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prescription uploaded successfully',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint(
        'Prescription upload error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not upload prescription',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ORDER MEDICINE
  // ============================================================

  void orderMedicine(
    Medicine medicine,
  ) {
    final medicineName = medicine.name;
    final price = medicine.price.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            20,
            22,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Order Medicine',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: medicine.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                            child: Image.network(
                              medicine.image,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons
                                      .medication_outlined,
                                  color: blue,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons
                                .medication_outlined,
                            color: blue,
                            size: 30,
                          ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicineName,
                          style: const TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '$price EGP',
                          style: const TextStyle(
                            color: blue,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          medicine.category,
                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    await createOrder(medicine);
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: blue,
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
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ORDER FROM PHARMACY
  // ============================================================

  void orderFromPharmacy(
    Pharmacy pharmacy,
  ) {
    final pharmacyName = pharmacy.name;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            20,
            22,
            30,
          ),
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

              Container(
                width: 70,
                height: 70,
                decoration:
                    const BoxDecoration(
                  color: lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_pharmacy_outlined,
                  color: blue,
                  size: 35,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                pharmacyName,
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                pharmacy.location,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                pharmacy.delivery.isNotEmpty
                    ? pharmacy.delivery
                    : 'Delivery available',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: blue,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order started from $pharmacyName',
                        ),
                        duration:
                            const Duration(
                          seconds: 2,
                        ),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: blue,
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
                  child: const Text(
                    'Continue Order',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool hasSearch =
        searchController.text.trim().isNotEmpty;

    final bool showingResults =
        hasSearch ||
        selectedCategory != 'All';

    return Scaffold(
      backgroundColor: background,

      bottomNavigationBar: const AppBottomNav(),

      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -35,
              right: -25,
              child: Container(
                width: 100,
                height: 100,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFB5D9F5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 85,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      top: 12,
                    ),
                    child: Text(
                      'Medicine',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ),

                  Container(
                    margin:
                        const EdgeInsets.fromLTRB(
                      22,
                      22,
                      22,
                      17,
                    ),
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE6ECF5),
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),
                    ),
                    padding:
                        const EdgeInsets.only(
                      left: 16,
                      right: 6,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: darkBlue,
                          size: 22,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: TextField(
                            controller:
                                searchController,
                            textInputAction:
                                TextInputAction
                                    .search,
                            onSubmitted: (_) {
                              searchMedicine();
                            },
                            decoration:
                                const InputDecoration(
                              border:
                                  InputBorder.none,
                              hintText:
                                  'Search for medicine & health products..',
                              hintStyle:
                                  TextStyle(
                                color:
                                    Color(0xFF7A879A),
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        if (hasSearch)
                          IconButton(
                            onPressed:
                                clearSearch,
                            icon:
                                const Icon(
                              Icons.close,
                              color: darkBlue,
                              size: 21,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ============================================================
                  // PRESCRIPTION
                  // ============================================================

                  Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    height: 125,
                    decoration:
                        BoxDecoration(
                      color: blue,
                      borderRadius:
                          BorderRadius.circular(
                        17,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          left: 17,
                          top: 7,
                          child: Text(
                            'Have a prescription?',
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Positioned(
                          left: 17,
                          top: 37,
                          child: SizedBox(
                            width: 285,
                            child: Text(
                              'Upload your prescription and find your medicines easily',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),

                        const Positioned(
                          right: 17,
                          top: 10,
                          child: Icon(
                            Icons
                                .insert_drive_file_outlined,
                            color:
                                Colors.white,
                            size: 36,
                          ),
                        ),

                        Positioned(
                          left: 105,
                          bottom: 15,
                          child:
                              GestureDetector(
                            onTap:
                                uploadPrescription,
                            child:
                                Container(
                              width: 137,
                              height: 36,
                              alignment:
                                  Alignment
                                      .center,
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  25,
                                ),
                              ),
                              child:
                                  const Text(
                                'Upload prescription',
                                style:
                                    TextStyle(
                                  color: blue,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ============================================================
                  // QUICK ACCESS
                  // ============================================================

                  Container(
                    margin:
                        const EdgeInsets
                            .fromLTRB(
                      24,
                      25,
                      24,
                      0,
                    ),
                    height: 140,
                    padding:
                        const EdgeInsets.only(
                      top: 17,
                      left: 12,
                      right: 12,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(
                            alpha: 0.10,
                          ),
                          blurRadius: 12,
                          offset:
                              const Offset(
                            0,
                            5,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(
                            left: 7,
                          ),
                          child: Text(
                            'Quick access',
                            style:
                                TextStyle(
                              color:
                                  darkBlue,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceAround,
                          children: [
                            QuickAccessItem(
                              imagePath:
                                  'assets/pharmacy.svg',
                              text:
                                  'Pharmacies',
                              onTap:
                                  showAllPharmacies,
                            ),

                            QuickAccessItem(
                              imagePath:
                                  'assets/Offers.svg',
                              text: 'Offers',
                              onTap:
                                  showAllOffers,
                            ),

                            QuickAccessItem(
                              imagePath:
                                  'assets/My orders.svg',
                              text:
                                  'My Orders',
                              onTap:
                                  showMyOrders,
                            ),

                            QuickAccessItem(
                              imagePath:
                                  'assets/History.svg',
                              text:
                                  'History',
                              onTap:
                                  showHistory,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(
                      left: 23,
                      top: 29,
                      bottom: 10,
                    ),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                      ),
                      scrollDirection:
                          Axis.horizontal,
                      itemCount:
                          categories.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        width: 8,
                      ),
                      itemBuilder:
                          (context, index) {
                        final category =
                            categories[index];

                        return CategoryItem(
                          text: category,
                          selected:
                              selectedCategory ==
                                  category,
                          imagePath:
                              category ==
                                      'Pain Relief'
                                  ? 'assets/Pain relief.svg'
                                  : null,
                          icon:
                              category == 'All'
                                  ? Icons
                                      .apps_outlined
                                  : category ==
                                          'Vitamins'
                                      ? Icons
                                          .favorite_border
                                      : category ==
                                              'Diabetes'
                                          ? Icons
                                              .water_drop_outlined
                                          : category ==
                                                  'Skin Care'
                                              ? Icons
                                                  .medication_outlined
                                              : Icons
                                                  .device_thermostat,
                          onTap: () {
                            selectCategory(
                              category,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  if (showingResults)
                    buildMedicineResults(),

                  buildPharmacies(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEDICINE RESULTS
  // ============================================================

  Widget buildMedicineResults() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            selectedCategory == 'All'
                ? 'Search Results'
                : selectedCategory,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (loadingMedicines)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child:
                    CircularProgressIndicator(
                  color: blue,
                ),
              ),
            )
          else if (filteredMedicines.isEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(25),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.search_off,
                    color: Colors.grey,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No medicines found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredMedicines.map(
              (medicine) => MedicineCard(
                medicine: medicine,
                onOrder: () {
                  orderMedicine(medicine);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PHARMACIES
  // ============================================================

  void showAllPharmacies() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder:
              (context, scrollController) {
            return ListView(
              controller:
                  scrollController,
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'All Pharmacies',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                if (loadingPharmacies)
                  const Padding(
                    padding:
                        EdgeInsets.all(30),
                    child: Center(
                      child:
                          CircularProgressIndicator(
                        color: blue,
                      ),
                    ),
                  )
                else if (pharmacies.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No pharmacies available',
                      ),
                    ),
                  )
                else
                  ...pharmacies.map(
                    (pharmacy) =>
                        PharmacyCard(
                      pharmacy: pharmacy,
                      onOrder: () {
                        Navigator.pop(
                          context,
                        );

                        orderFromPharmacy(
                          pharmacy,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildPharmacies() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              23,
              0,
              23,
              5,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Text(
                  'Nearby Pharmacies',
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                GestureDetector(
                  onTap:
                      showAllPharmacies,
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: blue,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (loadingPharmacies)
            const Padding(
              padding:
                  EdgeInsets.all(20),
              child:
                  CircularProgressIndicator(
                color: blue,
              ),
            )
          else if (pharmacies.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.all(20),
              child: Text(
                'No pharmacies available',
              ),
            )
          else
            ...pharmacies.take(2).map(
              (pharmacy) => PharmacyCard(
                pharmacy: pharmacy,
                onOrder: () {
                  orderFromPharmacy(
                    pharmacy,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// MEDICINE CARD
// ================================================================

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onOrder;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onOrder,
  });

  static const Color blue =
      Color(0xFF2864E8);

  static const Color darkBlue =
      Color(0xFF173F78);

  static const Color lightBlue =
      Color(0xFFE8F1FF);

  @override
  Widget build(BuildContext context) {
    final name = medicine.name;
    final price = medicine.price.toString();
    final category = medicine.category;
    final image = medicine.image;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
        left: 20,
        right: 20,
      ),
      padding:
          const EdgeInsets.all(11),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration:
                BoxDecoration(
              color: lightBlue,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: image.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons
                              .medication_outlined,
                          color: blue,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons
                        .medication_outlined,
                    color: blue,
                    size: 30,
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: darkBlue,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$price EGP',
                  style:
                      const TextStyle(
                    color: blue,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            height: 34,
            child:
                ElevatedButton(
              onPressed: onOrder,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),
              child:
                  const Text(
                'Order',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QUICK ACCESS ITEM
// ================================================================

class QuickAccessItem
    extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final String text;
  final VoidCallback? onTap;

  const QuickAccessItem({
    super.key,
    this.imagePath,
    this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 65,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFE8F1FF),
                shape: BoxShape.circle,
              ),
              child: imagePath != null
                  ? ClipOval(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(10),
                        child:
                            SvgPicture.asset(
                          imagePath!,
                          fit:
                              BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .image_outlined,
                              color:
                                  Colors.grey,
                              size: 23,
                            );
                          },
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color:
                          Colors.black,
                      size: 23,
                    ),
            ),

            const SizedBox(height: 5),

            Text(
              text,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(0xFF173F78),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CATEGORY ITEM
// ================================================================

class CategoryItem
    extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    this.imagePath,
    this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF2864E8,
                      )
                    : const Color(
                        0xFFE8F1FF,
                      ),
                shape:
                    BoxShape.circle,
              ),
              child: imagePath != null
                  ? ClipOval(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(10),
                        child:
                            SvgPicture.asset(
                          imagePath!,
                          fit:
                              BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Icon(
                              icon,
                              color:
                                  selected
                                      ? Colors
                                          .white
                                      : Colors
                                          .black,
                              size: 23,
                            );
                          },
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: selected
                          ? Colors.white
                          : Colors.black,
                      size: 23,
                    ),
            ),

            const SizedBox(height: 5),

            Text(
              text,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    const Color(
                  0xFF173F78,
                ),
                fontSize: 9,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PHARMACY CARD
// ================================================================

class PharmacyCard
    extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback onOrder;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final name = pharmacy.name;
    final distance = pharmacy.distance.toString();
    final rating = pharmacy.rating.toString();
    final reviews = pharmacy.reviews.toString();
    final delivery = pharmacy.delivery;
    final isOpen = pharmacy.isOpen;

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        20,
        5,
        20,
        8,
      ),
      constraints:
          const BoxConstraints(
        minHeight: 100,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),

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
                color:
                    Color(0xFF2864E8),
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
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF173F78),
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$distance • ${isOpen ? 'Open now' : 'Closed'}',
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF7C899A),
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 3),

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
                        width: 3,
                      ),

                      Text(
                        '$rating ($reviews)',
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF7C899A,
                          ),
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
                        color:
                            Color(
                          0xFF2864E8,
                        ),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.only(
                right: 12,
              ),
              child: SizedBox(
                height: 34,
                child:
                    ElevatedButton(
                  onPressed: isOpen
                      ? onOrder
                      : null,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2864E8,
                    ),
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        Colors.grey
                            .shade300,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        22,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'Order now',
                    style:
                        TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
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