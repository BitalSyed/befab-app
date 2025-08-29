import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class HealthMetric {
  final String image;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String timestamp;
  final String value;
  final String unit;
  final VoidCallback? onTap;
  final bool isTrue;

  const HealthMetric({
    required this.image,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.timestamp,
    required this.value,
    this.unit = '',
    this.onTap,
    this.isTrue = false
    
  });
}

class HealthMetricsListWidget extends StatelessWidget {
  final List<HealthMetric> metrics;
  final EdgeInsets padding;
  final double itemSpacing;
  final double iconSize;
  final double iconContainerSize;
  final TextStyle? titleStyle;
  final TextStyle? timestampStyle;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool showDividers;
  final Color? dividerColor;
  const HealthMetricsListWidget({
    Key? key,
    required this.metrics,
    this.padding = const EdgeInsets.all(16.0),
    this.itemSpacing = 16.0,
    this.iconSize = 20.0,
    this.iconContainerSize = 40.0,
    this.titleStyle,
    this.timestampStyle,
    this.valueStyle,
    this.unitStyle,
    this.backgroundColor = Colors.white,
    this.borderRadius,
    this.boxShadow,
    this.showDividers = false,
    this.dividerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFF3F4F6))
        ),
        child: Column(
          children: metrics.asMap().entries.map((entry) {
            final index = entry.key;
            final metric = entry.value;
            final isLast = index == metrics.length - 1;
            
            return Column(
              children: [
                if (index > 0) SizedBox(height: itemSpacing),
                _buildMetricItem(metric),
                if (showDividers && !isLast) ...[
                  SizedBox(height: itemSpacing),
                  Divider(
                    color: dividerColor ?? Colors.grey[200],
                    height: 1,
                  ),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMetricItem(HealthMetric metric) {
    return InkWell(
      onTap: metric.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Icon container
            Container(
  width: iconContainerSize, // e.g., 48 or 40
  height: iconContainerSize,
  decoration: BoxDecoration(
    color: metric.iconBackgroundColor,
    shape: BoxShape.circle,
  ),
  child: metric.isTrue? Center( // Center the icon inside the circle
    child: Image.asset(
      metric.image,
      color: metric.iconColor,
      width: 20,   // smaller than container
      height: 20,  // adjust as needed
    ),
  ):Center( // Center the icon inside the circle
    child: SvgPicture.asset(
      metric.image,
      color: metric.iconColor,
      width: 20,   // smaller than container
      height: 20,  // adjust as needed
    ),
  ),
),

            const SizedBox(width: 16),
            
            // Title and timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.title,
                    style: titleStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.timestamp,
                    style: timestampStyle ??
                        TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,

                          color: Colors.grey[400],
                        ),
                  ),
                ],
              ),
            ),
            
            // Value and unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  metric.value,
                  style: valueStyle ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                if (metric.unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    metric.unit,
                    style: unitStyle ??
                        const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}