import 'package:flutter/material.dart';

// Data model class
class CompositionItem {
  final String label;
  final double percentage;
  final Color color;

  const CompositionItem({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

// Chart widget
class BodyCompositionChart extends StatelessWidget {
  final List<CompositionItem> chartItems;  // Only used for chart
  final List<CompositionItem> legendItems; // Shown in legend

  const BodyCompositionChart({
    super.key,
    required this.chartItems,
    required this.legendItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bigger Chart with slim stroke
        CustomPaint(
          size: const Size(250, 250), // Bigger chart
          painter: DonutChartPainter(chartItems),
        ),
        const SizedBox(height: 24),
        // Grid legend layout (2x2)
        Container(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row
              Row(
                children: [
                  _buildLegendItem(legendItems[0]),
                  SizedBox(width: 10,),

                  _buildLegendItem(legendItems[1]),
                ],
              ),
              const SizedBox(height: 16),
              // Second row
              Row(
                children: [
                  _buildLegendItem(legendItems[2]),
                  SizedBox(width: 30,),
                  _buildLegendItem(legendItems[3]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(CompositionItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<CompositionItem> items;

  DonutChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    double total = items.fold(0, (sum, item) => sum + item.percentage);
    double startRadian = -90.0;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 14.0; // Slimmer stroke width

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final item in items) {
      final sweepAngle = (item.percentage / total) * 360;

      paint.color = item.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startRadian * 0.0174533, // Convert degrees to radians
        sweepAngle * 0.0174533,
        false,
        paint,
      );

      startRadian += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}