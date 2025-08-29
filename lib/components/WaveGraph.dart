import 'package:flutter/material.dart';

class WaveGraph extends StatelessWidget {
  const WaveGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        size: const Size(300, 150),
        painter: WaveGraphPainter(),
      ),
    );
  }
}

class WaveGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B7280) // Gray color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Define wave points based on your image
    final points = [
      Offset(0, size.height * 0.4),
      Offset(size.width * 0.08, size.height * 0.3),
      Offset(size.width * 0.16, size.height * 0.5),
      Offset(size.width * 0.24, size.height * 0.4),
      Offset(size.width * 0.32, size.height * 0.6),
      Offset(size.width * 0.40, size.height * 0.7),
      Offset(size.width * 0.48, size.height * 0.5),
      Offset(size.width * 0.56, size.height * 0.3),
      Offset(size.width * 0.64, size.height * 0.8),
      Offset(size.width * 0.72, size.height * 0.9),
      Offset(size.width * 0.80, size.height * 0.2),
      Offset(size.width * 0.88, size.height * 0.1),
      Offset(size.width * 0.96, size.height * 0.6),
    ];

    // Start the path
    path.moveTo(points[0].dx, points[0].dy);

    // Create smooth curves between points
    for (int i = 1; i < points.length; i++) {
      if (i == 1) {
        // First curve
        path.quadraticBezierTo(
          points[i-1].dx + (points[i].dx - points[i-1].dx) * 0.5,
          points[i-1].dy,
          points[i].dx,
          points[i].dy,
        );
      } else {
        // Smooth curves for the rest
        final controlPoint1 = Offset(
          points[i-1].dx + (points[i].dx - points[i-1].dx) * 0.3,
          points[i-1].dy,
        );
        final controlPoint2 = Offset(
          points[i-1].dx + (points[i].dx - points[i-1].dx) * 0.7,
          points[i].dy,
        );
        
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          points[i].dx,
          points[i].dy,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}