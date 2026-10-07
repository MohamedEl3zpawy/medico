import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../pages/bookings.dart';
import '../pages/favourite_doctors_page.dart';
import '../pages/profile_page.dart';
import '../providers/user_provider.dart';

enum AppTab { home, bookings, favorites, profile }

class AppBottomNav extends StatelessWidget {
  final AppTab? currentTab;

  const AppBottomNav({super.key, this.currentTab});

  static const Color navy = Color(0xFF12365F);
  static const Color lightBlue = Color(0xFFEAF2FF);

  void _goTo(BuildContext context, AppTab tab) {
    if (tab == currentTab) return;

    switch (tab) {
      case AppTab.home:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
        break;

      case AppTab.bookings:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingsPage(),
          ),
        );
        break;

      case AppTab.favorites:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const FavouriteDoctorsPage(),
          ),
        );
        break;

      case AppTab.profile:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userId:
                  context.read<UserProvider>().userId,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      height: 58,
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(
            context,
            Icons.home_rounded,
            'Home',
            AppTab.home,
          ),
          _item(
            context,
            Icons.calendar_month_outlined,
            'Booking',
            AppTab.bookings,
          ),
          _item(
            context,
            Icons.favorite_border_rounded,
            'Favorite',
            AppTab.favorites,
          ),
          _item(
            context,
            Icons.person_outline_rounded,
            'Profile',
            AppTab.profile,
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    AppTab tab,
  ) {
    final bool active = tab == currentTab;

    return GestureDetector(
      onTap: () => _goTo(context, tab),
      child: SizedBox(
        width: 70,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: active ? navy : Colors.black87,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: active ? navy : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}