import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthService {
  final Health _health = Health();

  /// Full list of data types (you had before)
  final List<HealthDataType> _allDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.LEAN_BODY_MASS,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WATER,
    HealthDataType.BODY_WATER_MASS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.SLEEP_AWAKE,
    // HealthDataType.SLEEP_IN_BED,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    // HealthDataType.EXERCISE_TIME,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_UNKNOWN,
  ];

  /// iOS does not support everything in _allDataTypes
  List<HealthDataType> get _dataTypes {
    if (Platform.isIOS) {
      return [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
        HealthDataType.BODY_FAT_PERCENTAGE,
        HealthDataType.BODY_MASS_INDEX,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
      ];
    }
    return _allDataTypes;
  }

  /// Permissions mapping (READ / READ_WRITE depending on platform)
  List<HealthDataAccess> get _permissions => _dataTypes.map((type) {
        if (Platform.isIOS) {
          return HealthDataAccess.READ;
        }
        if ([
          HealthDataType.APPLE_MOVE_TIME,
          HealthDataType.APPLE_STAND_HOUR,
          HealthDataType.APPLE_STAND_TIME,
          HealthDataType.WALKING_HEART_RATE,
          HealthDataType.ELECTROCARDIOGRAM,
          HealthDataType.HIGH_HEART_RATE_EVENT,
          HealthDataType.LOW_HEART_RATE_EVENT,
          HealthDataType.IRREGULAR_HEART_RATE_EVENT,
          HealthDataType.EXERCISE_TIME,
        ].contains(type)) {
          return HealthDataAccess.READ;
        }
        return HealthDataAccess.READ_WRITE;
      }).toList();

  /// Configure health plugin
  Future<void> configure() async {
    _health.configure();
    if (Platform.isAndroid) {
      await _health.getHealthConnectSdkStatus();
    }
  }

  /// Check if Health Connect (Android) or Apple Health (iOS) is available
  Future<bool> isHealthAppInstalled() async {
    if (Platform.isAndroid) {
      return await _health.isHealthConnectAvailable();
    } else if (Platform.isIOS) {
      return true; // Apple Health always available
    }
    return false;
  }

  /// Suggest install dialog
  void suggestInstallHealthApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Health App Required"),
        content: const Text(
          "This feature requires Health Connect (Android) or Apple Health (iOS).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final url = Uri.parse(
                Platform.isAndroid
                    ? "https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata"
                    : "https://apps.apple.com/us/app/health/id1110145103",
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text("Install"),
          ),
        ],
      ),
    );
  }

  /// Request runtime + health permissions
  Future<bool> requestAuthorization() async {
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
      await Permission.location.request();
    }

    bool? hasPermissions = await _health.hasPermissions(
      _dataTypes,
      permissions: _permissions,
    );

    debugPrint("🔍 Already has permissions: $hasPermissions");

    bool authorized = false;

    if (!(hasPermissions ?? false)) {
      try {
        authorized = await _health.requestAuthorization(
          _dataTypes,
          permissions: _permissions,
        );

        debugPrint("✅ requestAuthorization returned: $authorized");

        if (Platform.isAndroid && authorized) {
          await _health.requestHealthDataHistoryAuthorization();
          await _health.requestHealthDataInBackgroundAuthorization();
        }
      } catch (e) {
        debugPrint("❌ Exception in requestAuthorization: $e");
      }
    } else {
      debugPrint("✅ Permissions already granted");
      authorized = true;
    }

    return authorized;
  }

  /// Fetch data between [from] and [to]
  Future<Map<String, dynamic>> fetchAllData({
    DateTime? from,
    DateTime? to,
  }) async {
    from ??= DateTime.now().subtract(const Duration(days: 7));
    to ??= DateTime.now();

    Map<String, dynamic> results = {};

    try {
      final authorized = await requestAuthorization();
      if (!authorized) {
        results["error"] = "Permissions denied!";
        return results;
      }

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        types: _dataTypes,
        startTime: from,
        endTime: to,
      );

      for (var type in _dataTypes) {
        var filtered = data.where((d) => d.type == type).toList();
        results[type.toString()] = filtered
            .map((d) => {
                  "value": d.value,
                  "unit": d.unitString,
                  "dateFrom": d.dateFrom.toIso8601String(),
                  "dateTo": d.dateTo.toIso8601String(),
                })
            .toList();
      }
    } catch (e) {
      results["error"] = e.toString();
    }

    return results;
  }

  String getPlatform() {
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "iOS";
    return "Unknown";
  }
}
