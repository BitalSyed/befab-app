import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class VitalsCard extends StatelessWidget {
  final String icon;
  final Color iconBgColor;
  final Color iconColor;

  final String heading;
  final List<Map<String, String>> vitals; // [{label: ..., value: ...}]

  const VitalsCard({
    Key? key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.heading,
    required this.vitals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
      color: Colors.white, // White background for outer container
      border: Border.all(color: Color(0xFFF3F4F6)), // Border color
      borderRadius: BorderRadius.circular(12),
        ),
        child: Card(
      color: Colors.white, // White background for the card
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, // Optional: removes shadow if needed
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: Icon, Heading, Arrow
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    heading,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // const Icon(
                //   Icons.chevron_right,
                //   color: Color(0xFF862633),
                //   size: 24,
                // ),
              ],
            ),
            const SizedBox(height: 16),
      
            // Grid of vitals
            GridView.builder(
              itemCount: vitals.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = vitals[index];
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white, // White background for each grid item
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFF3F4F6)), // Border color
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label']!,
                        style: GoogleFonts.inter(
                          color: Color(0xFF4E4E4E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['value']!,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
  }
