import 'package:befab/components/AddedItemsList.dart';
import 'package:befab/components/CaloriesMacroTracking.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/HeadingWithImageRow.dart';
import 'package:befab/components/MealTypeSelector.dart';
import 'package:befab/components/MetricsOverview.dart';
import 'package:befab/components/MetricsOverview2.dart';
import 'package:befab/components/SleepTracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health/health.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/health_service/health_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class MealLogging extends StatefulWidget {
  @override
  _MealLoggingState createState() => _MealLoggingState();
}

class _MealLoggingState extends State<MealLogging> {
  void _showPortionDialog(Map<String, dynamic> product) {
    final TextEditingController portionController = TextEditingController();
      debugPrint("Data Barcode: $product");

    // Try to auto-detect serving size from API
    String detectedUnit = "g";
    double detectedAmount = 100; // default: per 100g

    if (product["serving_size"] != null) {
      final serving = product["serving_size"].toString().toLowerCase();

      if (serving.contains("tsp")) {
        detectedUnit = "tsp";
        detectedAmount = 5;
      } else if (serving.contains("tbsp")) {
        detectedUnit = "tbsp";
        detectedAmount = 15;
      } else if (serving.contains("cup")) {
        detectedUnit = "cup";
        detectedAmount = 240;
      } else if (serving.contains("ml")) {
        detectedUnit = "ml";
        detectedAmount =
            double.tryParse(
              RegExp(r"(\d+)").firstMatch(serving)?.group(1) ?? "240",
            ) ??
            240;
      } else if (serving.contains("g")) {
        detectedUnit = "g";
        detectedAmount =
            double.tryParse(
              RegExp(r"(\d+)").firstMatch(serving)?.group(1) ?? "100",
            ) ??
            100;
      }
    }

    portionController.text = detectedAmount.toString();

    final units = ["g", "ml", "tsp", "tbsp", "cup", "slice", "tub", "drink"];

    showDialog(
      context: context,
      builder: (context) {
        String selectedUnit = detectedUnit;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Portion Size for ${product['name']}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: portionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Enter amount",
                      hintText: "e.g. 2",
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnit = value;
                        });
                      }
                    },
                    items:
                        units
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(portionController.text) ?? 1.0;

                    final per100 = (product["calories"] ?? 0).toDouble();

                    // 🔥 Apply rough conversions for tsp/tbsp/cup
                    double grams = amount;
                    switch (selectedUnit) {
                      case "tsp":
                        grams = amount * 5;
                        break;
                      case "tbsp":
                        grams = amount * 15;
                        break;
                      case "cup":
                        grams = amount * 240;
                        break;
                      case "ml":
                        grams = amount; // assume 1ml ≈ 1g for water-based
                        break;
                      default:
                        grams = amount;
                    }

                    double calories = (per100 / 100.0) * grams;

                    Navigator.pop(context);

                    _submitMealData1(
                      "${product['name']} ($amount $selectedUnit)",
                      calories,
                    );
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final HealthService healthService = HealthService();
  Map<String, dynamic>? healthData;
  final storage = FlutterSecureStorage();
  bool showMealForm = false;
  String selectedMealType = '';
  num selectedWater = 0;

  // Form controllers
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  late List<MealOption> sampleMeals;
  @override
  void initState() {
    super.initState();
    // Initialize with empty values first
    sampleMeals = [
      MealOption(
        name: 'Breakfast',
        calories: 0,
        selectedBgColor: Color(0xFFFFF0F0),
      ),
      MealOption(name: 'Lunch', calories: 0),
      MealOption(name: 'Dinner', calories: 0),
      MealOption(name: 'Snack', calories: 0),
    ];
    getData(); // Fetch initial data
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
  List<dynamic> filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();

  // Variables accessible anywhere in this file
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

    totalWaterLiters = (waterIntakeOz as num) * 0.0295735;

    setState(() {
      sampleMeals = [
        MealOption(
          name: 'Breakfast',
          calories: totalCaloriesBreakfast,
          selectedBgColor: Color(0xFFFFF0F0),
        ),
        MealOption(name: 'Lunch', calories: totalCaloriesLunch),
        MealOption(name: 'Dinner', calories: totalCaloriesDinner),
        MealOption(name: 'Snack', calories: totalCaloriesSnacks),
      ];
    });

    // print('🍳 Breakfast: $totalCaloriesBreakfast');
    // print('🥪 Lunch: $totalCaloriesLunch');
    // print('🍽 Dinner: $totalCaloriesDinner');
    // print('🍿 Snacks: $totalCaloriesSnacks');
    // print('⚡ Total Calories: $totalCaloriesAll');
    // print('💧 Water: ${totalWaterLiters.toStringAsFixed(2)} L');
  }

  Widget buildMealItemsList(List<dynamic> items) {
    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      children:
          items.map<Widget>((item) {
            final name = item['name'] ?? '';
            final calories = (item['calories'] ?? 0);

            return HeadingWithImageRow(
              heading: name,
              subtitle: "$calories calories",
              trailingWidget: null, // No add button
            );
          }).toList(),
    );
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

  // final List<MealOption> sampleMeals = [
  //   MealOption(
  //     name: 'Breakfast',
  //     calories: totalCaloriesBreakfast,
  //     selectedBgColor: Color(0xFFFFF0F0),
  //   ),
  //   MealOption(name: 'Lunch', calories: 480),
  //   MealOption(name: 'Dinner', calories: 450),
  //   MealOption(name: 'Snack', calories: 0),
  // ];
  final List<AddedItem> sampleItems = [
    AddedItem.food(
      name: 'Scrambled Eggs',
      servingInfo: '2 Large Eggs',
      calories: 140,
      quantity: 2,
    ),
    AddedItem.food(
      name: 'Whole White Toast',
      servingInfo: '1 Slice',
      calories: 80,
      quantity: 1,
    ),
  ];

  // Function to open meal form
  void _openMealForm(String mealType) {
    setState(() {
      showMealForm = true;
      selectedMealType = mealType;

      // Clear previous form data
      foodNameController.clear();
      caloriesController.clear();
      proteinController.clear();
      fatController.clear();
      carbsController.clear();
      quantityController.clear();
    });
  }

  // Function to close meal form
  void _closeMealForm() {
    setState(() {
      showMealForm = false;
      selectedMealType = '';
    });
  }

  // Function to submit meal data to backend
  Future<void> _submitMealData() async {
    try {
      // Get token from secure storage
      final token = await storage.read(key: 'token');
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
        "bucket": "$selectedMealType".toLowerCase(),
        "item": {
          "name": foodNameController.text,
          "calories": int.tryParse(caloriesController.text) ?? 0,
          "protein_g": int.tryParse(proteinController.text) ?? 0,
          "fat_g": int.tryParse(fatController.text) ?? 0,
          "carbs_g": int.tryParse(carbsController.text) ?? 0,
          "quantity": int.tryParse(quantityController.text) ?? 1,
        },
      };

      // Make the API call
      final response = await http.post(
        Uri.parse(
          '${dotenv.env['BACKEND_URL']}/app/nutrition/$currentDate/meal',
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
        ).showSnackBar(SnackBar(content: Text('Meal added successfully!')));
        _closeMealForm();
        getData(); // Refresh the data
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meal: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitWater() async {
    try {
      // Get token from secure storage
      final token = await storage.read(key: 'token');
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
          SnackBar(content: Text('Failed to add meal: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitMealData1(String foodName, num calories) async {
    try {
      // Get token from secure storage
      final token = await storage.read(key: 'token');
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
        "bucket": "other".toLowerCase(),
        "item": {"name": foodName, "calories": double.parse(calories.toStringAsFixed(2)) ?? 0},
      };

      // Make the API call
      final response = await http.post(
        Uri.parse(
          '${dotenv.env['BACKEND_URL']}/app/nutrition/$currentDate/meal',
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
        ).showSnackBar(SnackBar(content: Text('Meal added successfully!')));
        getData(); // Refresh the data

        // Clear search and hide results
        setState(() {
          _searchController.clear();
          filteredFoods.clear();
        });
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meal: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          'Meal Logging',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                MetricsOverview(
                  healthData: {
                    'Calories': {'data': totalCaloriesAll, 'unit': ''},
                    'Water': {
                      'data': (nutritionData?['waterIntake_oz'] ?? 0),
                      'unit': 'ml',
                    },
                    'Sleep': {
                      'data':
                          getHealthValue(
                            'HealthDataType.SLEEP_SESSION',
                          )['data'],
                      'unit':
                          getHealthValue(
                            'HealthDataType.SLEEP_SESSION',
                          )['unit'],
                    },
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Meal Logging",
                        style: GoogleFonts.inter(
                          color: Color(0xFF000000),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
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

                HeadingWithImageRow(
                  heading: "Breakfast",
                  subtitle: "$totalCaloriesBreakfast calories",
                  trailingWidget: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 30,
                      color: Color(0xFF862633),
                    ),
                    onPressed: () => _openMealForm('breakfast'),
                  ),
                ),
                HeadingWithImageRow(
                  heading: "Lunch",
                  subtitle: "$totalCaloriesLunch calories",
                  trailingWidget: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 30,
                      color: Color(0xFF862633),
                    ),
                    onPressed: () => _openMealForm('lunch'),
                  ),
                ),
                HeadingWithImageRow(
                  heading: "Dinner",
                  subtitle: "$totalCaloriesDinner calories",
                  trailingWidget: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 30,
                      color: Color(0xFF862633),
                    ),
                    onPressed: () => _openMealForm('dinner'),
                  ),
                ),
                HeadingWithImageRow(
                  heading: "Snack",
                  subtitle: "$totalCaloriesSnacks calories",
                  trailingWidget: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 30,
                      color: Color(0xFF862633),
                    ),
                    onPressed: () => _openMealForm('snacks'),
                  ),
                ),
                if (nutritionData != null)
                  buildMealItemsList(nutritionData!['meals']['other'] ?? []),

                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Add Food Items",
                      style: GoogleFonts.lexend(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEDF0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _searchController, // ✅ add controller
                          onChanged: (query) {
                            setState(() {
                              final seen =
                                  <String>{}; // ✅ to track unique items
                              filteredFoods =
                                  (foods ?? [])
                                      .where(
                                        (food) => food['name']
                                            .toString()
                                            .toLowerCase()
                                            .contains(query.toLowerCase()),
                                      )
                                      .map<Map<String, dynamic>>(
                                        (food) =>
                                            Map<String, dynamic>.from(food),
                                      )
                                      .where(
                                        (food) => seen.add(
                                          "${food['name']}-${food['calories']}",
                                        ),
                                      ) // ✅ unique filter
                                      .toList();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Search foods....",
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF5E6B87),
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Color(0xFF5E6B87),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      // 🔽 List of search results
                      if (filteredFoods.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredFoods.length,
                          itemBuilder: (context, index) {
                            final item = filteredFoods[index];
                            return ListTile(
                              title: Text(item['name']),
                              subtitle: Text("${item['calories']} cal"),
                              onTap: () {
                                _submitMealData1(
                                  item['name'],
                                  item['calories'],
                                );

                                // ✅ clear search + hide results
                                setState(() {
                                  _searchController.clear();
                                  filteredFoods.clear();
                                });
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(
                            color: Color(0xFF862633),
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BarcodeScannerScreen(),
                          ),
                        );
                        if (result != null && result['calories'] != null) {
                          debugPrint("✅ Scanned Barcode: $result");

                          _showPortionDialog(result);
                        }
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBarcode(),
                            Text(
                              'Scan Barcode',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF862633),
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                ProgressTracker(
                  title: 'Calories macro Tracking',
                  leftText:
                      '${totalCaloriesAll > 2000 ? 2000 : totalCaloriesAll}/2000 cal',
                  rightText:
                      totalCaloriesAll >= 2000
                          ? 'Goal reached'
                          : '${2000 - totalCaloriesAll} cal remaining',
                  progress: (totalCaloriesAll / 2000).clamp(0, 1),
                  progressColor: const Color(0xFF862633),
                ),

                // MetricsOverview2(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          label: 'Proteins',
                          value: '$totalP g',
                          color: const Color(0xFF862633), // Maroon
                        ),
                        _buildMetricItem(
                          label: 'Fats',
                          value: '$totalF g',
                          color: const Color(0xFF862633), // Blue
                        ),
                        _buildMetricItem(
                          label: 'Carbs',
                          value: '$totalC g',
                          color: const Color(0xFF862633), // Purple
                        ),
                      ],
                    ),
                  ),
                ),

                ProgressTracker(
                  title: 'Hydration Tracker',
                  leftText:
                      '${((((nutritionData?['waterIntake_oz'] ?? 0) / 1000) / 3.2) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                  rightText: '100%',
                  progress: (((nutritionData?['waterIntake_oz'] ?? 0) / 1000) /
                          3.2)
                      .clamp(0.0, 1.0),
                  progressColor: const Color(0xFF862633),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF862633),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Add Water"),
                              content: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Enter water (ml)",
                                ),
                                onChanged: (value) {
                                  selectedWater = double.tryParse(value) ?? 0;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _submitWater();
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        child: Text(
                          'Add Water',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Text(
                //       "Sleep Tracker",
                //       style: GoogleFonts.lexend(
                //         color: Color(0xFF000000),
                //         fontSize: 16,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
                // SleepTracker(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Wellness Tips",
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
                            "Mindful Eating",
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
                            "Take time to enjoy your food without distractions. This help with digestion and prevents overeating",
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

          // Meal Form Overlay
          if (showMealForm)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add $selectedMealType',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF862633),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: _closeMealForm,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: foodNameController,
                          decoration: InputDecoration(
                            labelText: 'Food Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: caloriesController,
                          decoration: InputDecoration(
                            labelText: 'Calories',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: proteinController,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: fatController,
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: carbsController,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF862633),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: _submitMealData,
                            child: Text(
                              'Add Meal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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

Widget _buildMetricItem({
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFFAFBFB)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBarcode() {
  return Container(
    height: 20,
    width: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBarcodeBar(width: 2, height: 25),
        SizedBox(width: 2),
        _buildBarcodeBar(width: 1, height: 30),
        SizedBox(width: 3),
        _buildBarcodeBar(width: 3, height: 20),
        SizedBox(width: 2),
        _buildBarcodeBar(width: 2, height: 25),
        SizedBox(width: 1),
        _buildBarcodeBar(width: 2, height: 25),
        SizedBox(width: 4),
        _buildBarcodeBar(width: 3, height: 30),
        SizedBox(width: 2),
        _buildBarcodeBar(width: 2, height: 20),
        SizedBox(width: 1),
        _buildBarcodeBar(width: 1, height: 25),
        SizedBox(width: 3),
        _buildBarcodeBar(width: 2, height: 25),
      ],
    ),
  );
}

Widget _buildBarcodeBar({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Color(0xFF862633),
      borderRadius: BorderRadius.circular(0.5),
    ),
  );
}

Future<Map<String, dynamic>?> fetchProductFromBarcode(String barcode) async {
  final url = Uri.parse(
    "https://world.openfoodfacts.org/api/v0/product/$barcode.json",
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 1) {
      return data['product'];
    } else {
      return null;
    }
  } else {
    throw Exception("API Error: ${response.statusCode}");
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) async {
          if (_scanned) return;
          _scanned = true;

          final barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;
            if (code != null) {
              try {
                final product = await fetchProductFromBarcode(code);

                if (product != null && mounted) {
                  Navigator.pop(context, {
                    "barcode": code,
                    "name": product["product_name"] ?? "Unknown",
                    "brand": product["brands"] ?? "N/A",
                    "calories": product["nutriments"]?["energy-kcal_100g"],
                  });
                } else {
                  if (mounted) {
                    Navigator.pop(context, {
                      "barcode": code,
                      "error": "Product not found",
                    });
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context, {
                    "barcode": code,
                    "error": "API error: $e",
                  });
                }
              }
            }
          }
        },
      ),
    );
  }
}
