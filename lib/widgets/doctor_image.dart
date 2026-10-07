import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_constants.dart';

String? doctorAsset(dynamic doctor) {
  final name = doctor['name']?.toString() ?? '';

  if (name == 'Dr. Ahmed Ali') {
    return 'doctor_avatar_1.svg';
  }

  if (name == 'Dr. Yasser Adel') {
    return 'doctor_avatar_3.svg';
  }

  if (name == 'Dr. Ehab Ahmed') {
    return 'doctor_avatar_2.svg';
  }

  return null;
}

Widget buildDoctorImage(dynamic doctor, {double radius = 35}) {
  final asset = doctorAsset(doctor);

  if (asset == null) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: radius * 1.15,
        color: navy,
      ),
    );
  }

  return SvgPicture.asset(
    'assets/$asset',
    width: radius * 2.2,
    height: radius * 2.55,
    fit: BoxFit.contain,
  );
}