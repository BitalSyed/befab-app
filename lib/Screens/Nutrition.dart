import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/CustomTabBar.dart';
import 'package:befab/components/InfoCardTile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class NutritionPage extends StatelessWidget {
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
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                // 🔔 Notification Bell with dot
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    SvgPicture.asset(
                      'assets/images/bell.svg',
                      height: 20,
                      width: 20,
                      color: Color(0xFF862633),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // // 🧑 Profile Avatar
                // CircleAvatar(
                //   radius: 18,
                //   backgroundImage: AssetImage('assets/images/profile.jpg'),
                // ),
                
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                CustomTabBar(
                  tabs: [
                    TabItem(
                      label: 'Nutrition',
                      image: "assets/images/nutrition.svg",
                    ),
                    TabItem(
                      label: 'Fitness',
                      image: "assets/images/fitness.svg",
                    ),
                  ],
                  routes: ['/nutrition', '/fitness'],
                ),
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
                    onTap:(){
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
                    onTap:(){
                      Navigator.pushNamed(context, "/search-food");
                    },
                    title: "Food Database Search",
                    subtitle: "Search nutritional info for foods",
                    image: ("assets/images/food.png"),
                    iconBgColor: Color(0xFFDCFCE7),
                    iconColor: Color.fromARGB(255, 5, 191, 11),
                    isTrue:true
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InfoCardTile(
                    onTap:(){
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
                    onTap:(){
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
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: IconButton(
          icon: const Icon(
            Icons.add_circle,
            size: 70,
            color: Color(0xFF862633),
          ),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}

