import 'package:befab/Screens/DashboardScreen.dart';
import 'package:befab/Screens/MessagesScreen.dart';
import 'package:befab/Screens/Nutrition.dart';
import 'package:befab/Screens/VideoCategoriesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  static const Color selectedColor = Color(0xFF862633);
  static const Color unselectedColor = Color(0xFF9CA3AF);
Widget? getTargetPage(int index) {
  switch (index) {
    case 0:
      return DashboardScreen();
    case 1:
      return NutritionPage();
    case 3:
      return VideoCategoriesScreen();
    case 4:
      return MessagesPage();
    default:
      return null;
  }
}

void _onItemTapped(BuildContext context, int index) {
  if (index == selectedIndex) return;

  final targetPage = getTargetPage(index);
  if (targetPage != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/Home.svg',
            width: 24,
            height: 24,
            color: selectedIndex == 0 ? selectedColor : unselectedColor,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/heartbeat.svg',
            width: 24,
            height: 24,
            color: selectedIndex == 1 ? selectedColor : unselectedColor,
          ),
          label: 'Health',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/video.svg',
            width: 24,
            height: 24,
            color: selectedIndex == 3 ? selectedColor : unselectedColor,
          ),
          label: 'Videos',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/message.svg',
            width: 24,
            height: 24,
            color: selectedIndex == 4 ? selectedColor : unselectedColor,
          ),
          label: 'Messages',
        ),
      ],
    );
  }
}
