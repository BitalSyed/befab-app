import 'package:befab/Screens/ActivityCalendarPage.dart';
import 'package:befab/Screens/AllNewsLetterScreen.dart';
import 'package:befab/Screens/CompetitionsProgressPage.dart';
import 'package:befab/Screens/DashboardScreen.dart';
import 'package:befab/Screens/GroupsScreen.dart';
import 'package:befab/Screens/Nutrition.dart';
import 'package:befab/Screens/SurveyScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

    const Color iconColor = Color(0xFF862633);
const Color selectedTileColor = Color.fromRGBO(134, 38, 51, 0.1);

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String profileImage; // can also be network URL
  final String? email;       // optional

  CustomDrawer({
    Key? key,
    required this.userName,
    required this.profileImage,
    this.email,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int selectedIndex = 0;

  final _secureStorage = FlutterSecureStorage();


final List<Map<String, dynamic>> menuItems = [
  {
    'title': 'Newsletters',
    'icon': 'assets/images/newsletters.svg',
    'route': '/all-newsletters'
  },
  {
    'title': 'Groups',
    'icon': 'assets/images/groups.svg',
    'route': '/groups'
  },
  {
    'title': 'Competitions',
    'icon': 'assets/images/competitions.svg',
    'route': '/competitions-progress'
  },
  {
    'title': 'Calendar',
    'icon': 'assets/images/calendar.svg',
    'route': '/calendar'
  },
  {
    'title': 'Surveys',
    'icon': 'assets/images/resources.svg',
    'route': '/survey'
  },
  {
    'title': 'Settings',
    'icon': 'assets/images/settings.svg',
    'route': '/settings'
  },
];
Widget? getTargetPage(String route) {
  switch (route) {
    case '/all-newsletters':
      return AllNewslettersScreen();
    case '/groups':
      return GroupsPage();
    case '/competitions-progress':
      return CompetitionsProgressPage();
    case '/calendar':
      return CalendarPage();
    case '/fitness':
      return NutritionPage();
    case '/resources':
      return DashboardScreen();
    case '/survey':
      return Surveyscreen();
    case '/settings':
      return DashboardScreen();
    default:
      return null;
  }
}


  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.profileImage),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                       Text(
                        'View Profile',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey                          
                        ,fontWeight: FontWeight.w500,
)
                        ,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Drawer Items
            ...List.generate(menuItems.length, (index) {
              final item = menuItems[index];
              return ListTile(
                selected: selectedIndex == index,
                selectedTileColor: selectedTileColor,
                leading: SvgPicture.asset(
  item['icon'],
  width: 24,
  height: 24,
  color: iconColor,
),
                title: Text(
                  item['title'],
                  style:  GoogleFonts.inter(color: Color(0xFF000000),fontSize: 16,fontWeight: FontWeight.w400),
                ),
                onTap: () {
  setState(() {
    selectedIndex = index;
  });
  Navigator.pop(context); // Close the drawer

  final targetPage = getTargetPage(item['route']);
  if (targetPage != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }
},


              );
            }),

            const Spacer(),

            // Logout Button
         Padding(
  padding: const EdgeInsets.all(12),
  child: Align(
    alignment: Alignment.centerLeft,
    child: GestureDetector(
      onTap: () async {
        // 1️⃣ Delete token from secure storage
        await _secureStorage.delete(key: 'token');

        // 2️⃣ Navigate to /signin and remove all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/signin',
          (Route<dynamic> route) => false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF862633),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/logout.svg',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)  ],
        ),
      ),
    );
  }
}
