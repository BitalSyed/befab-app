import 'package:befab/charts/WeeklyActivityChart.dart';
import 'package:befab/components/CustomAppHeader.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/ImageTextGridCard.dart';
import 'package:befab/components/MiniStatCard.dart';
import 'package:befab/components/VitalsCard.dart';
import 'package:befab/services/health_service/health_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/health_service/health_service.dart'; // Make sure to import your HealthService class

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
    final isInstalled = await healthService.isHealthAppInstalled();
    if (!isInstalled) {
      healthService.suggestInstallHealthApp(context);
      return;
    }

    final authorized = await healthService.requestAuthorization();
    if (!authorized) {
      debugPrint("❌ Health permissions denied");
      return;
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 1);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final data = await healthService.fetchAllData(
      from: startOfDay,
      to: endOfDay,
    );

    if (!mounted) return;
    setState(() => healthData = data);

    debugPrint("✅ Platform: ${healthService.getPlatform()}");
    debugPrint("✅ Today’s health data: $data");
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
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.STEPS',
              )['data']?.toString() ??
              '0',
        ) ??
        0;
    // num distance =
    //     (num.tryParse(
    //           HealthUtils.getHealthValue(healthData,'HealthDataType.DISTANCE_DELTA')['data']?.toString() ?? '0',
    //                 'HealthDataType.DISTANCE_DELTA',
    //               )['data']?.toString() ??
    //               '0',
    //         ) ??
    //         0) +
    //     (num.tryParse(
    //         HealthUtils.getHealthValue(healthData,'HealthDataType.DISTANCE_CYCLING')['data']?.toString() ??
    //               '0',
    //         ) ??
    //         0);
    num activeCalories =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.ACTIVE_ENERGY_BURNED',
              )['data']?.toString() ??
              '0',
        ) ??
        0;
    num workouts =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.WORKOUT',
              )['data']?.toString() ??
              '0',
        ) ??
        0;

    num restingHR =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.RESTING_HEART_RATE',
              )['data']?.toString() ??
              '70',
        ) ??
        70;
    num hrv =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.HEART_RATE_VARIABILITY_RMSSD',
              )['data']?.toString() ??
              '30',
        ) ??
        30;
    num spo2 =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.BLOOD_OXYGEN',
              )['data']?.toString() ??
              '95',
        ) ??
        95;

    num bmi =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.BODY_MASS_INDEX',
              )['data']?.toString() ??
              '25',
        ) ??
        25;
    num bodyFat =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.BODY_FAT_PERCENTAGE',
              )['data']?.toString() ??
              '20',
        ) ??
        20;
    num leanMass =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.LEAN_BODY_MASS',
              )['data']?.toString() ??
              '50',
        ) ??
        50;

    num sleepTotal =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.SLEEP_SESSION',
              )['data']?.toString() ??
              '0',
        ) ??
        0;
    num sleepDeep =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.SLEEP_DEEP',
              )['data']?.toString() ??
              '0',
        ) ??
        0;
    num sleepREM =
        num.tryParse(
          HealthUtils.getHealthValue(
                healthData,
                'HealthDataType.SLEEP_REM',
              )['data']?.toString() ??
              '0',
        ) ??
        0;

    num sleepQuality =
        sleepTotal > 0 ? ((sleepDeep + sleepREM) / sleepTotal) : 0;

    // --- Normalize into 0–1 ranges ---
    num activityScore =
        (steps / 10000).clamp(0, 1) * 0.4 +
        // (distance / 5000).clamp(0, 1) * 0.3 +
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
            SvgPicture.asset('assets/images/Arrow.svg', width: 18, height: 18),
            const SizedBox(width: 5),
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
                'h': HealthUtils.getHealthValue(
                  healthData,
                  'HealthDataType.HEART_RATE',
                ),
                's': HealthUtils.getHealthValue(
                  healthData,
                  'HealthDataType.STEPS',
                ),
                'calories': HealthUtils.getHealthValue(
                  healthData,
                  'HealthDataType.TOTAL_CALORIES_BURNED',
                ),
                'sleep': HealthUtils.getHealthValue(
                  healthData,
                  'HealthDataType.SLEEP_SESSION',
                ),
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
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_SESSION')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_SESSION')['unit']}",
                },
                {
                  'label': 'Distance',
                  'value': () {
                    final raw =
                        HealthUtils.getHealthValue(
                          healthData,
                          'HealthDataType.DISTANCE_DELTA',
                        )['data'];
                    if (raw == '--') return '--';
                    final meters = double.tryParse(raw.toString()) ?? 0;
                    final miles = meters * 0.000621371;
                    return "${miles.toStringAsFixed(2)} mi";
                  }(),
                },
                {
                  'label': 'Active Calories',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.ACTIVE_ENERGY_BURNED')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.ACTIVE_ENERGY_BURNED')['unit']}",
                },
                {
                  'label': 'Activity Minutes',
                  'value':
                      HealthUtils.getHealthValue(
                        healthData,
                        'HealthDataType.WORKOUT',
                      )['data'],
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
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.HEART_RATE')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.HEART_RATE')['unit']}",
                },
                {
                  'label': 'Blood Pressure',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['data']}/${HealthUtils.getHealthValue(healthData, 'HealthDataType.BLOOD_PRESSURE_DIASTOLIC')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['unit'] != 'MILLIMETER_OF_MERCURY' ? HealthUtils.getHealthValue(healthData, 'HealthDataType.BLOOD_PRESSURE_SYSTOLIC')['unit'] : 'mmHg'}",
                },
                {
                  'label': 'Oxygen (SpO2)',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.BLOOD_OXYGEN')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.BLOOD_OXYGEN')['unit']}",
                },
                {
                  'label': 'Respiratory Rate',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.RESPIRATORY_RATE')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.RESPIRATORY_RATE')['unit']}",
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
                      (() {
                        final raw =
                            HealthUtils.getHealthValue(
                              healthData,
                              'HealthDataType.WEIGHT',
                            )['data'];
                        if (raw == '--') return '--';
                        final kg = double.tryParse(raw.toString()) ?? 0;
                        final lbs = kg * 2.20462;
                        return "${lbs.toStringAsFixed(1)} lb";
                      })(),
                },
                {
                  'label': 'BMI',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.BODY_MASS_INDEX')['data']}",
                },
                {
                  'label': 'Body Fat',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.BODY_FAT_PERCENTAGE')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.BODY_FAT_PERCENTAGE')['unit']}",
                },
                {
                  'label': 'Lean Mass',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.LEAN_BODY_MASS')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.LEAN_BODY_MASS')['unit']}",
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
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_SESSION')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_SESSION')['unit']}",
                },
                {
                  'label': 'Deep Sleep',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_DEEP')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_DEEP')['unit']}",
                },
                {
                  'label': 'REM Sleep',
                  'value':
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_REM')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.SLEEP_REM')['unit']}",
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
                      "${HealthUtils.getHealthValue(healthData, 'HealthDataType.DISTANCE_CYCLING')['data']} ${HealthUtils.getHealthValue(healthData, 'HealthDataType.DISTANCE_CYCLING')['unit']}",
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
