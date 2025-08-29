import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthStatusCard extends StatelessWidget {
  
  final List<HealthStat> stats;

  const HealthStatusCard({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
      color: Color(0xFFFFFFFF), // background color
      border: Border.all(
        color: Color(0xFFF3F4F6), // border color (light grey)
        width: 1, // optional border width
      ),
      borderRadius: BorderRadius.circular(12), // optional: rounded corners
        ),
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: stats.map((stat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat.title,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Color(0xFF191919))),
                      Text(
                        "${stat.lastUpdated}",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF878686),
                        ),
                      ),
                    ],
                  ),
                ),
      
                // Value, unit and optional label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stat.value} ${stat.unit}',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF191919)),
                    ),
                    if (stat.secondaryLabel != null)
                      Text(
                        stat.secondaryLabel!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: stat.secondaryColor ?? Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
        ),
      ),
    );

  }
}
class HealthStat {
  final String title;
  final String value;
  final String unit;
  final String lastUpdated;
  final String? secondaryLabel;
  final Color? secondaryColor;

  HealthStat({
    required this.title,
    required this.value,
    required this.unit,
    required this.lastUpdated,
    this.secondaryLabel,
    this.secondaryColor,
  });
}
