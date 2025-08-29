import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is included

class HeartRateData {
  final String time;
  final double value;

  const HeartRateData({
    required this.time,
    required this.value,
  });
}

class HeartRateWidget extends StatelessWidget {
  final String title;
  final int currentHeartRate;
  final String unit;
  final String status;
  final Color statusColor;
  final List<HeartRateData> heartRateData;
  final int minHeartRate;
  final int avgHeartRate;
  final int maxHeartRate;
  final int restingHeartRate;
  final int heartRateVariability;
  final String hrvUnit;
  final Color heartIconColor;
  final Color heartIconBackgroundColor;
  final Color chartLineColor;
  final Color chartGradientStartColor;
  final Color chartGradientEndColor;
  final TextStyle? titleStyle;
  final TextStyle? heartRateStyle;
  final TextStyle? unitStyle;
  final TextStyle? statusStyle;
  final TextStyle? timeLabelsStyle;
  final TextStyle? statsLabelStyle;
  final TextStyle? statsValueStyle;

  const HeartRateWidget({
    Key? key,
    required this.title,
    required this.currentHeartRate,
    required this.unit,
    required this.status,
    required this.heartRateData,
    required this.minHeartRate,
    required this.avgHeartRate,
    required this.maxHeartRate,
    required this.restingHeartRate,
    required this.heartRateVariability,
    this.statusColor = const Color(0xFF00CC4C),
    this.heartIconColor = const Color(0xFFEF4444),
    this.heartIconBackgroundColor = const Color(0xFFFEE2E2),
    this.chartLineColor = const Color(0xFFAD1457),
    this.chartGradientStartColor = const Color(0xFFE91E63),
    this.chartGradientEndColor = const Color(0xFFFFFFFF),
    this.hrvUnit = 'ms',
    this.titleStyle,
    this.heartRateStyle,
    this.unitStyle,
    this.statusStyle,
    this.timeLabelsStyle,
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
          border: Border.all(color: Color(0xFFF3F4F6)),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with heart icon, title, current rate, and status
            Row(
              children: [
                // Heart icon
                Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: heartIconBackgroundColor,
    borderRadius: BorderRadius.circular(32),
  ),
  child: Center(
    child: SvgPicture.asset(
      "assets/images/heartbeat.svg",
      color: heartIconColor,
      width: 18,
      height: 18,
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
                      currentHeartRate.toString(),
                      style: heartRateStyle ??
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
            
            // Heart rate chart
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
  gridData: FlGridData(show: false), // Disable default grid
  titlesData: FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles:false,),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
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
                    LineChartBarData(
                      spots: heartRateData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: chartLineColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            chartGradientStartColor.withOpacity(0.3),
                            chartGradientEndColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: chartLineColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                    ),
                  ],
                  minY: heartRateData.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 10,
                  maxY: heartRateData.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 10,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: heartRateData.map((data) {
                return Text(
                  data.time,
                  style: timeLabelsStyle ??
                      TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Stats row (Min, Avg, Max)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Min $minHeartRate $unit'),
                _buildStatItem('Avg $avgHeartRate $unit'),
                _buildStatItem('Max $maxHeartRate $unit'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Additional metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resting Heart Rate',
                      style: statsLabelStyle ??
                          TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      'Heart Rate Variability',
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
                      '$restingHeartRate $unit',
                      style: statsValueStyle ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                    Text(
                      '$heartRateVariability $hrvUnit',
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

  Widget _buildStatItem(String text) {
    return Text(
      text,
      style: statsLabelStyle ??
          TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
    );
  }
}