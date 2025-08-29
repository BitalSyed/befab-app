import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class WeeklyActivityChart2 extends StatelessWidget {
  final List<int> stepsData;
  final List<int> caloriesData;
  final String title;
  final Color stepsColor;
  final Color caloriesColor;
  final double chartHeight;
  final List<String> dayLabels;
  
  const WeeklyActivityChart2({
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
    final maxSteps = stepsData.reduce((a, b) => a > b ? a : b);
    final maxCalories = caloriesData.reduce((a, b) => a > b ? a : b);
    
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Icon on the left with circular background
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x1AFF8C00), // Light orange background
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset("assets/images/clock.svg",color: Color(0xFFF97316),)
    ),

    // Spacer or SizedBox if needed for spacing
    const SizedBox(width: 16),

    // Today info
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Today",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4E4E4E),
          ),
        ),
        SizedBox(height: 4),
        Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "56 ",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: "Minutes",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4E4E4E),
        ),
      ),
    ],
  ),
)

      ],
    ),

    // Spacer to push Goal to the right
    const Spacer(),

    // Goal info
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        Text(
          "Goal",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4E4E4E),
          ),
        ),
        SizedBox(height: 4),
        Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "56 ",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: "Minutes",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4E4E4E),
        ),
      ),
    ],
  ),
)
      ],
    ),
  ],
),

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
  
  
  Widget _buildDayColumn(String day, int steps, int calories, int maxSteps, int maxCalories) {
  final stepsHeight = (steps / maxSteps) * (chartHeight - 40);
  final caloriesHeight = (calories / maxCalories) * (chartHeight - 40);

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