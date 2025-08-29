import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Make sure this import is present

class ActivityStatCard extends StatelessWidget {
  final ActivityStat stat;

  const ActivityStatCard({Key? key, required this.stat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFF3F4F6),
        ), // single light gray border
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: stat.imageBackgroundColor,
                  child: stat.isTrue ?Image.asset(
                    stat.image,
                    color: stat.imageColor,
                    width: 28,
                    height: 28,
                  ): SvgPicture.asset(
                    stat.image,
                    color: stat.imageColor,
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  stat.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xFF191919),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Main value
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "${stat.value} ",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  TextSpan(
                    text: stat.unit,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF878686),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              stat.goalLabel,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF878686),
              ),
            ),

            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stat.progress,
                backgroundColor: Colors.pink[50],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF862633)),
                minHeight: 6,
              ),
            ),
            if (stat.startLabel != null && stat.startLabel!.isNotEmpty)
              const SizedBox(height: 3),

            if (stat.startLabel != null && stat.startLabel!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat.startLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF878686),
                    ),
                  ),
                  Text(
                    stat.endLabel ?? "",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF878686),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ActivityStat {
  final String image;
  final Color imageColor;
  final Color imageBackgroundColor;
  final String title;
  final String value;
  final String unit;
  final String goalLabel;
  final double progress; // Between 0 and 1
  final String? startLabel;
  final String? endLabel;
  final bool isTrue;

  ActivityStat({
    required this.image,
    required this.imageColor,
    required this.imageBackgroundColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.goalLabel,
    required this.progress,
    this.startLabel,
    this.endLabel,
    this.isTrue = false
  });
}
