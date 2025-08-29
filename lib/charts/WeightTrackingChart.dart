import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint({required this.label, required this.value});
}

class WeightTrackingChart extends StatelessWidget {
  final String title;
  final String currentWeight;
  final String weightUnit;
  final String changeText;
  final bool isWeightLoss;
  final String titleImage;
  final Color titleIconColor;
  final Color titleIconBackgroundColor;
  final Color changeTextColor;
  final Color chartLineColor;
  final Color chartPointColor;
  final Color backgroundColor;
  final Color titleTextColor;
  final Color weightTextColor;
  final Color chartLabelColor;
  final Color axisColor;
  final Color gridColor;
  final List<ChartDataPoint> chartData;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool showGrid;
  final bool showYAxisLabels;

  const WeightTrackingChart({
    Key? key,
    required this.title,
    required this.currentWeight,
    required this.weightUnit,
    required this.changeText,
    required this.chartData,
    this.isWeightLoss = true,
    this.titleImage = "assets/images/heartbeat.svg",
    this.titleIconColor = const Color(0xFFEF4444),
    this.titleIconBackgroundColor = const Color(0xFFFEE2E2),
    this.changeTextColor = const Color(0xFF00B945),
    this.chartLineColor = const Color(0xFF862633),
    this.chartPointColor = const Color(0xFF862633),
    this.backgroundColor = Colors.white,
    this.titleTextColor = const Color(0xFF4B5563),
    this.weightTextColor = Colors.black87,
    this.chartLabelColor = Colors.grey,
    this.axisColor = const Color(0xFFE2E8F0),
    this.gridColor = const Color(0xFFF7FAFC),
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(0),
    this.showGrid = true,
    this.showYAxisLabels = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF3F4F6),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              // Icon
              Container(
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: titleIconBackgroundColor,
    borderRadius: BorderRadius.circular(32),
  ),
  child: SvgPicture.asset(
    titleImage, // path to your SVG asset
    color: titleIconColor,
    width: 20,
    height: 20,
  ),
),


              const SizedBox(width: 12),

              // Title and weight
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: titleTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: currentWeight,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: weightTextColor,
                            ),
                          ),
                          TextSpan(
                            text: ' $weightUnit',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Color(0xFF444444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Change indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: changeTextColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  changeText,
                  style:  GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart with axes
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: LineChartPainter(
                data: chartData,
                lineColor: chartLineColor,
                pointColor: chartPointColor,
                labelColor: chartLabelColor,
                axisColor: axisColor,
                gridColor: gridColor,
                showGrid: showGrid,
                showYAxisLabels: showYAxisLabels,
                weightUnit: weightUnit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color lineColor;
  final Color pointColor;
  final Color labelColor;
  final Color axisColor;
  final Color gridColor;
  final bool showGrid;
  final bool showYAxisLabels;
  final String weightUnit;

  LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.pointColor,
    required this.labelColor,
    required this.axisColor,
    required this.gridColor,
    required this.showGrid,
    required this.showYAxisLabels,
    required this.weightUnit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Define margins for axes
    final double leftMargin =
        showYAxisLabels ? 40.0 : 10.0; // Space for Y-axis labels only if shown
    const double bottomMargin = 30.0; // Space for X-axis labels
    const double topMargin = 10.0;
    const double rightMargin = 10.0;

    // Calculate chart area
    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;
    final chartLeft = leftMargin;
    final chartTop = topMargin;
    final chartRight = chartLeft + chartWidth;
    final chartBottom = chartTop + chartHeight;

    // Paint for axes
    final axisPaint =
        Paint()
          ..color = axisColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Paint for grid lines
    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Paint for data line
    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    // Paint for data points
    final pointPaint =
        Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill;

    final pointBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Find min and max values for scaling
    final values = data.map((e) => e.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final valueRange = maxValue - minValue;

    // Add some padding to the value range
    final paddedRange = valueRange * 0.1;
    final adjustedMin = minValue - paddedRange;
    final adjustedMax = maxValue + paddedRange;
    final adjustedRange = adjustedMax - adjustedMin;

    // Draw Y-axis
    canvas.drawLine(
      Offset(chartLeft, chartTop),
      Offset(chartLeft, chartBottom),
      axisPaint,
    );

    // Draw X-axis
    canvas.drawLine(
      Offset(chartLeft, chartBottom),
      Offset(chartRight, chartBottom),
      axisPaint,
    );

    // Draw grid lines and Y-axis labels
    if (showGrid || showYAxisLabels) {
      const int gridLines = 4;
      for (int i = 0; i <= gridLines; i++) {
        final y = chartBottom - (i / gridLines) * chartHeight;
        final value = adjustedMin + (i / gridLines) * adjustedRange;

        // Draw horizontal grid line
        if (showGrid && i > 0 && i < gridLines) {
          canvas.drawLine(
            Offset(chartLeft, y),
            Offset(chartRight, y),
            gridPaint,
          );
        }

        // Draw Y-axis label
        if (showYAxisLabels) {
          textPainter.text = TextSpan(
            text: value.toStringAsFixed(1),
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          );
          textPainter.layout();

          final labelX = chartLeft - textPainter.width - 8;
          final labelY = y - (textPainter.height / 2);
          textPainter.paint(canvas, Offset(labelX, labelY));
        }
      }
    }

    // Calculate data points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = chartLeft + (i / (data.length - 1)) * chartWidth;
      final normalizedValue =
          adjustedRange == 0
              ? 0.5
              : (data[i].value - adjustedMin) / adjustedRange;
      final y = chartBottom - (normalizedValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw vertical grid lines for X-axis
    if (showGrid) {
      for (int i = 0; i < points.length; i++) {
        if (i > 0 && i < points.length - 1) {
          canvas.drawLine(
            Offset(points[i].dx, chartTop),
            Offset(points[i].dx, chartBottom),
            gridPaint,
          );
        }
      }
    }

    // Draw data line with smooth curves
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        // Create smooth curve between points
        if (i == 1) {
          path.lineTo(points[i].dx, points[i].dy);
        } else {
          final controlPoint1 = Offset(
            points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.3,
            points[i - 1].dy,
          );
          final controlPoint2 = Offset(
            points[i].dx - (points[i].dx - points[i - 1].dx) * 0.3,
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
      canvas.drawPath(path, linePaint);
    }

    // Draw data points
    for (int i = 0; i < points.length; i++) {
      // Draw white border around point
      canvas.drawCircle(points[i], 5, pointBorderPaint);
      // Draw colored point
      canvas.drawCircle(points[i], 3.5, pointPaint);
    }

    // Draw X-axis labels
    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          color: labelColor,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();

      final labelX = points[i].dx - (textPainter.width / 2);
      final labelY = chartBottom + 8;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // Draw Y-axis unit label
    if (showYAxisLabels) {
      textPainter.text = TextSpan(
        text: weightUnit,
        style: TextStyle(
          color: labelColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(8, chartTop + chartHeight / 2);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
