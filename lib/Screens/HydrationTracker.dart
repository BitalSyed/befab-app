import 'package:befab/charts/HydrationTrackerWidget.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class HydrationTracker extends StatefulWidget {
  @override
  _HydrationTrackerState createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<HydrationTracker> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  Map<String, dynamic>? nutritionData;
  List<dynamic> foods = [];
  num selectedWater = 0;

  @override
  void initState() {
    super.initState();
    getData(); // Fetch initial data
  }

  Future<Map<String, dynamic>?> fetchNutritionData() async {
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

      // Get current date in YYYY-MM-DD format
      final String currentDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());

      // Build full URL
      final String url = '$backendUrl/app/nutrition/${currentDate}';
      final String url1 = '$backendUrl/app/nutrition/get/foods';
      print("Fetching nutrition data from: $url");

      // Make GET request with Authorization header
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final response1 = await http.get(
        Uri.parse(url1),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response1.statusCode == 200) {
        List<dynamic> data = jsonDecode(
          response1.body,
        ); // backend returns a list
        print("✅ Foods: $data");
        foods = data; // store the list directly
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print("✅ Nutrition data fetched successfully");
        return data;
      } else {
        print('⚠️ Failed to fetch data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching nutrition data: $e');
      return null;
    }
  }

  void getData() async {
    final data = await fetchNutritionData();
    if (data != null) {
      setState(() {
        // <-- REBUILD UI
        nutritionData = data; // update class-level variable
        print("data_nutrition: $nutritionData");
      });
    }
  }

  Future<void> _submitWater() async {
    try {
      // Get token from secure storage
      final token = await secureStorage.read(key: 'token');
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication required')));
        return;
      }

      // Get current date in YYYY-MM-DD format
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "water": "$selectedWater".toLowerCase(),
      };

      // Make the API call
      final response = await http.post(
        Uri.parse(
          '${dotenv.env['BACKEND_URL']}/app/nutrition/$currentDate/hydration',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - refresh data
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Water added successfully!')));
        getData(); // Refresh the data
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add water: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddWaterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Water Intake"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("How much water would you like to add?"),
              SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Water amount (ml)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedWater = num.tryParse(value) ?? 0;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showConfirmationDialog();
              },
              child: Text("Add Water"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Water Intake"),
          content: Text("Are you sure you want to add $selectedWater ml of water?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitWater();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _handleQuickAdd(int amount) {
    setState(() {
      selectedWater = amount;
    });
    _showConfirmationDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,  // Prevent M3 tint
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
          'Hydration Tracker',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            HydrationTrackerWidget(
              title: "Today's Hydration",
              consumedAmount: (nutritionData?['waterIntake_oz'] ?? 0),
              dailyGoal: 2000,
              currentCups: (((nutritionData?['waterIntake_oz'] ?? 0) / 250).round()),
              totalCups: 8,
              onTap: _showAddWaterDialog,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Quick Add",
                    style: GoogleFonts.lexend(
                            color: Color(0xFF000000),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  Text(
                    "",
                    style: GoogleFonts.lexend(
                            color: Color(0xFF862633),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _handleQuickAdd(100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFBFB)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("100 ml",style: TextStyle(color: Color(0xFF862633,),fontSize: 16,fontWeight: FontWeight.w600),),
                    )),
                ),
                GestureDetector(
                  onTap: () => _handleQuickAdd(250),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFBFB)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("250 ml",style: TextStyle(color: Color(0xFF862633,),fontSize: 16,fontWeight: FontWeight.w600),),
                    )),
                ),
                GestureDetector(
                  onTap: () => _handleQuickAdd(500),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFBFB)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("500 ml",style: TextStyle(color: Color(0xFF862633,),fontSize: 16,fontWeight: FontWeight.w600),),
                    )),
                ),
                GestureDetector(
                  onTap: () => _showAddWaterDialog(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFBFB)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Custom",style: TextStyle(color: Color(0xFF862633,),fontSize: 16,fontWeight: FontWeight.w600),),
                    )),
                ),
              ],
            ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "Today's Log",
            //         style: GoogleFonts.lexend(
            //                 color: Color(0xFF000000),
            //                 fontSize: 22,
            //                 fontWeight: FontWeight.w600,
            //               ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child:  Text(
            //         "",
            //         style: GoogleFonts.lexend(
            //                 color: Color(0xFF862633),
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w400,
            //               ),
            //       ),
            //     ),
            //   ],
            // ),
            // HeadingWithImageRow(
            //   heading: "250 ml",
            //   subtitle: "8:30 am",
            //   trailingWidget: SvgPicture.asset("assets/images/bin.svg",color: Color(0xFFFF1919),),
            // ),
            // HeadingWithImageRow(
            //   heading: "500 ml",
            //   subtitle: "11:30 am",
            //   trailingWidget: SvgPicture.asset("assets/images/bin.svg",color: Color(0xFFFF1919),),
            // ),
            // HeadingWithImageRow(
            //   heading: "150 ml",
            //   subtitle: "2:50 pm",
            //   trailingWidget: SvgPicture.asset("assets/images/bin.svg",color: Color(0xFFFF1919),),
            // ),
            // HeadingWithImageRow(
            //   heading: "100 ml",
            //   subtitle: "4:20 pm",
            //   trailingWidget: SvgPicture.asset("assets/images/bin.svg",color: Color(0xFFFF1919),),
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "Meal Breakdown",
            //         style: GoogleFonts.lexend(
            //                 color: Color(0xFF000000),
            //                 fontSize: 22,
            //                 fontWeight: FontWeight.w600,
            //               ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child:  Text(
            //         "",
            //         style: GoogleFonts.lexend(
            //                 color: Color(0xFF862633),
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w400,
            //               ),
            //       ),
            //     ),
            //   ],
            // ),
            // WeeklyStatusWidget(
            //   title: 'Weekly Status',
            //   viewAllText: 'View all',
            //   weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            //   averageLabel: 'Average',
            //   averageValue: '1750',
            //   averageUnit: 'ml',
            //   goalLabel: 'Goal',
            //   goalValue: '2000',
            //   goalUnit: 'ml',
            //   onViewAllTap: () {
            //     print('View all tapped');
            //   },
            //   titleColor: const Color(0xFF862633),
            //   viewAllColor: const Color(0xFF862633),
            //   averageColor: const Color(0xFF862633),
            //   goalColor: const Color(0xFF862633),
            //   backgroundColor: Color(0xFFFAFBFB),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Hydration Tips",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFAFBFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Good Protein intake",
                        style: TextStyle(
                          color: Color(0xFF862633),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "You are meeting your proteins goals, which is great for muscles maintainence and recovery",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24,)
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 11), // adjust as needed
        child: SizedBox(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}