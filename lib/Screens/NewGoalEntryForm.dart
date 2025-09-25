import 'dart:convert';
import 'package:befab/services/health_service/health_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:befab/Screens/GoalSetSuccessPage.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/InputBox.dart';
import 'package:befab/components/ProgressSwitchRow.dart';
import 'package:befab/components/StepsChart.dart';
import 'package:intl/intl.dart';

class NewGoalPage extends StatefulWidget {
  const NewGoalPage({Key? key}) : super(key: key);

  @override
  State<NewGoalPage> createState() => _NewGoalPageState();
}

class _NewGoalPageState extends State<NewGoalPage> {

  @override
  void initState() {
    super.initState();

    // 👇 FIX: Only run after widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHealthData();
    });
  }

  final HealthService healthService = HealthService();
  Map<String, dynamic>? healthData;

   Future<void> _loadHealthData() async {
    bool isInstalled = await healthService.isHealthAppInstalled();
    if (!isInstalled) {
      healthService.suggestInstallHealthApp(context);
      return;
    }

    bool authorized = await healthService.requestAuthorization();
    debugPrint("$authorized");
    if (!authorized) {
      debugPrint("❌ Health permissions denied!");
      return;
    }

    Map<String, dynamic> data = await healthService.fetchAllData(
      from: DateTime.now().subtract(const Duration(days: 30)),
      to: DateTime.now(),
    );

    if (!mounted) return;
    setState(() {
      healthData = data;
    });

    // sendData(data);

    debugPrint("✅ Platform: ${healthService.getPlatform()}");
    // debugPrint(
    //   "✅ Fetched health data: ${getHealthValue('HealthDataType.STEPS')}",
    // );
  }


Map<String, dynamic> calculateHealthDataTotal(
  Map<String, dynamic> healthData,
  String dataType,
  DateTime targetDate,
) {
  // Check if the data type exists in the health data
  if (!healthData.containsKey(dataType)) {
    return {'total': 0, 'unit': 'UNKNOWN'};
  }

  final List<dynamic> dataList = healthData[dataType];
  double total = 0;
  String unit = 'UNKNOWN';

  // Format the target date to match the format in the data (YYYY-MM-DD)
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final String targetDateString = dateFormat.format(targetDate);

  for (final dataEntry in dataList) {
    try {
      final String dateFrom = dataEntry['dateFrom'];
      
      // Extract just the date part (YYYY-MM-DD) from the timestamp
      final String entryDate = dateFrom.split('T')[0];
      
      // Check if this entry matches the target date
      if (entryDate == targetDateString) {
        final dynamic value = dataEntry['value'];
        final String currentUnit = dataEntry['unit'];
        
        // Update unit (should be consistent for same data type)
        unit = currentUnit;
        
        // Extract numeric value
        if (value is Map<String, dynamic> && value.containsKey('numericValue')) {
          final dynamic numericValue = value['numericValue'];
          if (numericValue is num) {
            total += numericValue.toDouble();
          }
        }
      }
    } catch (e) {
      // Skip malformed entries
      continue;
    }
  }

  return {
    'total': total,
    'unit': unit,
  };
}

  final TextEditingController goalController = TextEditingController();
  final TextEditingController monthsController = TextEditingController();
  final TextEditingController milestoneController = TextEditingController();
  String? selectedCategory; // For dropdown selection

  bool trackProgress = true;
  final List<String> categories = [
    'Steps',
    'Distance',
    'Calories Burned',
    'Calories Taken',
    'Water Intake',
  ];

  @override
  void dispose() {
    goalController.dispose();
    monthsController.dispose();
    milestoneController.dispose();
    super.dispose();
  }

  // create storage instance (at class level)
  final storage = const FlutterSecureStorage();

  Future<void> _setGoal() async {
    final String? baseUrl = dotenv.env['BACKEND_URL'];
    if (baseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server Error")),
      );
      return;
    }

    // Validate category selection
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    try {
      // get token from secure storage
      final token = await storage.read(key: "token");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session Expired, please login again.")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/app/goals"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": goalController.text.trim(),
          "durationDays": int.tryParse(monthsController.text.trim()) ?? 0,
          "milestones": milestoneController.text.trim(),
          "category": selectedCategory, // Add category to the request
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reset fields
        goalController.clear();
        monthsController.clear();
        milestoneController.clear();
        setState(() {
          selectedCategory = null;
        });

        // Navigate to dashboard
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/dashboard",
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/images/cross.svg',
                width: 15,
                height: 15,
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'New Goal',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EditableGoalInputBox(
                title: "What's your goal",
                hintText: "Drink more water, get fit",
                controller: goalController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EditableGoalInputBox(
                title: "By when (days)",
                hintText: "e.g., 150",
                controller: monthsController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EditableGoalInputBox(
                title: "Milestones",
                hintText: "1,000 (Steps, ml, etc.)",
                controller: milestoneController,
              ),
            ),
            // New Category Dropdown
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(), // Remove default underline
                      hint: const Text('Select a category'),
                      items: categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     "Get Personalized Tips",
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            // ),
            // ProgressSwitchRow(), // later bind this to `trackProgress`

            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text("Steps in 20 days"),
            // ),
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     "10k",
            //     style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
            //   ),
            // ),
            // const StepsChart(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _setGoal,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('Set Goal', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
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
          onPressed: () {
            Navigator.pushNamed(context, "/all-reels");
          },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}