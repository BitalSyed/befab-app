import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionItem {
  final String name;
  final String currentValue;
  final String targetValue;
  final String unit;
  
  const NutritionItem({
    required this.name,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
  });
  
  double get progressPercentage {
    final current = double.tryParse(currentValue) ?? 0.0;
    final target = double.tryParse(targetValue) ?? 1.0;
    return (current / target).clamp(0.0, 1.0);
  }
}

class NutritionTracker extends StatelessWidget {
  final String title;
  final String summaryLabel;
  final List<NutritionItem> nutritionItems;
  final Color progressBarColor;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;

  const NutritionTracker({
    Key? key,
    this.title = 'Nutrition tracker',
    this.summaryLabel = 'Summary',
    required this.nutritionItems,
    this.progressBarColor = const Color(0xFF862633),
    this.backgroundColor = const Color(0xFFFAFBFB),
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary label
            Text(
              summaryLabel,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: progressBarColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nutrition items
            ...nutritionItems.map((item) => _buildNutritionRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(NutritionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and values row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style:  GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
              Text(
                '${item.currentValue}${item.unit} of ${item.targetValue}${item.unit}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: item.progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: progressBarColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}