import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthService {
  final Health _health = Health();

  /// Only the 5 data types we need
  final List<HealthDataType> _dataTypes = [
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT,
    HealthDataType.STEPS,
    HealthDataType.TOTAL_CALORIES_BURNED, // Calories
    HealthDataType.HEART_RATE, // BPM
  ];

  /// Permissions (READ only on iOS, READ/WRITE on Android)
  List<HealthDataAccess> get _permissions =>
      _dataTypes.map((type) {
        if (Platform.isIOS) return HealthDataAccess.READ;
        return HealthDataAccess.READ_WRITE;
      }).toList();

  /// Configure health plugin
  Future<void> configure() async {
    _health.configure();
    if (Platform.isAndroid) {
      await _health.getHealthConnectSdkStatus();
    }
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

    if (!(hasPermissions ?? false)) {
      try {
        return await _health.requestAuthorization(
          _dataTypes,
          permissions: _permissions,
        );
      } catch (e) {
        debugPrint("❌ Exception in requestAuthorization: $e");
        return false;
      }
    }

    return true;
  }

  /// Fetch the 5 values between [from] and [to]
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
        results[type.toString()] =
            filtered
                .map(
                  (d) => {
                    "value": d.value,
                    "unit": d.unitString,
                    "dateFrom": d.dateFrom.toIso8601String(),
                    "dateTo": d.dateTo.toIso8601String(),
                  },
                )
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
      builder:
          (_) => AlertDialog(
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
}



  // static final String _baseUrl = dotenv.env['BACKEND_URL'] ?? "";

  // static Future<void> sendData(Map<String, dynamic> data) async {
  //   final url = Uri.parse("$_baseUrl/app/data");
  //   final storage = FlutterSecureStorage();
  //   final token = await storage.read(key: 'token');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(data),
  //     );

  //     if (response.statusCode == 200) {
  //       print("✅ Success: ${response.body}");
  //     } else {
  //       print("❌ Failed: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("⚡ Error sending request: $e");
  //   }
  // }