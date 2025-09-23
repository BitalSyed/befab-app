import 'package:intl/intl.dart';
import 'package:health/health.dart'; // if you use NumericHealthValue

class HealthUtils {
  static const Map<String, String> simplifiedUnits = {
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
    "WATER": "L",
    "CAFFEINE": "mg",
    "ALCOHOL_CONSUMED": "g",
    "TOBACCO_SMOKED": "cig",
    "BODY_MASS": "kg",
    "HEIGHT": "m",
  };

  /// Get today’s sum for a given type
  static Map<String, dynamic> getHealthValue(
    Map<String, dynamic>? healthData,
    String type, {
    int decimalsIfDouble = 2,
  }) {
    if (healthData == null) return {"data": "--", "unit": ""};

    final raw = healthData[type];
    if (raw is! List || raw.isEmpty) return {"data": "--", "unit": ""};

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    num total = 0;
    String? unit;

    for (final e in raw) {
      if (e is! Map) continue;
      if (!(e['dateFrom'] as String).contains(today)) continue;

      final value = e['value'];
      num? numericValue;

      if (value is NumericHealthValue) {
        numericValue = value.numericValue;
      } else if (value is Map) {
        numericValue = value['numericValue'] as num?;
      }

      if (numericValue != null) total += numericValue;
      unit ??= e['unit'] as String?;
    }

    String outUnit = simplifiedUnits[unit] ?? (unit ?? "");
    String formatted =
        (total % 1 == 0) ? total.toInt().toString() : total.toStringAsFixed(decimalsIfDouble);

    return {"data": formatted, "unit": outUnit};
  }
}
