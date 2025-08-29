// dashboard_screen.dart
import 'dart:convert';
import 'package:befab/Screens/NewGoalEntryForm.dart';
import 'package:befab/charts/WeightLossProgressChart.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/CustomDrawer.dart';
import 'package:befab/services/health_service.dart';
import 'package:befab/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final storage = const FlutterSecureStorage();

  String firstName = "";
  String lastName = "";
  String profilePhoto = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHealthData();
    });
    data = getDWMPercentagesForStepsAndDistance();
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

    debugPrint("✅ Platform: ${healthService.getPlatform()}");
    debugPrint(
      "✅ Fetched health data: ${getHealthValue('HealthDataType.STEPS')}",
    );
  }

  // Helper to get a single value safely from healthData
  Map<String, String> simplifiedUnits = {
    "METER": "m",
    "KILOMETER": "km",
    "MILE": "mi",
    "YARD": "yd",
    "FOOT": "ft",
    "GRAM": "g",
    "KILOGRAM": "kg",
    "OUNCE": "oz",
    "POUND": "lb",
    "MILLIMETER_OF_MERCURY": "mmHg",
    "INCH_OF_MERCURY": "inHg",
    "PASCAL": "Pa",
    "KILOPASCAL": "kPa",
    "CELSIUS": "°C",
    "FAHRENHEIT": "°F",
    "KELVIN": "K",
    "CALORIE": "kcal",
    "KILOJOULE": "kJ",
    "SECOND": "s",
    "MINUTE": "min",
    "HOUR": "h",
    "DAY": "d",
    "LITER": "L",
    "MILLILITER": "mL",
    "FLUID_OUNCE_US": "fl oz",
    "COUNT": "",
    "BEAT": "beat",
    "BEAT_PER_MINUTE": "bpm",
    "REP": "rep",
    "PERCENTAGE": "%",
    "SLEEP_ASLEEP": "sleep",
    "SLEEP_IN_BED": "in bed",
    "SLEEP_AWAKE": "awake",
    "DISTANCE_WALKING_RUNNING": "m",
    "DISTANCE_CYCLING": "m",
    "ACTIVE_ENERGY_BURNED": "kcal",
    "BASAL_ENERGY_BURNED": "kcal",
    "BODY_MASS_INDEX": "BMI",
    "BODY_FAT_PERCENTAGE": "%",
    "LEAN_BODY_MASS": "kg",
    "RESTING_HEART_RATE": "bpm",
    "HEART_RATE": "bpm",
    "STEP_COUNT": "",
    "FLIGHTS_CLIMBED": "fl",
    "WALKING_HEART_RATE": "bpm",
    "VO2_MAX": "ml/kg/min",
    "DISTANCE_SWIMMING": "m",
    "SWIM_STROKE_COUNT": "stroke",
    "WORKOUT_DURATION": "min",
    "DURATION": "min",
    "BODY_TEMPERATURE": "°C",
    "BLOOD_PRESSURE_SYSTOLIC": "mmHg",
    "BLOOD_PRESSURE_DIASTOLIC": "mmHg",
    "BLOOD_GLUCOSE": "mg/dL",
    "BLOOD_OXYGEN": "%",
    "RESPIRATORY_RATE": "breaths/min",
    "OXYGEN_SATURATION": "%",
    "HEADACHE_SEVERITY": "",
    "MOOD": "",
    "STRESS_LEVEL": "",
    "WATER": "L",
    "CAFFEINE": "mg",
    "ALCOHOL_CONSUMED": "g",
    "TOBACCO_SMOKED": "cig",
    "BODY_MASS": "kg",
    "HEIGHT": "m",
    "BEATS_PER_MINUTE": "bpm",
    "PERCENT": "%",
  };

  Map<String, dynamic> getHealthValue(
    String type, {
    int decimalsIfDouble = 2,
    bool convertMetersToKm = false,
  }) {
    if (healthData == null) return {"data": "--", "unit": ""};

    final raw = healthData![type];
    if (raw is! List || raw.isEmpty) return {"data": "--", "unit": ""};

    String _resolveUnit(List list) {
      final counts = <String, int>{};
      for (final e in list) {
        if (e is Map) {
          String? u;
          if (e['unit'] is String) {
            u = e['unit'] as String;
          }
          if (u != null && u.isNotEmpty) {
            counts[u] = (counts[u] ?? 0) + 1;
          }
        }
      }
      if (counts.isEmpty) return '';
      return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    final unitFromData = _resolveUnit(raw);

    num total = 0;

    for (final e in raw) {
      if (e is! Map) continue;

      final value = e['value'];
      if (value != null) {
        total += value.numericValue;
      }
    }

    String outUnit = simplifiedUnits[unitFromData] ?? unitFromData;
    if (convertMetersToKm && unitFromData == "METER") {
      total = total / 1000;
      outUnit = "km";
    }

    String formatted;
    if (total % 1 == 0) {
      formatted = total.toInt().toString();
    } else {
      formatted = total.toStringAsFixed(decimalsIfDouble);
    }

    return {"data": formatted, "unit": outUnit};
  }

  Map<String, Map<String, double>> getDWMPercentagesForStepsAndDistance() {
    Map<String, Map<String, double>> result = {
      "STEPS": {"daily": 0.0, "weekly": 0.0, "monthly": 0.0},
      "DISTANCE_DELTA": {"daily": 0.0, "weekly": 0.0, "monthly": 0.0},
    };

    double pct(num part, num whole) =>
        (whole == 0) ? 0.0 : (part / whole) * 100.0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final monthStart = todayStart.subtract(const Duration(days: 29));

    double sumForRange(String type, DateTime fromInclusive) {
      final list = healthData?[type];
      if (list is! List || list.isEmpty) return 0.0;

      double total = 0.0;
      for (final e in list) {
        if (e is! Map) continue;

        final dateStr = e['dateFrom'];
        if (dateStr is! String) continue;
        final dt = DateTime.tryParse(dateStr);
        if (dt == null || dt.isBefore(fromInclusive)) continue;

        final v = e['value'];
        double val = 0.0;
        if (v is Map && v['numericValue'] is num) {
          val = (v['numericValue'] as num).toDouble();
        } else {
          try {
            final n = (v as dynamic).numericValue;
            if (n is num) val = n.toDouble();
          } catch (_) {}
        }
        total += val;
      }
      return total;
    }

    Map<String, double> calcFor(String type) {
      final daily = sumForRange(type, todayStart);
      final weekly = sumForRange(type, weekStart);
      final monthly = sumForRange(type, monthStart);

      return {
        "daily": pct(daily, weekly),
        "weekly": pct(weekly, monthly),
        "monthly": monthly > 0 ? 100.0 : 0.0,
      };
    }

    result["STEPS"] = calcFor("HealthDataType.STEPS");
    result["DISTANCE_DELTA"] = calcFor("HealthDataType.DISTANCE_DELTA");

    return result;
  }

  var data;

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

  Map<String, dynamic>? nutritionData;
  List<dynamic> foods = [];

  Future<void> _fetchUser() async {
    try {
      final token = await secureStorage.read(key: 'token');
      final url = "${dotenv.env['BACKEND_URL']}/app/get";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstName = data["firstName"] ?? "";
          lastName = data["lastName"] ?? "";
          profilePhoto = data["profilePhoto"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user: $e");
      setState(() => isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final fallbackAvatar = "${dotenv.env['BACKEND_URL']}/BeFab.png";
    final avatarUrl =
        profilePhoto.isNotEmpty
            ? "${dotenv.env['BACKEND_URL']}/$profilePhoto"
            : fallbackAvatar;

    return Scaffold(
      drawer: CustomDrawer(
        userName: "$firstName $lastName",
        profileImage: avatarUrl,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF862633)),
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? "Loading..." : "Hi, $firstName $lastName",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getGreeting(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9C9B9D),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/images/bell.svg',
                  height: 24,
                  width: 24,
                  color: const Color(0xFF862633),
                ),
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
        ],
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    WeightLossProgressChart(),
                    const SizedBox(height: 16),
                    _buildActivityTrackerCard(context, (data)),
                    const SizedBox(height: 12),
                    Card(
                      color: const Color(0xFFF3F3F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8,
                            ),
                            child: Text(
                              'Goals Summary',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: _buildGoalRow(
                              "Goal Title",
                              "Description",
                              "30%",
                            ),
                          ),
                          const Divider(thickness: 0.5),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: _buildGoalRow(
                              "Goal Title",
                              "Description",
                              "50%",
                            ),
                          ),
                          const Divider(thickness: 0.5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8.0,
                                right: 8,
                              ),
                              child: const Text(
                                "view all",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildImageCard(
                          context,
                          "assets/images/mail.svg",
                          "E-Newsletters",
                          "",
                          "/all-newsletters",
                        ),
                        _buildImageCard(
                          context,
                          "assets/images/video2.svg",
                          "Videos",
                          "",
                          "/video-categories",
                        ),
                        _buildImageCard(
                          context,
                          "assets/images/sms.svg",
                          "SMS",
                          "",
                          "/message",
                        ),
                        _buildImageCard(
                          context,
                          "assets/images/groups2.svg",
                          "Group",
                          "",
                          "/groups",
                        ),
                        _buildImageCard(
                          context,
                          "assets/images/groups2.svg",
                          "Competitions",
                          "",
                          "/competitions-list",
                        ),
                        _buildImageCard(
                          context,
                          "assets/images/activities2.svg",
                          "Activities",
                          "",
                          "/nutrition",
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "More",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconBoxWithText(
                          context,
                          'assets/images/log.svg',
                          'Log Activity',
                          "/log",
                        ),
                        _buildIconBoxWithText(
                          context,
                          'assets/images/goal.svg',
                          'Set a Goal',
                          "/new-goal",
                        ),
                        _buildIconBoxWithText(
                          context,
                          'assets/images/competition2.svg',
                          'Join Competition',
                          "/competitions-list",
                        ),
                        _buildIconBoxWithText(
                          context,
                          'assets/images/resource.svg',
                          'Resource',
                          "/dashboard",
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}

// ----------------- UI Helpers -------------------

Widget _buildGoalRow(String title, String subtitle, String percent) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Text(
            percent,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
  );
}

Widget _buildIconBoxWithText(
  BuildContext context,
  String imagePath,
  String label,
  String route,
) {
  return GestureDetector(
    onTap: () {
      if (route.isNotEmpty) {
        Navigator.pushNamed(context, route); // ✅ navigate by route
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(imagePath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 36),
      ],
    ),
  );
}

Widget _buildImageCard(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
  String route,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        if (route.isNotEmpty) {
          Navigator.pushNamed(context, route); // ✅ use context here
        }
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              imagePath,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

// Widget _buildSegmentButton(String label, bool isSelected) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//     decoration: BoxDecoration(
//       color: isSelected ? const Color(0xFFD9D9D9) : const Color(0xFFF3F3F3),
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: Colors.grey),
//     ),
//     child: Text(
//       label,
//       style: TextStyle(
//         fontFamily: 'roboto',
//         color: isSelected ? const Color(0xFF1D1B20) : const Color(0xFF49454F),
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//   );
// }

Widget _buildActivityTrackerCard(BuildContext context, dynamic percentages) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      // Calculate percentages for each time period
      final daily = ((percentages?["STEPS"]?["daily"] ?? 0) +
              (percentages?["DISTANCE_DELTA"]?["daily"] ?? 0)) /
          2;

      final weekly = ((percentages?["STEPS"]?["weekly"] ?? 0) +
              (percentages?["DISTANCE_DELTA"]?["weekly"] ?? 0)) /
          2;

      final monthly = ((percentages?["STEPS"]?["monthly"] ?? 0) +
              (percentages?["DISTANCE_DELTA"]?["monthly"] ?? 0)) /
          2;

      // Initialize state variables
      String selectedPeriod = "Daily";
      num percentage = daily;
      double progress = daily / 100;

      // Function to handle period selection
      void selectPeriod(String period) {
        setState(() {
          selectedPeriod = period;
          if (period == "Daily") {
            percentage = daily;
          } else if (period == "Weekly") {
            percentage = weekly;
          } else if (period == "Monthly") {
            percentage = monthly;
          }
          progress = percentage / 100;
        });
      }

      return Card(
        color: const Color(0xFFF3F3F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Physical activity tracker',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_up),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildSegmentButton(
                    "Daily", 
                    selectedPeriod == "Daily", 
                    onTap: () => selectPeriod("Daily")
                  ),
                  const SizedBox(width: 12),
                  _buildSegmentButton(
                    "Weekly", 
                    selectedPeriod == "Weekly", 
                    onTap: () => selectPeriod("Weekly")
                  ),
                  const SizedBox(width: 12),
                  _buildSegmentButton(
                    "Monthly", 
                    selectedPeriod == "Monthly", 
                    onTap: () => selectPeriod("Monthly")
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF862633),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "0%",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF4E4E4E),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "100%",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF4E4E4E),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: progress * MediaQuery.of(context).size.width * 0.72,
                        child: Text(
                          "${(percentage).round()}%",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4E4E4E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "view details",
                  style: TextStyle(fontSize: 11, color: Color(0xFF862633)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildSegmentButton(String text, bool isSelected, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF862633) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF862633),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF862633),
          fontSize: 12,
        ),
      ),
    ),
  );
}