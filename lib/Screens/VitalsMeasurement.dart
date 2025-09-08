import 'dart:convert';

import 'package:befab/charts/BloodPressureWidget.dart';
import 'package:befab/components/ActivityStatCard.dart';
import 'package:befab/components/BodyMetricsWidget.dart';
import 'package:befab/components/CustomAppHeader.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/HealthMetricsListWidget.dart';
import 'package:befab/components/HeartRateWidget.dart';
import 'package:befab/services/health_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VitalsMeasurement extends StatefulWidget {
  @override
  _VitalsMeasurementState createState() => _VitalsMeasurementState();
}

class _VitalsMeasurementState extends State<VitalsMeasurement> {
  final HealthService healthService = HealthService();
  Map<String, dynamic>? healthData;

  @override
  void initState() {
    super.initState();
    getData();
    // 👇 FIX: Only run after widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHealthData();
    });
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

  Map<String, dynamic>? nutritionData;
  List<dynamic> foods = [];

  int totalCaloriesBreakfast = 0;
  int totalCaloriesLunch = 0;
  int totalCaloriesDinner = 0;
  int totalCaloriesSnacks = 0;
  int totalCaloriesOther = 0;
  int totalP = 0;
  int totalF = 0;
  int totalC = 0;
  int totalCaloriesAll = 0;
  double totalWaterLiters = 0.0;

  /// Call this with your nutritionData to update all totals
  void updateNutritionTotals(Map<String, dynamic> nutritionData) {
    if (nutritionData.isEmpty) return;

    final meals = nutritionData['meals'] as Map<String, dynamic>? ?? {};
    final waterIntakeOz = nutritionData['waterIntake_oz'] ?? 0;

    int sumCalories(List<dynamic> items) {
      return items.fold(0, (sum, item) {
        final qty = (item['quantity'] ?? 1) as num;
        final cal = (item['calories'] ?? 0) as num;
        return sum + (cal * qty).toInt();
      });
    }

    int sumP(List<dynamic> items) {
      return items.fold(0, (sum, item) {
        final qty = (item['quantity'] ?? 1) as num;
        final val = item['protein_g'];
        final p =
            (val is num
                ? val.toDouble()
                : double.tryParse(val?.toString() ?? "0") ?? 0);
        return sum + (p * qty).toInt();
      });
    }

    int sumF(List<dynamic> items) {
      return items.fold(0, (sum, item) {
        final qty = (item['quantity'] ?? 1) as num;
        final val = item['fat_g'];
        final f =
            (val is num
                ? val.toDouble()
                : double.tryParse(val?.toString() ?? "0") ?? 0);
        return sum + (f * qty).toInt();
      });
    }

    int sumC(List<dynamic> items) {
      return items.fold(0, (sum, item) {
        final qty = (item['quantity'] ?? 1) as num;
        final val = item['carbs_g'];
        final c =
            (val is num
                ? val.toDouble()
                : double.tryParse(val?.toString() ?? "0") ?? 0);
        return sum + (c * qty).toInt();
      });
    }

    totalCaloriesBreakfast = sumCalories(meals['breakfast'] ?? []);
    totalCaloriesLunch = sumCalories(meals['lunch'] ?? []);
    totalCaloriesDinner = sumCalories(meals['dinner'] ?? []);
    totalCaloriesSnacks = sumCalories(meals['snacks'] ?? []);
    totalCaloriesOther = sumCalories(meals['other'] ?? []);
    totalCaloriesAll =
        totalCaloriesBreakfast +
        totalCaloriesLunch +
        totalCaloriesDinner +
        totalCaloriesSnacks +
        totalCaloriesOther;

    totalF =
        sumF(meals['breakfast'] ?? []) +
        sumF(meals['lunch'] ?? []) +
        sumF(meals['dinner'] ?? []) +
        sumF(meals['snacks'] ?? []);
    totalP =
        sumP(meals['breakfast'] ?? []) +
        sumP(meals['lunch'] ?? []) +
        sumP(meals['dinner'] ?? []) +
        sumP(meals['snacks'] ?? []);
    totalC =
        sumC(meals['breakfast'] ?? []) +
        sumC(meals['lunch'] ?? []) +
        sumC(meals['dinner'] ?? []) +
        sumC(meals['snacks'] ?? []);

    totalWaterLiters = waterIntakeOz.toDouble();

    setState(() {});

    // print('🍳 Breakfast: $totalCaloriesBreakfast');
    // print('🥪 Lunch: $totalCaloriesLunch');
    // print('🍽 Dinner: $totalCaloriesDinner');
    // print('🍿 Snacks: $totalCaloriesSnacks');
    // print('⚡ Total Calories: $totalCaloriesAll');
    // print('💧 Water: ${totalWaterLiters.toStringAsFixed(2)} L');
  }

  void getData() async {
    final data = await fetchNutritionData();
    if (data != null) {
      setState(() {
        // <-- REBUILD UI
        nutritionData = data; // update class-level variable
        updateNutritionTotals(nutritionData!);
        print("data_nutrition: $nutritionData");
      });
    }
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
    "DEGREE_CELSIUS": "C",
    "RESPIRATIONS_PER_MINUTE": "resp/min",
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

    // --- sum numeric values ---
    num total = 0;

    for (final e in raw) {
      if (e is! Map) continue;

      final value = e['value'];
      if (value != null) {
        total += value.numericValue;
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

  Map<String, dynamic> getHealthValue1(
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

    // --- collect all valid entries with their date ---
    List<Map<String, dynamic>> validEntries = [];
    for (final e in raw) {
      if (e is! Map) continue;

      final dateFrom = e['dateFrom'];
      final value = e['value'];

      num? numericValue;
      if (value is NumericHealthValue) {
        numericValue = value.numericValue;
      } else if (value is Map) {
        numericValue = value['numericValue'] as num?;
      }

      if (dateFrom is String && numericValue != null) {
        validEntries.add({"date": dateFrom, "value": numericValue});
      }
    }

    if (validEntries.isEmpty) return {"data": "--", "unit": unitFromData};

    // --- Prefer today, else pick most recent entry ---
    List<Map<String, dynamic>> todayEntries =
        validEntries.where((e) => e["date"].contains(today)).toList();

    List<Map<String, dynamic>> chosenEntries;
    if (todayEntries.isNotEmpty) {
      chosenEntries = todayEntries;
    } else {
      // sort by date descending to get last logged
      validEntries.sort(
        (a, b) => (b["date"] as String).compareTo(a["date"] as String),
      );
      final lastDate = validEntries.first["date"];
      chosenEntries = validEntries.where((e) => e["date"] == lastDate).toList();
    }

    // --- sum values for chosen date ---
    num total = 0;
    for (final e in chosenEntries) {
      total += e["value"] as num;
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

  // Helper method to get heart rate data for the chart
  List<HeartRateData> _getHeartRateChartData() {
    if (healthData == null ||
        healthData!['HealthDataType.HEART_RATE'] == null) {
      return [HeartRateData(time: '6AM', value: 0)];
    }

    final heartRateData = healthData!['HealthDataType.HEART_RATE'] as List;
    if (heartRateData.isEmpty) {
      return [HeartRateData(time: '6AM', value: 0)];
    }

    // Get the latest 7 readings for the chart
    final recentReadings =
        heartRateData.length > 7
            ? heartRateData.sublist(heartRateData.length - 7)
            : heartRateData;

    List<HeartRateData> chartData = [];
    List<String> timeLabels = [
      '6AM',
      '9AM',
      '12PM',
      '3PM',
      '6PM',
      '9PM',
      '10PM',
    ];

    for (int i = 0; i < recentReadings.length; i++) {
      if (i < timeLabels.length) {
        final reading = recentReadings[i];
        if (reading is Map && reading['value'] != null) {
          chartData.add(
            HeartRateData(
              time: timeLabels[i],
              value: reading['value'].numericValue.toDouble(),
            ),
          );
        }
      }
    }

    return chartData;
  }

  // Helper method to get blood pressure data for the chart
  List<BloodPressureData> _getBloodPressureChartData() {
    if (healthData == null ||
        healthData!['HealthDataType.BLOOD_PRESSURE_SYSTOLIC'] == null ||
        healthData!['HealthDataType.BLOOD_PRESSURE_DIASTOLIC'] == null) {
      return [BloodPressureData(day: 'Mon', systolic: 0, diastolic: 0)];
    }

    final systolicData =
        healthData!['HealthDataType.BLOOD_PRESSURE_SYSTOLIC'] as List;
    final diastolicData =
        healthData!['HealthDataType.BLOOD_PRESSURE_DIASTOLIC'] as List;

    if (systolicData.isEmpty || diastolicData.isEmpty) {
      return [BloodPressureData(day: 'Mon', systolic: 0, diastolic: 0)];
    }

    // Get the latest 7 readings for the chart
    final recentSystolic =
        systolicData.length > 7
            ? systolicData.sublist(systolicData.length - 7)
            : systolicData;

    final recentDiastolic =
        diastolicData.length > 7
            ? diastolicData.sublist(diastolicData.length - 7)
            : diastolicData;

    List<BloodPressureData> chartData = [];
    List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < recentSystolic.length; i++) {
      if (i < dayLabels.length && i < recentDiastolic.length) {
        final systolicReading = recentSystolic[i];
        final diastolicReading = recentDiastolic[i];

        if (systolicReading is Map &&
            systolicReading['value'] != null &&
            diastolicReading is Map &&
            diastolicReading['value'] != null) {
          chartData.add(
            BloodPressureData(
              day: dayLabels[i],
              systolic: systolicReading['value'].numericValue.toDouble(),
              diastolic: diastolicReading['value'].numericValue.toDouble(),
            ),
          );
        }
      }
    }

    return chartData;
  }

  // Helper method to calculate heart rate statistics
  Map<String, dynamic> _getHeartRateStats() {
    if (healthData == null ||
        healthData!['HealthDataType.HEART_RATE'] == null) {
      return {
        'current': 0,
        'min': 0,
        'avg': 0,
        'max': 0,
        'resting': 0,
        'variability': 0,
      };
    }

    final heartRateData = healthData!['HealthDataType.HEART_RATE'] as List;
    if (heartRateData.isEmpty) {
      return {
        'current': 0,
        'min': 0,
        'avg': 0,
        'max': 0,
        'resting': 0,
        'variability': 0,
      };
    }

    // Get the latest reading for current heart rate
    double current = 0;
    if (heartRateData.isNotEmpty) {
      final latestReading = heartRateData.last;
      if (latestReading is Map && latestReading['value'] != null) {
        current = latestReading['value'].numericValue.toDouble();
      }
    }

    // Calculate min, max, and average
    double min = double.maxFinite;
    double max = double.minPositive;
    double sum = 0;

    for (final reading in heartRateData) {
      if (reading is Map && reading['value'] != null) {
        final value = reading['value'].numericValue.toDouble();
        min = value < min ? value : min;
        max = value > max ? value : max;
        sum += value;
      }
    }

    double avg = heartRateData.isNotEmpty ? sum / heartRateData.length : 0;

    // For resting heart rate, we might need to filter for specific times
    // For simplicity, we'll use the minimum value as resting heart rate
    double resting = min;

    // Heart rate variability calculation would require more specific data
    // For now, we'll use a placeholder
    double variability = 58;

    return {
      'current': current,
      'min': min,
      'avg': avg,
      'max': max,
      'resting': resting,
      'variability': variability,
    };
  }

  // Helper method to get blood pressure statistics
  Map<String, dynamic> _getBloodPressureStats() {
    if (healthData == null ||
        healthData!['HealthDataType.BLOOD_PRESSURE_SYSTOLIC'] == null ||
        healthData!['HealthDataType.BLOOD_PRESSURE_DIASTOLIC'] == null) {
      return {
        'systolic': 0,
        'diastolic': 0,
        'lastWeekAverage': '0/0',
        'map': 0,
        'pulse': 0,
      };
    }

    final systolicData =
        healthData!['HealthDataType.BLOOD_PRESSURE_SYSTOLIC'] as List;
    final diastolicData =
        healthData!['HealthDataType.BLOOD_PRESSURE_DIASTOLIC'] as List;

    if (systolicData.isEmpty || diastolicData.isEmpty) {
      return {
        'systolic': 0,
        'diastolic': 0,
        'lastWeekAverage': '0/0',
        'map': 0,
        'pulse': 0,
      };
    }

    // Get the latest reading
    double systolic = 0;
    double diastolic = 0;

    if (systolicData.isNotEmpty && diastolicData.isNotEmpty) {
      final latestSystolic = systolicData.last;
      final latestDiastolic = diastolicData.last;

      if (latestSystolic is Map &&
          latestSystolic['value'] != null &&
          latestDiastolic is Map &&
          latestDiastolic['value'] != null) {
        systolic = latestSystolic['value'].numericValue.toDouble();
        diastolic = latestDiastolic['value'].numericValue.toDouble();
      }
    }

    // Calculate last week average
    double systolicSum = 0;
    double diastolicSum = 0;
    int count = 0;

    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    for (int i = 0; i < systolicData.length; i++) {
      if (i < diastolicData.length) {
        final systolicReading = systolicData[i];
        final diastolicReading = diastolicData[i];

        if (systolicReading is Map &&
            systolicReading['value'] != null &&
            diastolicReading is Map &&
            diastolicReading['value'] != null &&
            systolicReading['date_from'] != null) {
          final readingDate = DateTime.parse(systolicReading['date_from']);
          if (readingDate.isAfter(oneWeekAgo)) {
            systolicSum += systolicReading['value'].numericValue.toDouble();
            diastolicSum += diastolicReading['value'].numericValue.toDouble();
            count++;
          }
        }
      }
    }

    String lastWeekAverage =
        count > 0
            ? '${(systolicSum / count).round()}/${(diastolicSum / count).round()}'
            : '--/--';

    // Calculate MAP (Mean Arterial Pressure)
    double map =
        count > 0 ? (systolicSum / count + 2 * (diastolicSum / count)) / 3 : 0;

    // For pulse, we'll use the heart rate data if available
    double pulse = 0;
    if (healthData!['HealthDataType.HEART_RATE'] != null) {
      final heartRateData = healthData!['HealthDataType.HEART_RATE'] as List;
      if (heartRateData.isNotEmpty) {
        final latestReading = heartRateData.last;
        if (latestReading is Map && latestReading['value'] != null) {
          pulse = latestReading['value'].numericValue.toDouble();
        }
      }
    }

    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'lastWeekAverage': lastWeekAverage,
      'map': map.round(),
      'pulse': pulse.round(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Get the actual data for the widgets
    final heartRateStats = _getHeartRateStats();
    final bloodPressureStats = _getBloodPressureStats();
    final heartRateChartData = _getHeartRateChartData();
    final bloodPressureChartData = _getBloodPressureChartData();

    final List<HealthMetric> sampleMetrics = [
      HealthMetric(
        image: "assets/images/heartbeat.svg",
        iconColor: const Color(0xFF862633),
        iconBackgroundColor: const Color.fromRGBO(134, 38, 51, 0.2),
        title: 'Heart Rate',
        timestamp: '',
        value: (getHealthValue1('HealthDataType.HEART_RATE')['data']),
        unit: getHealthValue1('HealthDataType.HEART_RATE')['unit'],
        onTap: () => print('Heart Rate tapped'),
      ),
      HealthMetric(
        image: "assets/images/ic5.svg",
        iconColor: const Color(0xFF0074C4),
        iconBackgroundColor: const Color.fromRGBO(0, 116, 196, 0.2),
        title: 'Blood Pressure',
        timestamp: '',
        value:
            (getHealthValue1('HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['data']),
        unit: getHealthValue1('HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['unit'],
        onTap: () => print('Blood Pressure tapped'),
      ),
      HealthMetric(
        image: "assets/images/ic6.svg",
        iconColor: const Color(0xFF1A9B8E),
        iconBackgroundColor: const Color.fromRGBO(26, 155, 142, 0.2),
        title: 'Blood Glucose',
        timestamp: '',
        value: (getHealthValue1('HealthDataType.BLOOD_GLUCOSE')['data']),
        unit: getHealthValue1('HealthDataType.BLOOD_GLUCOSE')['unit'],
        onTap: () => print('Blood Glucose tapped'),
      ),
      HealthMetric(
        image: "assets/images/ic7.png",
        iconColor: const Color(0xFF2563EB),
        iconBackgroundColor: const Color.fromRGBO(37, 99, 235, 0.2),
        title: 'Oxygen (Spo2)',
        timestamp: '',
        value: (getHealthValue1('HealthDataType.BLOOD_OXYGEN')['data']),
        unit: getHealthValue1('HealthDataType.BLOOD_OXYGEN')['unit'],
        onTap: () => print('Oxygen tapped'),
        isTrue: true,
      ),
    ];

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
        title: "Vitals & Measurements",
        // rightWidget: Icon(Icons.more_vert, color: Colors.black),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Current Vitals",
                    style: GoogleFonts.inter(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     "History",
                //     style: GoogleFonts.inter(
                //       color: Color(0xFF862633),
                //       fontSize: 16,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HeartRateWidget(
                title: 'Heart Rate',
                currentHeartRate:
                    (heartRateStats['current'] as num?)?.round() ?? 0,
                unit: 'bpm',
                status: 'Normal',
                heartRateData: heartRateChartData,
                minHeartRate: (heartRateStats['min'] as num?)?.round() ?? 0,
                avgHeartRate: (heartRateStats['avg'] as num?)?.round() ?? 0,
                maxHeartRate: (heartRateStats['max'] as num?)?.round() ?? 0,
                restingHeartRate:
                    (heartRateStats['resting'] as num?)?.round() ?? 0,
                heartRateVariability:
                    (heartRateStats['variability'] as num?)?.round() ?? 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BloodPressureWidget(
                title: 'Blood Pressure',
                systolicValue:
                    (bloodPressureStats['systolic'] as num?)?.round() ?? 0,
                diastolicValue:
                    (bloodPressureStats['diastolic'] as num?)?.round() ?? 0,
                unit: 'mmHg',
                status: 'Normal',
                weeklyData: bloodPressureChartData,
                lastWeekAverage: (() {
                  final val = bloodPressureStats['lastWeekAverage'];
                  if (val is num) return val.round().toString();
                  if (val is String)
                    return (double.tryParse(val)?.round() ?? 0).toString();
                  return '0';
                }()),
                lastReading: '',
                mapValue: (bloodPressureStats['map'] as num?)?.round() ?? 0,
                pulseValue: (bloodPressureStats['pulse'] as num?)?.round() ?? 0,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Other Vital Metrics",
                    style: GoogleFonts.inter(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "",
                    style: GoogleFonts.inter(
                      color: Color(0xFF862633),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
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
                      image: "assets/images/ic6.svg",
                      imageColor: Color(0xFF1A9B8E),
                      imageBackgroundColor: Color.fromRGBO(26, 155, 142, 0.2),
                      title: "Blood Glucose",
                      value:
                          getHealthValue(
                            'HealthDataType.BLOOD_GLUCOSE',
                          )['data'],
                      unit:
                          getHealthValue(
                            'HealthDataType.BLOOD_GLUCOSE',
                          )['unit'],
                      goalLabel: "",
                      progress: 5.2 / 8.0,
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/ic7.png",
                      imageColor: Color(0xFF2563EB),
                      imageBackgroundColor: Color.fromRGBO(37, 99, 235, 0.2),
                      title: "Oxygen(Sp02)",
                      value:
                          getHealthValue('HealthDataType.BLOOD_OXYGEN')['data'],
                      unit:
                          getHealthValue('HealthDataType.BLOOD_OXYGEN')['unit'],
                      goalLabel: "",
                      progress: 12 / 15,
                      isTrue: true,
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/lungs.svg",
                      imageColor: Color(0xFFFF1919),
                      imageBackgroundColor: Color.fromRGBO(255, 25, 25, 0.2),
                      title: "Respiratory Rate",
                      value:
                          getHealthValue(
                            'HealthDataType.RESPIRATORY_RATE',
                          )['data'],
                      unit:
                          getHealthValue(
                            'HealthDataType.RESPIRATORY_RATE',
                          )['unit'],
                      goalLabel: "",
                      progress: 5.2 / 8.0,
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/temp.svg",
                      imageColor: Color(0xFF9333EA),
                      imageBackgroundColor: Color.fromRGBO(147, 51, 234, 0.2),
                      title: "Temperature",
                      value: () {
                        final raw =
                            getHealthValue(
                              'HealthDataType.BODY_TEMPERATURE',
                            )['data'];
                        if (raw == '--') return '--';
                        final celsius = double.tryParse(raw.toString()) ?? 0;
                        final fahrenheit = (celsius * 9 / 5) + 32;
                        return fahrenheit.toStringAsFixed(1);
                      }(),
                      unit: "°F",
                      goalLabel: "",
                      progress: 12 / 15,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Body Measurement",
                    style: GoogleFonts.inter(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     "Updates",
                //     style: GoogleFonts.inter(
                //       color: Color(0xFF862633),
                //       fontSize: 16,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BodyMetricsWidget(
                primaryMetrics: [
                  BodyMetric(
                    label: 'Weight',
                    value: () {
                      final raw =
                          getHealthValue1('HealthDataType.WEIGHT')['data'];
                      if (raw == '--') return '--';
                      final kg = double.tryParse(raw.toString()) ?? 0;
                      final lbs = kg * 2.20462;
                      return lbs.toStringAsFixed(1); // e.g. 154.3
                    }(),
                    unit: "lb",
                    changeText: '',
                    changeColor: const Color(0xFF4CAF50),
                  ),
                  BodyMetric(
                    label: 'Height',
                    value: () {
                      final raw =
                          getHealthValue1('HealthDataType.HEIGHT')['data'];
                      if (raw == '--') return '--';
                      final meters = double.tryParse(raw.toString()) ?? 0;
                      final feet = meters * 3.28084;
                      return feet.toStringAsFixed(1); // e.g. 5.9
                    }(),
                    unit: "ft",
                    additionalInfo: 'Last Update 3 mon ago',
                    additionalInfoColor: Colors.grey[600],
                  ),
                ],
                secondaryMetrics: [
                  BodyMetric(
                    label: 'BMI',
                    value:
                        getHealthValue(
                          'HealthDataType.BODY_MASS_INDEX',
                        )['data'],
                    status: '',
                    statusColor: const Color(0xFF4CAF50),
                  ),
                  BodyMetric(
                    label: 'Calories',
                    value:
                        getHealthValue1(
                          'HealthDataType.TOTAL_CALORIES_BURNED',
                        )['data'],
                    unit: "",
                    status: '',
                    statusColor: const Color(0xFF4CAF50),
                  ),
                  BodyMetric(
                    label: 'Body Fat',
                    value:
                        getHealthValue(
                          'HealthDataType.BODY_FAT_PERCENTAGE',
                        )['data'],
                    unit:
                        getHealthValue(
                          'HealthDataType.BODY_FAT_PERCENTAGE',
                        )['unit'],
                    additionalInfo: '76.1%',
                    additionalInfoColor: Colors.grey[600],
                  ),
                ],
                tertiaryMetrics: [
                  BodyMetric(
                    label: 'Bone Mass',
                    value: ((double.tryParse(
                                  getHealthValue1(
                                    'HealthDataType.WEIGHT',
                                  )['data'].toString(),
                                ) ??
                                0.0) *
                            2.20462)
                        .toStringAsFixed(1),
                    unit: "lb",
                  ),
                  BodyMetric(
                    label: 'Water',
                    value: (totalWaterLiters).toStringAsFixed(1),
                    unit: "ml",
                  ),
                  BodyMetric(
                    label: 'Heart Rate',
                    value:
                        (getHealthValue1('HealthDataType.HEART_RATE')['data']),
                    unit: getHealthValue1('HealthDataType.HEART_RATE')['unit'],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Recent Reading",
                    style: GoogleFonts.inter(
                      color: Color(0xFF000000),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Text(
                //     "See All",
                //     style: GoogleFonts.inter(
                //       color: Color(0xFF862633),
                //       fontSize: 16,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HealthMetricsListWidget(metrics: sampleMetrics),
            ),
            SizedBox(height: 24),
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
