import 'package:flutter/material.dart';

class WeeklyActivityChart extends StatelessWidget {
  final List<int> stepsData;
  final List<int> caloriesData;
  final String title;
  final Color stepsColor;
  final Color caloriesColor;
  final double chartHeight;
  final List<String> dayLabels;
  
  const WeeklyActivityChart({
    Key? key,
    required this.stepsData,
    required this.caloriesData,
    this.title = '',
    this.stepsColor = const Color(0xFF862633),
    this.caloriesColor = const Color(0xFFE8D5DB),
    this.chartHeight = 200.0,
    this.dayLabels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find max values for normalization
    final maxSteps = stepsData.isNotEmpty ? stepsData.reduce((a, b) => a > b ? a : b) : 1;
final maxCalories = caloriesData.isNotEmpty ? caloriesData.reduce((a, b) => a > b ? a : b) : 1;

    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Legend
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                _buildLegendItem('Steps', stepsColor),
                const SizedBox(width: 16),
                _buildLegendItem('Calories', caloriesColor),
              ],
            ),
            const SizedBox(height: 24),
            
            // Chart
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  return _buildDayColumn(
                    dayLabels[index],
                    stepsData[index],
                    caloriesData[index],
                    maxSteps,
                    maxCalories,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDayColumn(String day, int steps, int calories, int maxSteps, int maxCalories) {
  final safeMaxSteps = maxSteps > 0 ? maxSteps : 1;
final safeMaxCalories = maxCalories > 0 ? maxCalories : 1;

final stepsHeight = (steps / safeMaxSteps) * (chartHeight - 40);
final caloriesHeight = (calories / safeMaxCalories) * (chartHeight - 40);

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Bars container
      SizedBox(
        height: chartHeight - 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Steps bar
            Container(
              width: 12,
              height: stepsHeight,
              decoration: BoxDecoration(
                color: stepsColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Calories bar
            Container(
              width: 12,
              height: caloriesHeight,
              decoration: BoxDecoration(
                color: caloriesColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Day label
      Text(
        day,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
}