import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class InfoCardTile extends StatelessWidget {
  final bool isTrue;

  final String title;
  final String subtitle;
  final String image;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const InfoCardTile({
    Key? key,
    required this.isTrue,

    required this.title,
    required this.subtitle,
    required this.image,
    required this.iconBgColor,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Color(0xFFD9D9D9)),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: isTrue? Image.asset(
                  image,
                  height: 26,
                  width: 26,
                  color:
                      iconColor, // optional: applies color tint if image is monochrome
                ):SvgPicture.asset(
                  image,
                  height: 26,
                  width: 26,
                  color:
                      iconColor, // optional: applies color tint if image is monochrome
                ),
              ),
              const SizedBox(width: 12),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
        
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron icon
              const Icon(
                Icons.chevron_right,
                size: 28,
                color: Color(0xFF862633), // Maroon
              ),
            ],
          ),
        ),
      ),
    );
  }
}
