import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealBreakdown extends StatelessWidget {
  final String heading;
  final List<Map<String, String>> meals; // Example: [{'meal': 'Chicken', 'grams': '200g'}, ...]

  const MealBreakdown({
    Key? key,
    required this.heading,
    required this.meals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFFAFBFB),
          borderRadius: BorderRadius.circular(8),
        ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Heading
            Text(
              heading,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF862633),
              ),
            ),
            const SizedBox(height: 10),
        
            // Meals List
            ...meals.map(
              (meal) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Text(
                      meal['meal'] ?? '',
                      style:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400,color: Colors.black),
                    ),
                    Text(
                      meal['grams'] ?? '',
                      style:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400,color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
