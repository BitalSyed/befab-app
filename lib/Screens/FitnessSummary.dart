// dashboard_screen.dart
import 'package:befab/charts/WeeklyActivityChart.dart';
import 'package:befab/components/CustomAppHeader.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/ImageTextGridCard.dart';
import 'package:befab/components/MiniStatCard.dart';
import 'package:befab/components/VitalsCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../services/health_service.dart'; // Make sure to import your HealthService class
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class FitnessSummary extends StatefulWidget {
  const FitnessSummary({super.key});

  @override
  _FitnessSummaryState createState() => _FitnessSummaryState();
}

class _FitnessSummaryState extends State<FitnessSummary> {
  final HealthService healthService = HealthService();
  Map<String, dynamic>? healthData;

  @override
  void initState() {
    super.initState();

    // 👇 FIX: Only run after widget tree is built
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

  // Helper to get a single value safely from healthData
  /// Sums all entries in `healthData[type]` and returns "total unit"
  /// Works with entries shaped like:
  /// { "value": {"numericValue": 10}, "unit": "COUNT", ... }
  // --- Simplified units map ---
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
  static final String _baseUrl = dotenv.env['BACKEND_URL'] ?? "";

  // Function to send JSON data
  static Future<void> sendData(Map<String, dynamic> data) async {
    final url = Uri.parse("$_baseUrl/data");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("✅ Success: ${response.body}");
      } else {
        print("❌ Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚡ Error sending request: $e");
    }
  }

  List<num> mapWeeklyData(List raw) {
    final today = DateTime.now();
    final Map<DateTime, num> dailyTotals = {};

    // Initialize last 7 days with 0
    for (int i = 0; i < 7; i++) {
      final day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - i));
      dailyTotals[day] = 0;
    }

    for (final e in raw) {
      if (e is! Map) continue;
      final value = e['value'];
      if (value == null || value['numericValue'] == null) continue;
      final numVal = value['numericValue'] as num;

      DateTime? dateFrom;
      if (e['dateFrom'] is String) {
        dateFrom = DateTime.tryParse(e['dateFrom']);
      } else if (e['dateFrom'] is int) {
        dateFrom = DateTime.fromMillisecondsSinceEpoch(e['dateFrom']);
      }
      if (dateFrom == null) continue;

      // Normalize to midnight
      final dayKey = DateTime(dateFrom.year, dateFrom.month, dateFrom.day);

      if (dailyTotals.containsKey(dayKey)) {
        dailyTotals[dayKey] = dailyTotals[dayKey]! + numVal;
      }
    }

    return dailyTotals.values.toList();
  }

  // Getters for chart
  List<num> get weeklySteps => mapWeeklyData(healthData?['STEPS'] ?? []);
  List<num> get weeklyCalories =>
      mapWeeklyData(healthData?['TOTAL_CALORIES_BURNED'] ?? []);

  List<num> padWeeklyData(List<num> data) {
    final result = List<num>.filled(7, 0); // default 0 for missing days
    for (int i = 0; i < data.length && i < 7; i++) {
      result[i] = data[i];
    }
    return result;
  }

  /// Returns sleep quality as a percentage (0-100)
  int getSleepQuality() {
    final sleepData = healthData?['SLEEP_SESSION'] as List? ?? [];
    if (sleepData.isEmpty) return 0;

    int totalAsleep = 0;
    int totalInBed = 0;

    for (final entry in sleepData) {
      if (entry is! Map) continue;

      final start = DateTime.tryParse(entry['dateFrom'] ?? '');
      final end = DateTime.tryParse(entry['dateTo'] ?? '');
      if (start == null || end == null) continue;

      final duration = end.difference(start).inMinutes;
      totalInBed += duration;

      // Count only "asleep" states
      if ((entry['value'] ?? '') == 'asleep' ||
          entry['value'] == 'SLEEP_ASLEEP') {
        totalAsleep += duration;
      }
    }

    if (totalInBed == 0) return 0;

    return ((totalAsleep / totalInBed) * 100).round();
  }

  /// Converts sleep quality percentage to a readable term
  String getSleepQualityTerm() {
    final quality = getSleepQuality(); // from previous function

    if (quality >= 85) return 'Excellent';
    if (quality >= 70) return 'Good';
    if (quality >= 50) return 'Fair';
    return 'Poor';
  }

  num calculateMobilityScore() {
    // --- Activity ---
    num steps =
        num.tryParse(
          getHealthValue('HealthDataType.STEPS')['data']?.toString() ?? '0',
        ) ??
        0;
    num distance =
        (num.tryParse(
              getHealthValue(
                    'HealthDataType.DISTANCE_DELTA',
                  )['data']?.toString() ??
                  '0',
            ) ??
            0) +
        (num.tryParse(
              getHealthValue(
                    'HealthDataType.DISTANCE_CYCLING',
                  )['data']?.toString() ??
                  '0',
            ) ??
            0);
    num activeCalories =
        num.tryParse(
          getHealthValue(
                'HealthDataType.ACTIVE_ENERGY_BURNED',
              )['data']?.toString() ??
              '0',
        ) ??
        0;
    num workouts =
        num.tryParse(
          getHealthValue('HealthDataType.WORKOUT')['data']?.toString() ?? '0',
        ) ??
        0;

    num restingHR =
        num.tryParse(
          getHealthValue(
                'HealthDataType.RESTING_HEART_RATE',
              )['data']?.toString() ??
              '70',
        ) ??
        70;
    num hrv =
        num.tryParse(
          getHealthValue(
                'HealthDataType.HEART_RATE_VARIABILITY_RMSSD',
              )['data']?.toString() ??
              '30',
        ) ??
        30;
    num spo2 =
        num.tryParse(
          getHealthValue('HealthDataType.BLOOD_OXYGEN')['data']?.toString() ??
              '95',
        ) ??
        95;

    num bmi =
        num.tryParse(
          getHealthValue(
                'HealthDataType.BODY_MASS_INDEX',
              )['data']?.toString() ??
              '25',
        ) ??
        25;
    num bodyFat =
        num.tryParse(
          getHealthValue(
                'HealthDataType.BODY_FAT_PERCENTAGE',
              )['data']?.toString() ??
              '20',
        ) ??
        20;
    num leanMass =
        num.tryParse(
          getHealthValue('HealthDataType.LEAN_BODY_MASS')['data']?.toString() ??
              '50',
        ) ??
        50;

    num sleepTotal =
        num.tryParse(
          getHealthValue('HealthDataType.SLEEP_SESSION')['data']?.toString() ??
              '0',
        ) ??
        0;
    num sleepDeep =
        num.tryParse(
          getHealthValue('HealthDataType.SLEEP_DEEP')['data']?.toString() ??
              '0',
        ) ??
        0;
    num sleepREM =
        num.tryParse(
          getHealthValue('HealthDataType.SLEEP_REM')['data']?.toString() ?? '0',
        ) ??
        0;

    num sleepQuality =
        sleepTotal > 0 ? ((sleepDeep + sleepREM) / sleepTotal) : 0;

    // --- Normalize into 0–1 ranges ---
    num activityScore =
        (steps / 10000).clamp(0, 1) * 0.4 +
        (distance / 5000).clamp(0, 1) * 0.3 +
        (activeCalories / 500).clamp(0, 1) * 0.2 +
        (workouts / 2).clamp(0, 1) * 0.1;

    num cardioScore =
        (1 - ((restingHR - 60) / 40).clamp(0, 1)) * 0.4 +
        (hrv / 100).clamp(0, 1) * 0.3 +
        ((spo2 - 90) / 10).clamp(0, 1) * 0.3;

    num bodyScore =
        (1 - ((bmi - 22).abs() / 10).clamp(0, 1)) * 0.4 +
        (1 - (bodyFat / 40).clamp(0, 1)) * 0.3 +
        (leanMass / 70).clamp(0, 1) * 0.3;

    num sleepScore = sleepQuality.clamp(0, 1);

    // --- Weighted sum ---
    num mobilityScore =
        (activityScore * 0.4) +
        (cardioScore * 0.3) +
        (bodyScore * 0.2) +
        (sleepScore * 0.1);

    return (mobilityScore * 100).clamp(0, 100).round(); // return 0–100
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leftWidget: Row(
          children: [
            SvgPicture.asset('assets/images/Arrow.svg', width: 14, height: 14),
            const SizedBox(width: 4),
            // const CircleAvatar(
            //   radius: 20,
            //   backgroundImage: AssetImage('assets/images/profile.jpg'),
            // ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              // children: const [
              //   Text(
              //     'Hi, John',
              //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              //   ),
              //   Text(
              //     'Good Evening',
              //     style: TextStyle(fontSize: 13, color: Colors.grey),
              //   ),
              // ],
            ),
          ],
        ),
        onLeftTap: () => Navigator.pop(context),
        // rightWidget: SvgPicture.asset("assets/images/settings2.svg"),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Todays Summary",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // child: Text(
                  //   "See All",
                  //   style: GoogleFonts.inter(
                  //     color: const Color(0xFF862633),
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                ),
              ],
            ),
            MiniStatsGrid(
              stats: {
                'h': getHealthValue('HealthDataType.HEART_RATE'),
                's': getHealthValue('HealthDataType.STEPS'),
                'calories': getHealthValue(
                  'HealthDataType.TOTAL_CALORIES_BURNED',
                ),
                'sleep': getHealthValue('HealthDataType.SLEEP_SESSION'),
              },
            ),

            WeeklyActivityChart(
              title: 'Weekly Activity',
              stepsData:
                  padWeeklyData(weeklySteps).map((e) => e.toInt()).toList(),
              caloriesData:
                  padWeeklyData(weeklyCalories).map((e) => e.toInt()).toList(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Health Categories",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            VitalsCard(
              icon: "assets/images/vital.svg",
              iconBgColor: const Color.fromRGBO(22, 163, 74, 0.2),
              iconColor: const Color(0xFF16A34A),
              heading: 'Vitals',
              vitals: [
                {
                  'label': 'Sleep',
                  'value':
                      "${getHealthValue('HealthDataType.SLEEP_SESSION')['data']} ${getHealthValue('HealthDataType.SLEEP_SESSION')['unit']}",
                },
                {
                  'label': 'Distance',
                  'value':
                      "${getHealthValue('HealthDataType.DISTANCE_DELTA')['data']} ${getHealthValue('HealthDataType.DISTANCE_DELTA')['unit'] == 'METER' ? 'm' : getHealthValue('HealthDataType.DISTANCE_DELTA')['unit']}",
                },
                {
                  'label': 'Active Calories',
                  'value':
                      "${getHealthValue('HealthDataType.ACTIVE_ENERGY_BURNED')['data']} ${getHealthValue('HealthDataType.ACTIVE_ENERGY_BURNED')['unit']}",
                },
                {
                  'label': 'Activity Minutes',
                  'value': getHealthValue('HealthDataType.WORKOUT')['data'],
                },
              ],
            ),

            VitalsCard(
              icon: "assets/images/heartbeat.svg",
              iconBgColor: const Color.fromRGBO(221, 37, 37, 0.2),
              iconColor: const Color(0xFFDD2525),
              heading: 'Vitals',
              vitals: [
                {
                  'label': 'Heart Rate',
                  'value':
                      "${getHealthValue('HealthDataType.HEART_RATE')['data']} ${getHealthValue('HealthDataType.HEART_RATE')['unit']}",
                },
                {
                  'label': 'Blood Pressure',
                  'value':
                      "${getHealthValue('HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['data']}/${getHealthValue('HealthDataType.BLOOD_PRESSURE_DIASTOLIC')['data']} ${getHealthValue('HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['unit'] != 'MILLIMETER_OF_MERCURY' ? getHealthValue('HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['unit'] : 'mmHg'}",
                },
                {
                  'label': 'Oxygen (SpO2)',
                  'value':
                      "${getHealthValue('HealthDataType.BLOOD_OXYGEN')['data']} ${getHealthValue('HealthDataType.BLOOD_OXYGEN')['unit']}",
                },
                {
                  'label': 'Respiratory Rate',
                  'value':
                      "${getHealthValue('HealthDataType.RESPIRATORY_RATE')['data']} ${getHealthValue('HealthDataType.RESPIRATORY_RATE')['unit']}",
                },
              ],
            ),

            VitalsCard(
              icon: "assets/images/body.svg",
              iconBgColor: const Color.fromRGBO(37, 99, 235, 0.2),
              iconColor: const Color(0xFF0074C4),
              heading: 'Body Composition',
              vitals: [
                {
                  'label': 'Weight',
                  'value':
                      "${getHealthValue('HealthDataType.WEIGHT')['data']} ${getHealthValue('HealthDataType.WEIGHT')['unit']}",
                },
                {
                  'label': 'BMI',
                  'value':
                      "${getHealthValue('HealthDataType.BODY_MASS_INDEX')['data']}",
                },
                {
                  'label': 'Body Fat',
                  'value':
                      "${getHealthValue('HealthDataType.BODY_FAT_PERCENTAGE')['data']} ${getHealthValue('HealthDataType.BODY_FAT_PERCENTAGE')['unit']}",
                },
                {
                  'label': 'Lean Mass',
                  'value':
                      "${getHealthValue('HealthDataType.LEAN_BODY_MASS')['data']} ${getHealthValue('HealthDataType.LEAN_BODY_MASS')['unit']}",
                },
              ],
            ),

            VitalsCard(
              icon: "assets/images/moon.svg",
              iconBgColor: const Color.fromRGBO(147, 51, 234, 0.2),
              iconColor: const Color(0xFF9333EA),
              heading: 'Sleep',
              vitals: [
                {
                  'label': 'Duration',
                  'value':
                      "${getHealthValue('HealthDataType.SLEEP_SESSION')['data']} ${getHealthValue('HealthDataType.SLEEP_SESSION')['unit']}",
                },
                {
                  'label': 'Deep Sleep',
                  'value':
                      "${getHealthValue('HealthDataType.SLEEP_DEEP')['data']} ${getHealthValue('HealthDataType.SLEEP_DEEP')['unit']}",
                },
                {
                  'label': 'REM Sleep',
                  'value':
                      "${getHealthValue('HealthDataType.SLEEP_REM')['data']} ${getHealthValue('HealthDataType.SLEEP_REM')['unit']}",
                },
                {'label': 'Sleep Quality', 'value': getSleepQualityTerm()},
              ],
            ),

            ImageTextGridItemCards(
              items: [
                {
                  'image': SvgPicture.asset(
                    'assets/images/cycle.svg',
                    color: const Color(0xFF9333EA),
                  ),
                  'text': 'Cycle Tracking',
                  'a':
                      "${getHealthValue('HealthDataType.DISTANCE_CYCLING')['data']} ${getHealthValue('HealthDataType.DISTANCE_CYCLING')['unit']}",
                  'imageBgColor': const Color.fromRGBO(147, 51, 234, 0.2),
                },
                {
                  'image': SvgPicture.asset('assets/images/run2.svg'),
                  'text': 'Mobility',
                  'a': "${calculateMobilityScore()}",
                  'imageBgColor': const Color.fromRGBO(22, 163, 74, 0.2),
                },
                // {
                //   'image': SvgPicture.asset('assets/images/heart3.svg'),
                //   'text': 'Health Records',
                //   'a':
                //       "${getHealthValue('HealthDataType.SLEEP_SESSION')['data']} ${getHealthValue('HealthDataType.SLEEP_SESSION')['unit']}",
                //   'imageBgColor': const Color.fromRGBO(249, 115, 22, 0.2),
                // },
                // {
                //   'image': SvgPicture.asset('assets/images/option.svg'),
                //   'text': 'Cycle Tracking',
                //   'a':
                //       "${getHealthValue('HealthDataType.SLEEP_SESSION')['data']} ${getHealthValue('HealthDataType.SLEEP_SESSION')['unit']}",
                //   'imageBgColor': Colors.white,
                // },
              ],
            ),
            const SizedBox(height: 24),
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
