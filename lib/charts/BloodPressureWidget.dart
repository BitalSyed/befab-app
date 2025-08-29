import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Make sure to import this

class BloodPressureData {
  final String day;
  final double systolic;
  final double diastolic;

  const BloodPressureData({
    required this.day,
    required this.systolic,
    required this.diastolic,
  });
}

class BloodPressureWidget extends StatelessWidget {
  final String title;
  final int systolicValue;
  final int diastolicValue;
  final String unit;
  final String status;
  final Color statusColor;
  final List<BloodPressureData> weeklyData;
  final String lastWeekAverage;
  final String lastReading;
  final int mapValue;
  final int pulseValue;
  final String mapUnit;
  final String pulseUnit;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color systolicLineColor;
  final Color diastolicLineColor;
  final TextStyle? titleStyle;
  final TextStyle? pressureValueStyle;
  final TextStyle? unitStyle;
  final TextStyle? statusStyle;
  final TextStyle? dayLabelsStyle;
  final TextStyle? statsLabelStyle;
  final TextStyle? statsValueStyle;

  const BloodPressureWidget({
    Key? key,
    required this.title,
    required this.systolicValue,
    required this.diastolicValue,
    required this.unit,
    required this.status,
    required this.weeklyData,
    required this.lastWeekAverage,
    required this.lastReading,
    required this.mapValue,
    required this.pulseValue,
    this.statusColor = const Color(0xFF00CC4C),
    this.iconColor = const Color(0xFF2196F3),
    this.iconBackgroundColor = const Color(0xFFE3F2FD),
    this.systolicLineColor = const Color(0xFF8B1538),
    this.diastolicLineColor = const Color(0xFFBD5A7A),
    this.mapUnit = 'mmHg',
    this.pulseUnit = 'mmHg',
    this.titleStyle,
    this.pressureValueStyle,
    this.unitStyle,
    this.statusStyle,
    this.dayLabelsStyle,
    this.statsLabelStyle,
    this.statsValueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with blood pressure icon, title, reading, and status
            Row(
                children: [
                  // Heart icon
                  Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: iconBackgroundColor,
    borderRadius: BorderRadius.circular(32),
  ),
  child: Center(
    child: SvgPicture.asset(
      "assets/images/ic5.svg",
      color: iconColor,
      width: 20,
      height: 20,
    ),
  ),
),
                  const SizedBox(width: 12),
                  
                  // Title
                  Column(
                    children: [
                      Text(
                        title,
                        style: titleStyle ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                      ),
                      Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${systolicValue}/${diastolicValue}",
                        style: pressureValueStyle ??
                            const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: unitStyle ??
                            const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                    ],
                  ),
                  const Spacer(),
                  
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 204, 76, 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: statusStyle ??
                          TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            
            // Dual line chart for systolic and diastolic
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
    show: true,
    border: Border(
      left: BorderSide(color: Colors.grey[400]!, width: 1), // Y axis
      bottom: BorderSide(color: Colors.grey[400]!, width: 1), // X axis
      right: BorderSide(color: Colors.transparent),
      top: BorderSide(color: Colors.transparent),
    ),
  ),
                  lineBarsData: [
                    // Systolic line (top line)
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.systolic);
                      }).toList(),
                      
                      isCurved: false,
                      color: systolicLineColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: systolicLineColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                    ),
                    // Diastolic line (bottom line)
                    LineChartBarData(
                      
                      spots: weeklyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.diastolic);
                      }).toList(),
                      isCurved: false,
                      color: diastolicLineColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: diastolicLineColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                    ),
                  ],
                  
                  minY: _getMinValue() - 5,
                  maxY: _getMaxValue() + 5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weeklyData.map((data) {
                return Text(
                  data.day,
                  style: dayLabelsStyle ??
                      TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Stats row (Last Week avg and Last Reading)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Week avg: $lastWeekAverage',
                  style: statsLabelStyle ??
                      TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  'Last Reading $lastReading',
                  style: statsLabelStyle ??
                      TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Additional metrics (MAP and Pulse Pressure)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Map ( Mean Arterial Pressure )',
                      style: statsLabelStyle ??
                          TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pulse Pressure',
                      style: statsLabelStyle ??
                          TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$mapValue $mapUnit',
                      style: statsValueStyle ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pulseValue $pulseUnit',
                      style: statsValueStyle ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMinValue() {
    final allValues = <double>[];
    for (final data in weeklyData) {
      allValues.add(data.systolic);
      allValues.add(data.diastolic);
    }
    return allValues.reduce((a, b) => a < b ? a : b);
  }

  double _getMaxValue() {
    final allValues = <double>[];
    for (final data in weeklyData) {
      allValues.add(data.systolic);
      allValues.add(data.diastolic);
    }
    return allValues.reduce((a, b) => a > b ? a : b);
  }
}

