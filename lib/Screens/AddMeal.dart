import 'package:befab/charts/PieChart.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/DateSelector.dart';
import 'package:befab/components/MealBreakdown.dart';
import 'package:befab/components/MealTypeSelector.dart';
import 'package:befab/components/NutritionTracker.dart';
import 'package:befab/components/ProgressSummaryWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:health/health.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/health_service/health_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class AddMeal extends StatefulWidget {
  @override
  _AddMealState createState() => _AddMealState();
}

class _AddMealState extends State<AddMeal> {
  @override
  void initState() {
    super.initState();
    getData();
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

      num? numericValue;

      if (value is NumericHealthValue) {
        // ✅ plugin object case
        numericValue = value.numericValue;
      } else if (value is Map) {
        // ✅ in case the plugin/data source returns it as a Map
        numericValue = value['numericValue'] as num?;
      }

      if (numericValue != null) {
        total += numericValue;
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

  Map<String, dynamic>? nutritionData;

 int totalCaloriesBreakfast = 0;
int totalCaloriesLunch = 0;
int totalCaloriesDinner = 0;
int totalCaloriesSnacks = 0;
int totalCaloriesOther = 0;

int totalPBreakfast = 0;
int totalPLunch = 0;
int totalPDinner = 0;
int totalPSnacks = 0;
int totalPOther = 0;

int totalFBreakfast = 0;
int totalFLunch = 0;
int totalFDinner = 0;
int totalFSnacks = 0;
int totalFOther = 0;

int totalCBreakfast = 0;
int totalCLunch = 0;
int totalCDinner = 0;
int totalCSnacks = 0;
int totalCOther = 0;

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
          (val is num ? val.toDouble() : double.tryParse(val?.toString() ?? "0") ?? 0);
      return sum + (p * qty).toInt();
    });
  }

  int sumF(List<dynamic> items) {
    return items.fold(0, (sum, item) {
      final qty = (item['quantity'] ?? 1) as num;
      final val = item['fat_g'];
      final f =
          (val is num ? val.toDouble() : double.tryParse(val?.toString() ?? "0") ?? 0);
      return sum + (f * qty).toInt();
    });
  }

  int sumC(List<dynamic> items) {
    return items.fold(0, (sum, item) {
      final qty = (item['quantity'] ?? 1) as num;
      final val = item['carbs_g'];
      final c =
          (val is num ? val.toDouble() : double.tryParse(val?.toString() ?? "0") ?? 0);
      return sum + (c * qty).toInt();
    });
  }

  // 🔹 Calories per meal
  totalCaloriesBreakfast = sumCalories(meals['breakfast'] ?? []);
  totalCaloriesLunch = sumCalories(meals['lunch'] ?? []);
  totalCaloriesDinner = sumCalories(meals['dinner'] ?? []);
  totalCaloriesSnacks = sumCalories(meals['snacks'] ?? []);
  totalCaloriesOther = sumCalories(meals['other'] ?? []);

  totalCaloriesAll = totalCaloriesBreakfast +
      totalCaloriesLunch +
      totalCaloriesDinner +
      totalCaloriesSnacks +
      totalCaloriesOther;

  // 🔹 Protein per meal
  totalPBreakfast = sumP(meals['breakfast'] ?? []);
  totalPLunch = sumP(meals['lunch'] ?? []);
  totalPDinner = sumP(meals['dinner'] ?? []);
  totalPSnacks = sumP(meals['snacks'] ?? []);
  totalPOther = sumP(meals['other'] ?? []);

  // 🔹 Fat per meal
  totalFBreakfast = sumF(meals['breakfast'] ?? []);
  totalFLunch = sumF(meals['lunch'] ?? []);
  totalFDinner = sumF(meals['dinner'] ?? []);
  totalFSnacks = sumF(meals['snacks'] ?? []);
  totalFOther = sumF(meals['other'] ?? []);

  // 🔹 Carbs per meal
  totalCBreakfast = sumC(meals['breakfast'] ?? []);
  totalCLunch = sumC(meals['lunch'] ?? []);
  totalCDinner = sumC(meals['dinner'] ?? []);
  totalCSnacks = sumC(meals['snacks'] ?? []);
  totalCOther = sumC(meals['other'] ?? []);

  // 🔹 Overall totals
  totalP = totalPBreakfast + totalPLunch + totalPDinner + totalPSnacks + totalPOther;
  totalF = totalFBreakfast + totalFLunch + totalFDinner + totalFSnacks + totalFOther;
  totalC = totalCBreakfast + totalCLunch + totalCDinner + totalCSnacks + totalCOther;

  // 🔹 Water
  totalWaterLiters = (waterIntakeOz as num) * 0.0295735;

  setState(() {});
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

  List<dynamic> foods = [];

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
      final String currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);

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

  DateTime selectedDate = DateTime.now();
  final List<MealOption> sampleMeals = [
    MealOption(
      name: 'Breakfast',
      calories: 320,
      textColor: Color(0xFF8B4513),
      subtextColor: Color(0xFF666666),
      bgColor: Color(0xFFF5F5F5),
      borderColor: Color(0xFFE0E0E0),
      selectedBgColor: Color(0xFFFFF0F0),
      selectedBorderColor: Color(0xFF8B4513),
    ),
    MealOption(
      name: 'Lunch',
      calories: 480,
      textColor: Color(0xFF8B4513),
      subtextColor: Color(0xFF666666),
      bgColor: Color(0xFFF5F5F5),
      borderColor: Color(0xFFE0E0E0),
      selectedBgColor: Color(0xFFFFF0F0),
      selectedBorderColor: Color(0xFF8B4513),
    ),
    MealOption(
      name: 'Dinner',
      calories: 450,
      textColor: Color(0xFF8B4513),
      subtextColor: Color(0xFF666666),
      bgColor: Color(0xFFF5F5F5),
      borderColor: Color(0xFFE0E0E0),
      selectedBgColor: Color(0xFFFFF0F0),
      selectedBorderColor: Color(0xFF8B4513),
    ),
    MealOption(
      name: 'Snack',
      calories: 0,
      textColor: Color(0xFF8B4513),
      subtextColor: Color(0xFF666666),
      bgColor: Color(0xFFF5F5F5),
      borderColor: Color(0xFFE0E0E0),
      selectedBgColor: Color(0xFFFFF0F0),
      selectedBorderColor: Color(0xFF8B4513),
    ),
  ];
  void _goToPrevious() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      getData();
    });
  }

  void _goToNext() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   leftWidget: Row(
      //     children: [
      //       SvgPicture.asset('assets/images/Arrow.svg', width: 14, height: 14),
      //       SizedBox(width: 4),
      //       Text(
      //         "Back",
      //         style: TextStyle(
      //           color: Color(0xFF862633),
      //           fontSize: 17,
      //           fontWeight: FontWeight.w400,
      //         ),
      //       ),
      //     ],
      //   ),
      //   onLeftTap: () => Navigator.pop(context),
      //   title: "Nutrition Detail",
      //   // rightWidget: Icon(Icons.more_vert, color: Colors.black),
      //   backgroundColor: Colors.white,
      // ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Prevent M3 tint

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
          'Nutrition Detail',
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
            DateSelector(
              selectedDate: selectedDate,
              onPrevious: _goToPrevious,
              onNext: _goToNext,
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Calories Summery",
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ProgressSummaryWidget(
              title: 'Summary',
              consumed: totalCaloriesAll,
              goal: 2000,
              burned:
                  (double.tryParse(
                            getHealthValue(
                              'HealthDataType.TOTAL_CALORIES_BURNED',
                            )['data'].toString(),
                          ) ??
                          0)
                      .round(),

              progressColor: Color(0xFF862633),
              unit: 'cal',
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Macro Breakdown",
                  style: GoogleFonts.lexend(
                    color: Color(0xFF121714),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            MacroBreakdownChart(
              title: 'Macro Breakdown',
              totalCalories: totalCaloriesAll,
              caloriesLabel: 'calories',
              proteinLabel: 'Protein',
              proteinAmount: '${totalP}g',
              proteinPercentage:
                  (totalCaloriesAll == null || totalCaloriesAll == 0)
                      ? "0%"
                      : '${(((totalP ?? 0) * 4) / totalCaloriesAll * 100).round()}%',

              proteinCalories: '${(totalP * 4)} cal',
              fatsLabel: 'Fats',
              fatsAmount: '${totalF}g',
              fatsPercentage:
                  (totalCaloriesAll == null || totalCaloriesAll == 0)
                      ? "0%"
                      : '${(((totalF ?? 0) * 9) / totalCaloriesAll * 100).round()}%',

              fatsCalories: '${totalF * 9} cal',
              carbsLabel: 'Carbs',
              carbsAmount: '${totalC}g',
              carbsPercentage:
                  (totalCaloriesAll == null || totalCaloriesAll == 0)
                      ? "0%"
                      : '${(((totalC ?? 0) * 4) / totalCaloriesAll * 100).round()}%',

              carbsCalories: '${totalC * 4} cal',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Nutrition tracker",
                  style: GoogleFonts.inter(
                    color: Color(0xFF121714),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            NutritionTracker(
              summaryLabel: 'Summary',
              nutritionItems: [
                NutritionItem(
                  name: 'Calories',
                  currentValue: "$totalCaloriesAll", // pass String
                  targetValue: '2000',
                  unit: 'cal',
                ),
                NutritionItem(
                  name: 'Carbs',
                  currentValue: '$totalC',
                  targetValue: '200',
                  unit: 'g',
                ),
                NutritionItem(
                  name: 'Protein',
                  currentValue: '$totalP',
                  targetValue:
                      '50',
                  unit: 'g',
                ),
                NutritionItem(
                  name: 'Fats',
                  currentValue: '$totalF',
                  targetValue: '67',
                  unit: 'g',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Meal Breakdown",
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: MealBreakdown(
                heading: "Breakfast ($totalCaloriesBreakfast cal)",
                meals: [
                  {'meal': 'Proteins', 'grams': '$totalPBreakfast'},
                  {'meal': 'Fats', 'grams': '$totalFBreakfast'},
                  {'meal': 'Carbs', 'grams': '$totalCBreakfast'},
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: MealBreakdown(
                heading: "Lunch ($totalCaloriesLunch cal)",
                meals: [
                  {'meal': 'Proteins', 'grams': '$totalPLunch'},
                  {'meal': 'Fats', 'grams': '$totalFLunch'},
                  {'meal': 'Carbs', 'grams': '$totalCLunch'},
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: MealBreakdown(
                heading: "Dinner ($totalCaloriesDinner cal)",
                meals: [
                  {'meal': 'Proteins', 'grams': '$totalPDinner'},
                  {'meal': 'Fats', 'grams': '$totalFDinner'},
                  {'meal': 'Carbs', 'grams': '$totalCDinner'},
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Recommendation",
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
