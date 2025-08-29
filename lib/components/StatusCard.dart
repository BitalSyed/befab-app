import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this is imported

class StatusCard extends StatelessWidget {
  final String heading;
  final String subText;
  final String image;
  final Color imageColor;
  final Color imageBgColor;

  const StatusCard({
    super.key,
    required this.heading,
    required this.subText,
    required this.image,
    required this.imageColor,
    required this.imageBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
  backgroundColor: imageBgColor,
  radius: 20,
  child: SvgPicture.asset(
    image,             // path to your SVG asset
    color: imageColor, // optional color tint
    width: 20,
    height: 20,
  ),
),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF878686),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
