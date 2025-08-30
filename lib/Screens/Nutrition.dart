import 'dart:convert';

import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/CustomTabBar.dart';
import 'package:befab/components/InfoCardTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

// Updated CustomTabBar without navigation routes
class CustomTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final Function(int) onTabChanged;
  final int selectedIndex;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ), // 👈 top/bottom padding here
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF862633) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tab.image != null)
                      SvgPicture.asset(
                        tab.image!,
                        width: 20,
                        height: 20,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    if (tab.image != null)
                      const SizedBox(width: 8), // spacing between icon & text
                    Text(
                      tab.label,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TabItem {
  final String label;
  final String? image;

  TabItem({required this.label, this.image});
}

// Main Nutrition Page
class NutritionPage extends StatefulWidget {
  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  int _selectedTab = 0; // 0 for Nutrition, 1 for Fitness
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      // Sync the tab indicator with page view
      setState(() {
        _selectedTab = _pageController.page!.round();
      });
    });
      _loadNotifications();
  }

  var notifications;

   Future<List<dynamic>?> fetchNotifications() async {
    try {
      // Get backend URL
      final String backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      if (backendUrl.isEmpty) {
        print("⚠️ BACKEND_URL is empty in .env");
        return null;
      }

      // Get token from secure storage
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token == null) {
        print("⚠️ No auth token found in storage");
        return null;
      }

      // Build full URL
      final String url = '$backendUrl/app/notifications';
      print("Fetching notifications from: $url");

      // Make GET request with Authorization header
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("✅ Notifications fetched successfully");
        print("🔔 Number of notifications: ${data.length}");
        return data;
      } else {
        print(
          '⚠️ Failed to fetch notifications. Status code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return null;
    }
  }

Future<void> _loadNotifications() async {
    final data = await fetchNotifications(); // ✅ await here
    setState(() {
      notifications = data ?? [];
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  'assets/images/Arrow.svg',
                  width: 14,
                  height: 14,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'Back',
                style: GoogleFonts.inter(
                  color: Color(0xFF862633),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          'Health Dashboard',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              right: 12,
              left: 4,
              bottom: 4,
            ),
            child: GestureDetector(
              onTap: () {
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    overlay.size.width, // right align
                    kToolbarHeight, // just below AppBar
                    0,
                    0,
                  ),
                  items: [
                    PopupMenuItem(
                      enabled: false, // non-clickable header
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Notifications",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),

                          // ✅ Handle null safely
                          if (notifications != null && notifications.isNotEmpty)
                            ...notifications.map((n) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.notifications,
                                  color: Colors.pink,
                                ),
                                title: Text(n["content"] ?? "No content"),
                                subtitle: Text(
                                  n["createdAt"] != null
                                      ? DateTime.parse(
                                        n["createdAt"],
                                      ).toLocal().toString()
                                      : "Unknown time",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList()
                          else
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No notifications yet"),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/images/bell.svg',
                    height: 24,
                    width: 24,
                    color: const Color(0xFF862633),
                  ),
                  if (notifications != null && notifications.isNotEmpty)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
    ),
      body: Column(
        children: [
          CustomTabBar(
            tabs: [
              TabItem(label: 'Nutrition', image: "assets/images/nutrition.svg"),
              TabItem(label: 'Fitness', image: "assets/images/fitness.svg"),
            ],
            selectedIndex: _selectedTab,
            onTabChanged: (index) {
              setState(() {
                _selectedTab = index;
              });
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              children: [_buildNutritionContent(), _buildFitnessContent()],
            ),
          ),
        ],
      ),
      // floatingActionButton: _selectedTab == 0 ? SizedBox(
      //   width: 70,
      //   height: 70,
      //   child: IconButton(
      //     icon: const Icon(
      //       Icons.add_circle,
      //       size: 70,
      //       color: Color(0xFF862633),
      //     ),
      //     onPressed: () {},
      //   ),
      // ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildNutritionContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12,
              ),
              child: Text(
                "Nutrition Categories",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/meal-logging");
              },
              title: "Meal Logging",
              subtitle: "Track your daily meals and snacks",
              image: ("assets/images/calorie.svg"),
              iconColor: Color(0xFFF97316),
              iconBgColor: Color(0xFFFFEDD5),
              isTrue: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/search-food");
              },
              title: "Food Database Search",
              subtitle: "Search nutritional info for foods",
              image: ("assets/images/food.png"),
              iconBgColor: Color(0xFFDCFCE7),
              iconColor: Color.fromARGB(255, 5, 191, 11),
              isTrue: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/add-meal");
              },
              title: "Calorie & Macro Tracking",
              subtitle: "Monitor calories, protein, carbs & fat",
              image: ("assets/images/meal.svg"),
              iconBgColor: Color(0xFFF3E8FF),
              iconColor: Color(0xFFA855F7),
              isTrue: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/hydration-tracker");
              },
              title: "Hydration Tracker",
              subtitle: "Track daily water intake",
              image: ("assets/images/droplet.svg"),
              iconBgColor: Color(0xFFDBEAFE),
              iconColor: Color(0xFF3B82F6),
              isTrue: false,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFitnessContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12,
              ),
              child: Text(
                "Fitness Categories",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/fitness-summary");
              },
              title: "Fitness Summary",
              subtitle: "Summary and track records",
              image: ("assets/images/dumbell.svg"),
              iconColor: Color(0xFF16A34A),
              iconBgColor: Color(0xFFDCFCE7),
              isTrue: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/activity-fitness");
              },
              title: "Activity & Fitness",
              subtitle: "Track workout steps and activities",
              image: ("assets/images/vital.svg"),
              iconBgColor: Color(0xFFF3E8FF),
              iconColor: Color(0xFFA855F7),
              isTrue: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/vitals-measurement");
              },
              title: "Vital & Measurement",
              subtitle: "Monitor heart rate, blood pressure",
              image: ("assets/images/heartbeat.svg"),
              iconBgColor: Color.fromARGB(221, 223, 200, 200),
              iconColor: Color(0xFFDD2525),
              isTrue: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InfoCardTile(
              onTap: () {
                Navigator.pushNamed(context, "/body-composition");
              },
              title: "Body Composition",
              subtitle: "Weight, BMI, body fat percentage",
              image: ("assets/images/body.svg"),
              iconBgColor: Color(0xFFDBEAFE),
              iconColor: Color(0xFF0074C4),
              isTrue: false,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
