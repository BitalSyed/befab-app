
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:google_fonts/google_fonts.dart';

class ActivityCard extends StatelessWidget {
  final String image;
  final bool isTrue;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String metric1Label;
  final String metric1Value;
  final String metric2Label;
  final String metric2Value;
  final String metric3Label;
  final String metric3Value;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.image,
    required this.isTrue,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.metric1Label,
    required this.metric1Value,
    required this.metric2Label,
    required this.metric2Value,
    required this.metric3Label,
    required this.metric3Value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
  margin: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Color(0xFFFFFFFF), // white background color
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Color(0xFFF3F4F6)), // optional inner border
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // Top Row: Icon + Texts + Chevron
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconBackgroundColor,
                  radius: 24,
                  child: SvgPicture.asset(image,color: iconColor,width: 24,height: 24,),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(subtitle,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF862633),size: 24,),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom: Metric Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricBox(metric1Label, metric1Value),
                _buildMetricBox(metric2Label, metric2Value),
                _buildMetricBox(metric3Label, metric3Value),
              ],
            ),
            SizedBox(height: 18,),
            isTrue
    ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFF0074C4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            "Add New Workout",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
    : SizedBox.shrink(), // or any other widget if false

          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(
        color: Color(0xFFF3F4F6), // Light gray border
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
fontWeight: FontWeight.w500,
            color: Colors.black87,          ),
        ),
      ],
    ),
  );
}
}