import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_absence/views/home_screen.dart';
import 'package:student_absence/views/presence_screen.dart';
import 'package:student_absence/views/history_screen.dart';
import 'package:student_absence/views/profile_screen.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex; // Indeks menu aktif

  const CustomNavigationBar({Key? key, required this.currentIndex})
      : super(key: key);

  void _onItemTapped(int index, BuildContext context) {
    if (index != currentIndex) {
      // Navigasi berdasarkan indeks menu
      switch (index) {
        case 0:
          Get.offAll(() => HomeScreen());
          break;
        case 1:
          Get.offAll(() => PresenceScreen());
          break;
        case 2:
          Get.offAll(() => HistoryScreen());
          break;
        case 3:
          Get.offAll(() => ProfileScreen());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendeteksi ukuran layar
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    final List<IconData> icons = [
      Icons.home,
      Icons.date_range,
      Icons.history,
      Icons.person,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: isSmallScreen ? 8.0 : 16.0),
      child: Container(
        height: isSmallScreen ? 60 : 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 30 : 40),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index, context),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color.fromRGBO(31, 80, 154, 1)
                      : Colors.transparent,
                ),
                child: Icon(
                  icons[index],
                  size: isSmallScreen ? 30 : 40,
                  color: isSelected
                      ? Colors.white
                      : const Color.fromARGB(255, 133, 133, 133),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
