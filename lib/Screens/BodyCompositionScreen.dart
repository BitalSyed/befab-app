import 'package:befab/charts/BodyCompositionChart.dart';
import 'package:befab/charts/WeightTrackingChart.dart';
import 'package:befab/components/ActivityStatCard.dart';
import 'package:befab/components/CustomAppHeader.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/HealthStatusCard.dart';
import 'package:befab/components/StatusCard.dart';
import 'package:befab/services/health_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class BodyCompositionScreen extends StatefulWidget {
  const BodyCompositionScreen({Key? key}) : super(key: key);

  @override
  _BodyCompositionScreenState createState() => _BodyCompositionScreenState();
}

class _BodyCompositionScreenState extends State<BodyCompositionScreen> {
  final HealthService healthService = HealthService();
  Map<String, dynamic>? healthData;

  @override
  void initState() {
    super.initState();
    // getData(); // Fetch initial data

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

  String getAverageBodyFatCategory(double bodyFat) {
    if (bodyFat < 18) {
      return "Underfat";
    } else if (bodyFat <= 30) {
      return "Healthy range";
    } else {
      return "Overfat / Obese";
    }
  }

  String getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi >= 18.5 && bmi < 25) {
      return "Normal";
    } else if (bmi >= 25 && bmi < 30) {
      return "Overweight";
    } else if (bmi >= 30 && bmi < 35) {
      return "Obesity Class I";
    } else if (bmi >= 35 && bmi < 40) {
      return "Obesity Class II";
    } else {
      return "Obesity Class III";
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = [
      CompositionItem(
        label: 'Lean Body Mass (76%)',
        percentage:
            double.tryParse(
              getHealthValue1(
                    'HealthDataType.LEAN_BODY_MASS',
                  )?['data']?.toString() ??
                  '0',
            ) ??
            0.0,
        color: Color(0xFF8B2635),
      ),
      CompositionItem(
        label: 'Body Fat',
        percentage:
            double.tryParse(
              getHealthValue1(
                    'HealthDataType.BODY_FAT_PERCENTAGE',
                  )?['data']?.toString() ??
                  '0',
            ) ??
            0.0,
        color: Color.fromRGBO(134, 38, 51, 0.6),
      ),
      CompositionItem(
        label: 'BMI',
        percentage:
            double.tryParse(
              getHealthValue1(
                    'HealthDataType.BODY_MASS_INDEX',
                  )?['data']?.toString() ??
                  '0',
            ) ??
            0.0,
        color: Color.fromRGBO(134, 38, 51, 0.4),
      ),
      CompositionItem(
        label: 'Weight',
        percentage:
            double.tryParse(
              getHealthValue1(
                    'HealthDataType.BODY_MASS_INDEX',
                  )?['data']?.toString() ??
                  '0',
            ) ??
            0.0,
        color: Color.fromRGBO(134, 38, 51, 0.2),
      ),
    ];
    final List<HealthStat> healthStats = [
      HealthStat(
        title: "Weight",
        value: () {
          final raw = getHealthValue1('HealthDataType.WEIGHT')['data'];
          if (raw == '--') return '--';
          final kg = double.tryParse(raw.toString()) ?? 0;
          final lbs = kg * 2.20462;
          return lbs.toStringAsFixed(1); // e.g. "154.3"
        }(),
        unit: "lb",
        lastUpdated: "",
        secondaryLabel: "",
        secondaryColor: Color(0xFF16A34A),
      ),
      HealthStat(
        title: "Height",
        value: () {
          final raw = getHealthValue1('HealthDataType.HEIGHT')['data'];
          if (raw == '--') return '--';
          final meters = double.tryParse(raw.toString()) ?? 0;
          final feet = meters * 3.28084;
          return feet.toStringAsFixed(1); // e.g. "5.9"
        }(),
        unit: "ft",
        lastUpdated: "",
      ),
      HealthStat(
        title: "BMI",
        value: getHealthValue1('HealthDataType.BODY_MASS_INDEX')['data'],
        unit: "",
        lastUpdated: "",
        secondaryLabel: "",
        secondaryColor: Color(0xFF16A34A),
      ),
      HealthStat(
        title: "Body Fat Percent",
        value: getHealthValue1('HealthDataType.BODY_FAT_PERCENTAGE')['data'],
        unit: "%",
        lastUpdated: "",
        secondaryLabel: "",
        secondaryColor: Color(0xFF16A34A),
      ),
      HealthStat(
        title: "Lean Body Mass",
        value: getHealthValue1('HealthDataType.LEAN_BODY_MASS')['data'],
        unit: getHealthValue1('HealthDataType.LEAN_BODY_MASS')['unit'],
        lastUpdated: "",
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
        title: "Body composition",
        rightWidget: Icon(Icons.more_vert, color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weight',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    () {
                      final raw =
                          getHealthValue1('HealthDataType.WEIGHT')['data'];
                      if (raw == '--') return '-- lb';
                      final kg = double.tryParse(raw.toString()) ?? 0;
                      final lbs = kg * 2.20462;
                      return "${lbs.toStringAsFixed(1)} lb";
                    }(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.green, // Use green for weight loss
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
                      image: "assets/images/cal.svg",
                      imageColor: Color(0xFFFF7D0E),
                      imageBackgroundColor: Color.fromRGBO(255, 125, 14, 0.2),
                      title: "BMI",
                      value:
                          getHealthValue1(
                            'HealthDataType.BODY_MASS_INDEX',
                          )['data'],
                      unit: "",
                      goalLabel:
                          "${getBmiCategory(double.tryParse(getHealthValue1('HealthDataType.BODY_MASS_INDEX')['data'].toString()) ?? 0.0)}",
                      progress:
                          (double.tryParse(
                                getHealthValue1(
                                  'HealthDataType.BODY_MASS_INDEX',
                                )['data'].toString(),
                              ) ??
                              0.0) /
                          25,
                      startLabel:
                          getHealthValue1(
                            'HealthDataType.BODY_MASS_INDEX',
                          )['data'],
                      endLabel: '25',
                    ),
                  ),
                  ActivityStatCard(
                    stat: ActivityStat(
                      image: "assets/images/men.svg",
                      imageColor: Color(0xFF2563EB),
                      imageBackgroundColor: Color.fromRGBO(37, 99, 235, 0.2),
                      title: "Body Fat",
                      value:
                          "${getHealthValue1('HealthDataType.BODY_FAT_PERCENTAGE')['data']}%",
                      unit: "",
                      goalLabel:
                          "${getAverageBodyFatCategory(double.tryParse(getHealthValue1('HealthDataType.BODY_FAT_PERCENTAGE')['data'].toString()) ?? 0.0)}",
                      progress:
                          (double.tryParse(
                                getHealthValue1(
                                  'HealthDataType.BODY_FAT_PERCENTAGE',
                                )['data'].toString(),
                              ) ??
                              0.0) /
                          31,
                      startLabel:
                          '${getHealthValue1('HealthDataType.BODY_FAT_PERCENTAGE')['data']}%',
                      endLabel: '31%',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Other Vital Metrics",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            HealthStatusCard(stats: healthStats),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Align(
            //     alignment: Alignment.topLeft,
            //     child: Text(
            //       "Body Composition Analysis",
            //       style: GoogleFonts.inter(
            //         fontSize: 20,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),

            // BodyCompositionChart(
            //   chartItems: allItems.sublist(0, 2), // only 2 shown in chart
            //   legendItems: allItems, // all shown in legend
            // ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Recommendation",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF), // background color
                  border: Border.all(
                    color: Color(0xFFF3F4F6), // border color (light grey)
                    width: 1, // optional border width
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // optional: rounded corners
                ),
                child: Column(
                  children: [
                    StatusCard(
                      heading: 'Your BMI is in the healthy range',
                      subText:
                          'Maintain your current weight through balanced diet and regular exercise.',
                      image:
                          "assets/images/cal.svg", // Replace with any icon you need
                      imageColor: Color(0xFFFF1919),
                      imageBgColor: Color.fromRGBO(255, 25, 25, 0.2),
                    ),
                    StatusCard(
                      heading: 'Consider strength training',
                      subText:
                          'To increase your lean body mass and improve overall fitness.',
                      image:
                          "assets/images/dumbell.svg", // Replace with any icon you need
                      imageColor: Color(0xFF0074C4),
                      imageBgColor: Color.fromRGBO(0, 116, 196, 0.2),
                    ),
                    StatusCard(
                      heading: 'Stay hydrated',
                      subText:
                          'Your body water percentage is good, aim to drink 2-3 liters daily.',
                      image:
                          "assets/images/droplets.svg", // Replace with any icon you need
                      imageColor: Color(0xFF0CBFAD),
                      imageBgColor: Color.fromRGBO(12, 191, 173, 0.2),
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(14.0),
            //   child: SizedBox(
            //     width: double.infinity, // Makes the button take full width
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFF862633),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(24),
            //         ),
            //       ),
            //       onPressed: () {},
            //       child: Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            //         child: Text(
            //           'Add New Measurement',
            //           style: GoogleFonts.lexend(
            //             color: Colors.white,
            //             fontWeight:
            //                 FontWeight.w600, // Optional: make it a bit bolder
            //             fontSize: 16, // Optional: specify a font size
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 36),
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
