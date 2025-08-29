import 'package:befab/charts/ActivityTrackerWidget.dart';
import 'package:befab/charts/WeeklyActivityChart2.dart';
import 'package:befab/components/ActivityCard.dart';
import 'package:befab/components/ActivityMetric.dart';
import 'package:befab/components/ActivityStatCard.dart';
import 'package:befab/components/CustomAppHeader.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/services/health_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ActivityFitness extends StatefulWidget {
  @override
  _ActivityFitnessState createState() => _ActivityFitnessState();
}

class _ActivityFitnessState extends State<ActivityFitness> {
  final HealthService healthService = HealthService();
  Map<String, dynamic>? healthData;

  @override
  void initState() {
    super.initState();

    // 👇 FIX: Only run after widget tree is built
    loadGoals();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHealthData();
    });
  }

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
    debugPrint(
      "✅ Fetched health data: ${getHealthValue('HealthDataType.STEPS')}",
    );
  }

  Map<String, String> simplifiedUnits = {
    // Distance
    "METER": "m",
    "KILOMETER": "km",
    "MILE": "mi",
    "YARD": "yd",
    "FOOT": "ft",

    // Weight
    "GRAM": "g",
    "KILOGRAM": "kg",
    "OUNCE": "oz",
    "POUND": "lb",

    // Pressure
    "MILLIMETER_OF_MERCURY": "mmHg",
    "INCH_OF_MERCURY": "inHg",
    "PASCAL": "Pa",
    "KILOPASCAL": "kPa",

    // Temperature
    "CELSIUS": "°C",
    "FAHRENHEIT": "°F",
    "KELVIN": "K",

    // Energy
    "CALORIE": "kcal",
    "KILOJOULE": "kJ",

    // Time
    "SECOND": "s",
    "MINUTE": "min",
    "HOUR": "h",
    "DAY": "d",

    // Volume / Liquids
    "LITER": "L",
    "MILLILITER": "mL",
    "FLUID_OUNCE_US": "fl oz",

    // Counts / Steps
    "COUNT": "",
    "BEAT": "beat",
    "BEAT_PER_MINUTE": "bpm",
    "REP": "rep",

    // Percentages
    "PERCENTAGE": "%",

    // Sleep / activity types
    "SLEEP_ASLEEP": "sleep",
    "SLEEP_IN_BED": "in bed",
    "SLEEP_AWAKE": "awake",

    // Other HealthKit / Health Connect types
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

  // --- Your function remains unchanged except mapping unit at the end ---
 Map<String, dynamic> getHealthValue(
  String type, {
  int decimalsIfDouble = 2,
  bool convertMetersToKm = false,
}) {
  if (healthData == null) return {"data": "--", "unit": ""};

  final raw = healthData![type];
  if (raw is! List || raw.isEmpty) return {"data": "--", "unit": ""};

  // Get today's date in YYYY-MM-DD format
  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- pick the most common unit present in the list ---
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

  // --- sum numeric values for TODAY only ---
  num total = 0;

  for (final e in raw) {
    if (e is! Map) continue;

    // Check if the entry is from today
    final dateFrom = e['dateFrom'];
    if (dateFrom is! String || !dateFrom.contains(today)) {
      continue; // Skip entries not from today
    }

    final value = e['value'];
    if (value != null && value is Map) {
      final numericValue = value['numericValue'];
      if (numericValue is num) {
        total += numericValue;
      }
    }
  }

  // optional unit conversion
  String outUnit = simplifiedUnits[unitFromData] ?? unitFromData;
  if (convertMetersToKm && unitFromData == "METER") {
    total = total / 1000;
    outUnit = "km";
  }

  // format nicely
  String formatted;
  if (total % 1 == 0) {
    formatted = total.toInt().toString();
  } else {
    formatted = total.toStringAsFixed(decimalsIfDouble);
  }

  return {"data": formatted, "unit": outUnit};
}
  final storage = FlutterSecureStorage();

  Future<void> fetchGoal() async {
    final String? baseUrl = dotenv.env['BACKEND_URL'];
    if (baseUrl == null) {
      throw Exception("BACKEND_URL not set in .env");
    }

    // Get token from secure storage
    final String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception("Token not found in secure storage");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/app/goals/current?q=Steps"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      // Parse JSON as Map
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Wrap in a list if you want a list
      userGoals = [data];
    } else {
      throw Exception("Failed to fetch goal: ${response.body}");
    }
  }

  // Declare userGoals as a list
  List<Map<String, dynamic>> userGoals = [];

  void loadGoals() async {
    try {
      await fetchGoal();
      print("goals: $userGoals");
    } catch (e) {
      print("Error fetching goals: $e");
    }
  }

  final now = DateTime.now();

  final List<ActivityMetric> sampleMetrics = [
    ActivityMetric(
      image: "assets/images/cycle.svg",
      iconBackgroundColor: const Color.fromRGBO(0, 184, 68, 0.2),
      iconColor: const Color(0xFF00B844),
      title: 'Cycling',
      subtitle: 'Distance',
      value: '5.2',
      unit: 'km',
      description: 'Weekly Total',
    ),
    ActivityMetric(
      image: "assets/images/ic4.svg",
      iconBackgroundColor: const Color.fromRGBO(255, 149, 0, 0.2),
      iconColor: const Color(0xFFFF9500),
      title: 'Wheelchair',
      subtitle: 'Pushes',
      value: 'N/A',
      unit: '',
      description: 'Not Tracked',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leftWidget: Row(
          children: [
            SvgPicture.asset('assets/images/Arrow.svg', width: 14, height: 14),
            SizedBox(width: 4),
            Text(
              "Back",
              style: TextStyle(
                color: Color(0xFF862633),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        onLeftTap: () => Navigator.pop(context),
        title: "Activity Fitness",
        // rightWidget: Icon(Icons.more_vert, color: Colors.black),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            ActivityTrackerWidget(
              title: "Goal's Activity",
              date: ("${now.month}-${now.day}-${now.year}"),
              currentValue:
                  userGoals.isNotEmpty ? userGoals[0]['progressValue'] ?? 0 : 0,
              unit: "Steps",
              goalValue:
                  userGoals.isNotEmpty ? userGoals[0]['milestones'] ?? 0 : 0,
              progressPercentage:
                  userGoals.isNotEmpty && userGoals[0]['milestones'] != 0
                      ? ((userGoals[0]['progressValue'] ?? 0) /
                          (userGoals[0]['milestones'] ?? 1) *
                          100)
                      : 0,
              averageValue:
                  userGoals.isNotEmpty
                      ? ((userGoals[0]['milestones'] ?? 0) -
                          (userGoals[0]['progressValue'] ?? 0))
                      : 0,
              progressColor: const Color(0xFF8B4B5C),
              backgroundColor: const Color(0xFFE5E5E5),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/ic1.svg",
                      imageColor: Color(0xFF862633),
                      imageBackgroundColor: Color.fromRGBO(134, 38, 51, 0.2),
                      title: "Distance",
                      value: getHealthValue('HealthDataType.DISTANCE_DELTA')['data'],
                      unit: getHealthValue('HealthDataType.DISTANCE_DELTA')['unit'],
                      goalLabel: "",
                      progress: 5.2 / 8.0,
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/ic2.svg",
                      imageColor: Color(0xFF2563EB),
                      imageBackgroundColor: Color.fromRGBO(37, 99, 235, 0.2),
                      title: "Steps",
                      value: getHealthValue('HealthDataType.STEPS')['data'],
                      unit: "",
                      goalLabel: "",
                      progress: 12 / 15,
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/fire.svg",
                      imageColor: Color(0xFF16A34A),
                      imageBackgroundColor: Color.fromRGBO(22, 163, 74, 0.2),
                      title: "BMI",
                      value: getHealthValue('HealthDataType.BODY_MASS_INDEX')['data'],
                      unit: "",
                      goalLabel: "",
                      progress: 5.2 / 8.0,
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/ic3.svg",
                      imageColor: Color(0xFF9333EA),
                      imageBackgroundColor: Color.fromRGBO(147, 51, 234, 0.2),
                      title: "Body Fat",
                      value: getHealthValue('HealthDataType.BODY_FAT_PERCENTAGE')['data'],
                      unit: getHealthValue('HealthDataType.BODY_FAT_PERCENTAGE')['unit'],
                      goalLabel: "",
                      progress: 12 / 15,
                    ),
                  ),
                ],
              ),
            ),
            // WeeklyActivityChart2(
            //   title: 'Activity Minutes',
            //   stepsData: [8500, 9200, 7800, 10200, 9800, 8900, 9500],
            //   caloriesData: [320, 380, 290, 420, 390, 350, 370],
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "Recent Workout",
            //         style: GoogleFonts.inter(
            //           color: Color(0xFF000000),
            //           fontSize: 20,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "See All",
            //         style: GoogleFonts.inter(
            //           color: Color(0xFF862633),
            //           fontSize: 16,
            //           fontWeight: FontWeight.w400,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // ActivityCard(
            //   image: "assets/images/activities3.svg",
            //   iconColor: Color(0xFF0074C4),
            //   iconBackgroundColor: Color.fromRGBO(0, 116, 196, 0.2),
            //   title: 'Morning Run',
            //   subtitle: 'Today 7:30 AM',
            //   metric1Label: 'Distance',
            //   metric1Value: '3.2 km',
            //   metric2Label: 'Duration',
            //   metric2Value: '28 min',
            //   metric3Label: 'Calories',
            //   metric3Value: '234 kcal',
            //   isTrue: false,
            // ),
            // ActivityCard(
            //   image: "assets/images/cyclist.svg",
            //   iconColor: Color(0xFF862633),
            //   iconBackgroundColor: Color.fromRGBO(134, 38, 51, 0.2),
            //   title: 'Cycling',
            //   subtitle: 'Yesterday 6:15 PM',
            //   metric1Label: 'Distance',
            //   metric1Value: '13.2 km',
            //   metric2Label: 'Duration',
            //   metric2Value: '45 min',
            //   metric3Label: 'Calories',
            //   metric3Value: '320 kcal',
            //   isTrue: false,
            // ),
            // ActivityCard(
            //   image: "assets/images/dumbell.svg",
            //   iconColor: Color(0xFFFF1919),
            //   iconBackgroundColor: Color.fromRGBO(255, 25, 25, 0.2),
            //   title: 'Strength Training',
            //   subtitle: 'May  8:00 PM',
            //   metric1Label: 'Set',
            //   metric1Value: '5 Sets',
            //   metric2Label: 'Duration',
            //   metric2Value: '25 min',
            //   metric3Label: 'Calories',
            //   metric3Value: '156 kcal',
            //   isTrue: true,
            // ),
            // ActivityMetricsWidget(
            //   title: 'Other Activity Metrics',
            //   metrics: sampleMetrics,
            // ),
            SizedBox(height: 24),
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
