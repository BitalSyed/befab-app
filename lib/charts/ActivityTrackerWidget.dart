import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityTrackerWidget extends StatelessWidget {
  final String title;
  final String date;
  final int currentValue;
  final String unit;
  final int goalValue;
  final double progressPercentage;
  final int averageValue;
  final Color progressColor;
  final Color backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? dateStyle;
  final TextStyle? currentValueStyle;
  final TextStyle? unitStyle;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double strokeWidth;

  const ActivityTrackerWidget({
    Key? key,
    required this.title,
    required this.date,
    required this.currentValue,
    required this.unit,
    required this.goalValue,
    required this.progressPercentage,
    required this.averageValue,
    this.progressColor = const Color(0xFF8B4B5C),
    this.backgroundColor = const Color(0xFFE5E5E5),
    this.titleStyle,
    this.dateStyle,
    this.currentValueStyle,
    this.unitStyle,
    this.labelStyle,
    this.valueStyle,
    this.strokeWidth = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: titleStyle ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000000)
                    ),
              ),
              Text(
                date,
                style: dateStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,

                      color: Color(0xFF878686),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Circular Chart
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    sections: _buildPieChartSections(),
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatNumber(currentValue),
                      style: currentValueStyle ??
                          const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                    Text(
                      unit,
                      style: unitStyle ??
                          TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,

                            color: Color(0xFF878686),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Bottom stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn(
                'Goal',
                _formatNumber(goalValue),
              ),
              _buildStatColumn(
                'Progress',
                '${progressPercentage.toInt()}%',
              ),
              _buildStatColumn(
                'Remaining',
                _formatNumber(averageValue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    const Color progressColor = Color(0xFF862633);     // Maroonish red
const Color backgroundColor = Color(0xFFF3F4F6);   // Light gray background (optional)

  final double progressValue = progressPercentage / 100;
  final double remainingValue = 1.0 - progressValue;

  return [
    // Progress section
    PieChartSectionData(
      color: progressColor,
      value: progressValue,
      radius: strokeWidth,
      showTitle: false,
      borderSide: BorderSide.none,
    ),
    // Remaining section
    PieChartSectionData(
      color: backgroundColor,
      value: remainingValue,
      radius: strokeWidth,
      showTitle: false,
      borderSide: BorderSide.none,
    ),
  ];
}


  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: labelStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF878686),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF191919),
              ),
        ),
      ],
    );
  }
}
