import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/CustomTabBar.dart';
import 'package:befab/components/InfoCardTile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class NutritionPage2 extends StatelessWidget {
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

      body: Stack(
        children: [
          Column(
            children: [
              CustomTabBar(
                tabs: [
                  TabItem(
                    label: 'Nutrition',
                    image: "assets/images/nutrition.svg",
                  ),
                  TabItem(label: 'Fitness', image: "assets/images/fitness.svg"),
                ],
                      routes: [
          '/nutrition',
          '/fitness',
        ],
                      
                      selectedIndex: 1,
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
                  onTap:(){
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
                  onTap:(){
                      Navigator.pushNamed(context, "/vitals-measurement");
                    },
                  title: "Vital & Measurement",
                  subtitle: "Monitor hear rate , blood pressure",
                  image: ("assets/images/heartbeat.svg"),
                  iconBgColor: Color.fromARGB(221, 223, 200, 200),
                  iconColor: Color(0xFFDD2525),
                    isTrue: false,
                
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InfoCardTile(
                  onTap:(){
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
            ],
          ),
        ],
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
