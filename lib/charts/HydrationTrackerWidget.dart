import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class HydrationTrackerWidget extends StatelessWidget {
  final String title;
  final int consumedAmount;
  final String consumedUnit;
  final int dailyGoal;
  final String goalUnit;
  final int currentCups;
  final int totalCups;
  final String cupsLabel;
  final Color titleColor;
  final Color progressColor;
  final Color backgroundColor;
  final Color circleTextColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? circleValueStyle;
  final TextStyle? circleLabelStyle;
  final double circleSize;
  final double strokeWidth;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color widgetBackgroundColor;
  final VoidCallback? onTap;

  const HydrationTrackerWidget({
    Key? key,
    required this.title,
    required this.consumedAmount,
    required this.dailyGoal,
    required this.currentCups,
    required this.totalCups,
    this.onTap,
    this.consumedUnit = 'ml',
    this.goalUnit = 'ml',
    this.cupsLabel = 'Cups',
    this.titleColor = const Color(0xFF862633),
    this.progressColor = const Color(0xFF862633),
    this.backgroundColor = const Color(0xFFE5E5E5),
    this.circleTextColor = const Color(0xFF8B4B5C),
    this.titleStyle,
    this.descriptionStyle,
    this.circleValueStyle,
    this.circleLabelStyle,
    this.circleSize = 120.0,
    this.strokeWidth = 8.0,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius,
    this.boxShadow,
    this.widgetBackgroundColor =const Color(0xFFFAFBFB),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progressPercentage = (consumedAmount / dailyGoal).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: widgetBackgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Left side - Text content
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: titleStyle ??
                            GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Description text
                      RichText(
                        text: TextSpan(
                          style: descriptionStyle ??
                               GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.black87,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2
                              ),
                          children: [
                            const TextSpan(text: 'You have consumed\n'),
                            TextSpan(
                              text: '$consumedAmount$consumedUnit',
                            ),
                            const TextSpan(text: ' of your daily\n'),
                            TextSpan(
                              text: '$dailyGoal $goalUnit',
                            ),
                            const TextSpan(text: ' goals'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                
                // Right side - Circular progress
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress circle using PieChart
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          centerSpaceRadius: (circleSize - strokeWidth * 2) / 2,
                          sections: [
                            // Progress section
                            PieChartSectionData(
                              color: progressColor,
                              value: progressPercentage,
                              radius: strokeWidth,
                              showTitle: false,
                              borderSide: BorderSide.none,
                            ),
                            // Remaining section
                            PieChartSectionData(
                              color: backgroundColor,
                              value: 1.0 - progressPercentage,
                              radius: strokeWidth,
                              showTitle: false,
                              borderSide: BorderSide.none,
                            ),
                          ],
                          borderData: FlBorderData(show: false),
                          pieTouchData: PieTouchData(enabled: false),
                        ),
                      ),
                      
                      // Center content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentCups/$totalCups',
                            style: circleValueStyle ??
                                TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: circleTextColor,
                                ),
                          ),
                          Text(
                            cupsLabel,
                            style: circleLabelStyle ??
                                TextStyle(
                                  fontSize: 12,
                                  color: circleTextColor,
                                ),
                          ),
                          
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4,),
           Padding(
  padding: const EdgeInsets.all(12.0),
  child: SizedBox(
    width: double.infinity, // Makes the button take full width
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF862633),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onPressed: () {
        // Add your onTap functionality here
        onTap!();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Text(
          'Add Water',
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.w700, // Optional: make it a bit bolder
            fontSize: 16, // Optional: specify a font size
          ),
        ),
      ),
    ),
  ),
),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity, // Makes the button take full width
                // child: ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFFFFFFF),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(24),
                //     ),
                //     side: BorderSide(
                //       color: Color(0xFF862633)
                //     )
                //   ),
                //   onPressed: () {},
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                //     child: Text(
                //       'Set Reminder',
                //       style: GoogleFonts.lexend(
                //         color: Color(0xFF862633),
                //         fontWeight:
                //             FontWeight.w700, // Optional: make it a bit bolder
                //         fontSize: 16, // Optional: specify a font size
                //       ),
                //     ),
                //   ),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}