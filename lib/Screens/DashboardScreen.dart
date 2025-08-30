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
import 'package:health/health.dart';
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
    loadGoals();
    _loadNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHealthData(); // wait for health data to load
      setState(() {
        data = getDWMPercentagesForStepsAndDistance();
      });
    });
  }

  Future<void> _loadNotifications() async {
    final data = await fetchNotifications(); // ✅ await here
    setState(() {
      notifications = data ?? [];
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

    sendData(data);

    debugPrint("✅ Platform: ${healthService.getPlatform()}");
    debugPrint(
      "✅ Fetched health data: ${getHealthValue('HealthDataType.STEPS')}",
    );
  }

  static final String _baseUrl = dotenv.env['BACKEND_URL'] ?? "";
  static Future<void> sendData(Map<String, dynamic> data) async {
    final url = Uri.parse("$_baseUrl/app/data");
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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

  Map<String, Map<String, double>> getDWMPercentagesForStepsAndDistance() {
    Map<String, Map<String, double>> result = {
      "STEPS": {"daily": 0.0, "weekly": 0.0, "monthly": 0.0},
      "DISTANCE": {"daily": 0.0, "weekly": 0.0, "monthly": 0.0},
    };

    // Get the actual values for steps and distance
    final stepsData = getHealthValue("HealthDataType.STEPS");
    final distanceData = getHealthValue("HealthDataType.DISTANCE_DELTA");
    print("Result: ${stepsData}");
    // Parse today's values
    double stepsToday =
        double.tryParse(stepsData["data"]?.toString() ?? "0") ?? 0;
    double distanceToday =
        double.tryParse(distanceData["data"]?.toString() ?? "0") ?? 0;

    // US-based healthy targets (CDC recommendations)
    const double dailyStepsTarget = 10000; // 10,000 steps per day
    const double dailyDistanceTarget = 8000; // 8 km (≈5 miles) per day

    // Calculate percentages
    double stepsPercentage =
        (stepsToday / dailyStepsTarget * 100).clamp(0, 100).toDouble();
    double distancePercentage =
        (distanceToday / dailyDistanceTarget * 100).clamp(0, 100).toDouble();

    result["STEPS"] = {
      "daily": stepsPercentage,
      "weekly": stepsPercentage, // For simplicity, using same as daily
      "monthly": stepsPercentage, // For simplicity, using same as daily
    };

    result["DISTANCE"] = {
      "daily": distancePercentage,
      "weekly": distancePercentage, // For simplicity, using same as daily
      "monthly": distancePercentage, // For simplicity, using same as daily
    };

    return result;
  }

  var data;
  var notifications;

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

  Future<List<dynamic>?> fetchGoalsData() async {
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

      // Build full URL
      final String url = '$backendUrl/app/goals';
      print("Fetching goals data from: $url");

      // Make GET request with Authorization header
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("✅ Goals data fetched successfully");
        print("📊 Number of goals: ${data.length}");
        return data;
      } else {
        print(
          '⚠️ Failed to fetch goals data. Status code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching goals data: $e');
      return null;
    }
  }

  Future<List<dynamic>?> fetchNotifications() async {
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

      // Build full URL
      final String url = '$backendUrl/app/notifications';
      print("Fetching notifications from: $url");

      // Make GET request with Authorization header
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("✅ Notifications fetched successfully");
        print("🔔 Number of notifications: ${data.length}");
        return data;
      } else {
        print(
          '⚠️ Failed to fetch notifications. Status code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return null;
    }
  }

  // Usage example:
  List<dynamic> goals = []; // Variable to store goals

  void loadGoals() async {
    final goalsData = await fetchGoalsData();
    if (goalsData != null) {
      setState(() {
        goals = goalsData;
      });
      print("🎯 Goals loaded: ${goals.length}");
    } else {
      print("❌ Failed to load goals");
    }
  }

  Map<String, dynamic>? nutritionData;
  List<dynamic> foods = [];

  Future<void> _fetchUser() async {
    try {
      final token = await storage.read(key: 'token');
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
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final decimalTime = hour + (minute / 60.0);

    // US cultural context - earlier mornings, later evenings
    if (decimalTime >= 5.0 && decimalTime < 12.0) {
      if (decimalTime < 6.0) return "Early Riser! Good Morning";
      if (decimalTime < 8.0) return "Rise and Shine! Good Morning";
      return "Good Morning";
    } else if (decimalTime >= 12.0 && decimalTime < 17.0) {
      if (decimalTime < 13.0) return "Good Afternoon! Lunch time?";
      return "Good Afternoon";
    } else if (decimalTime >= 17.0 && decimalTime < 22.0) {
      if (decimalTime < 19.0) return "Good Evening! How was your day?";
      return "Good Evening";
    } else {
      // Late night (10 PM - 4:59 AM)
      if (decimalTime >= 22.0 || decimalTime < 5.0) {
        return hour < 2 ? "Up late? Good Night" : "Good Night";
      }
      return "Hello";
    }
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
            Expanded(
              // ← This is the key fix
              child: Column(
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
                    softWrap: true, // ← Ensure wrapping is enabled
                    overflow:
                        TextOverflow.visible, // ← Allow text to wrap visibly
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              right: 12,
              left: 4,
              bottom: 4,
            ),
            child: GestureDetector(
              onTap: () {
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    overlay.size.width, // right align
                    kToolbarHeight, // just below AppBar
                    0,
                    0,
                  ),
                  items: [
                    PopupMenuItem(
                      enabled: false, // non-clickable header
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Notifications",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),

                          // ✅ Handle null safely
                          if (notifications != null && notifications.isNotEmpty)
                            ...notifications.map((n) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.notifications,
                                  color: Colors.pink,
                                ),
                                title: Text(n["content"] ?? "No content"),
                                subtitle: Text(
                                  n["createdAt"] != null
                                      ? DateTime.parse(
                                        n["createdAt"],
                                      ).toLocal().toString()
                                      : "Unknown time",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList()
                          else
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No notifications yet"),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/images/bell.svg',
                    height: 24,
                    width: 24,
                    color: const Color(0xFF862633),
                  ),
                  if (notifications != null && notifications.isNotEmpty)
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
                    _buildActivityTrackerCard(context, data),
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
                          Column(
                            children:
                                goals.map((goal) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: _buildGoalRow(
                                          goal["name"] ?? "Goal Title",
                                          "Duration: ${goal["durationDays"]} days",
                                          "${goal["progressPercent"]}%",
                                        ),
                                      ),
                                      const Divider(thickness: 0.5),
                                    ],
                                  );
                                }).toList(),
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
                          "Groups",
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                    const SizedBox(height: 8),
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
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
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
            margin: const EdgeInsets.only(
              left: 12.0, // Left padding
              top: 0.0, // Top padding
              right: 12.0, // Right padding
              bottom: 0.0, // Bottom padding
            ),
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
      padding: const EdgeInsets.only(
        left: 8.0, // Left padding
        top: 8.0, // Top padding
        right: 8.0, // Right padding
        bottom: 8.0, // Bottom padding
      ),
      child: GestureDetector(
        onTap: () {
          if (route.isNotEmpty) {
            Navigator.pushNamed(context, route); // ✅ use context here
          }
        },
        child: Container(
          width: 80,
          padding: const EdgeInsets.only(
            left: 4.0, // Left padding
            top: 18.0, // Top padding
            right: 4.0, // Right padding
            bottom: 4.0, // Bottom padding
          ),
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

  Widget _buildActivityTrackerCard(BuildContext context, dynamic percentages) {
    print("Activity percentages: $percentages");
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
                Text(
                  'Today',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF862633),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Steps progress bar
            _buildActivityProgressBar(
              "Steps",
              (percentages?["STEPS"]?["daily"]) ?? 0,
              context,
            ),
            const SizedBox(height: 16),

            // Distance progress bar
            _buildActivityProgressBar(
              "Distance",
              (percentages?["DISTANCE"]?["daily"]) ?? 0,
              context,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build individual progress bars
  Widget _buildActivityProgressBar(
    String title,
    double percentage,
    BuildContext context,
  ) {
    double progress = percentage / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(
                    6,
                  ), // optional rounded corners
                ),
                child: Text(
                  "${percentage.round()}%",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4E4E4E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
