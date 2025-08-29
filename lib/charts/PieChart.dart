import 'package:flutter/material.dart';
import 'dart:math' as math;

class MacroBreakdownChart extends StatelessWidget {
  final String title;
  final int totalCalories;
  final String caloriesLabel;
  
  final String proteinLabel;
  final String proteinAmount;
  final String proteinPercentage;
  final String proteinCalories;
  
  final String fatsLabel;
  final String fatsAmount;
  final String fatsPercentage;
  final String fatsCalories;
  
  final String carbsLabel;
  final String carbsAmount;
  final String carbsPercentage;
  final String carbsCalories;

  const MacroBreakdownChart({
    Key? key,
    this.title = 'Macro Breakdown',
    this.totalCalories = 1250,
    this.caloriesLabel = 'calories',
    this.proteinLabel = 'Protein',
    this.proteinAmount = '65g',
    this.proteinPercentage = '26%',
    this.proteinCalories = '260 cal',
    this.fatsLabel = 'Fats',
    this.fatsAmount = '48g',
    this.fatsPercentage = '35%',
    this.fatsCalories = '432 cal',
    this.carbsLabel = 'Carbs',
    this.carbsAmount = '132g',
    this.carbsPercentage = '39%',
    this.carbsCalories = '558 cal',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: DonutChartPainter(
                      proteinPercentage: _parsePercentage(proteinPercentage),
                      fatsPercentage: _parsePercentage(fatsPercentage),
                      carbsPercentage: _parsePercentage(carbsPercentage),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          totalCalories.toString(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          caloriesLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroInfo(
                color: const Color(0xFFE53E3E), // Red
                label: proteinLabel,
                amount: proteinAmount,
                percentage: proteinPercentage,
                calories: proteinCalories,
              ),
              _buildMacroInfo(
                color: const Color(0xFFD69E2E), // Yellow/Orange
                label: fatsLabel,
                amount: fatsAmount,
                percentage: fatsPercentage,
                calories: fatsCalories,
              ),
              _buildMacroInfo(
                color: const Color(0xFF3182CE), // Blue
                label: carbsLabel,
                amount: carbsAmount,
                percentage: carbsPercentage,
                calories: carbsCalories,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo({
    required Color color,
    required String label,
    required String amount,
    required String percentage,
    required String calories,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage ($calories)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  double _parsePercentage(String percentage) {
    return double.tryParse(percentage.replaceAll('%', '')) ?? 0.0;
  }
}

class DonutChartPainter extends CustomPainter {
  final double proteinPercentage;
  final double fatsPercentage;
  final double carbsPercentage;

  DonutChartPainter({
    required this.proteinPercentage,
    required this.fatsPercentage,
    required this.carbsPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 24.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Calculate angles (converting percentages to radians)
    final total = proteinPercentage + fatsPercentage + carbsPercentage;
    final proteinAngle = (proteinPercentage / total) * 2 * math.pi;
    final fatsAngle = (fatsPercentage / total) * 2 * math.pi;
    final carbsAngle = (carbsPercentage / total) * 2 * math.pi;

    // Start angle (top of circle)
    double startAngle = -math.pi / 2;

    // Draw protein arc (red)
    paint.color = const Color(0xFFE53E3E);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      proteinAngle,
      false,
      paint,
    );
    startAngle += proteinAngle;

    // Draw fats arc (yellow/orange)
    paint.color = const Color(0xFFD69E2E);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      fatsAngle,
      false,
      paint,
    );
    startAngle += fatsAngle;

    // Draw carbs arc (blue)
    paint.color = const Color(0xFF3182CE);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      carbsAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}