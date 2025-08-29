import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is included

class AssessmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String timeText;
  final String buttonText;
  final Color primaryColor;
  final Color primaryColorDark;
  final String image;
  final bool showTimeIcon;
  final VoidCallback? onButtonPressed;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const AssessmentCard({
    Key? key,
    this.title = "Weekly Fitness Assessment",
    this.subtitle = "Help us track your progress",
    this.duration = "5 min.",
    this.timeText = "due In 2 Days",
    this.buttonText = "Start Survey",
    this.primaryColor = const Color(0xFF862633), // red-800
    this.primaryColorDark = const Color(0xFF862633), // red-900
    this.image = "",
    this.showTimeIcon = true,
    this.onButtonPressed,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Color(0xFFFAFBFB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF862633),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    // decoration: BoxDecoration(
                    //   color: const Color(0xFF862633), // red-700
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    child: SvgPicture.asset(image)
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Time info
              Row(
                children: [
                  if (showTimeIcon) ...[
                    // Icon(
                    //   Icons.access_time,
                    //   size: 16,
                    //   color: Color(0xFF862633),
                    // ),
                    SvgPicture.asset("assets/images/clock.svg"),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '$duration $timeText',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return primaryColorDark;
                        }
                        return primaryColor;
                      },
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style:  GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}