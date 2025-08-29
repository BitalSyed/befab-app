import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class ActivityMetric {
  final String image;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final String description;

  const ActivityMetric({
    required this.image,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.description,
  });
}

class ActivityMetricsWidget extends StatelessWidget {
  final String title;
  final List<ActivityMetric> metrics;
  final TextStyle? titleStyle;
  final TextStyle? metricTitleStyle;
  final TextStyle? metricSubtitleStyle;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;
  final TextStyle? descriptionStyle;
  final double spacing;
  final double iconSize;
  final double iconContainerSize;
  final EdgeInsets padding;
  final CrossAxisAlignment alignment;

  const ActivityMetricsWidget({
    Key? key,
    required this.title,
    required this.metrics,
    this.titleStyle,
    this.metricTitleStyle,
    this.metricSubtitleStyle,
    this.valueStyle,
    this.unitStyle,
    this.descriptionStyle,
    this.spacing = 24.0,
    this.iconSize = 24.0,
    this.iconContainerSize = 48.0,
    this.padding = const EdgeInsets.all(16.0),
    this.alignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Title
          Text(
            title,
            style: titleStyle ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
          ),
          SizedBox(height: spacing),
          
          // Metrics Grid
          if (metrics.length == 2)
            Row(
              children: [
                Expanded(child: _buildMetricItem(metrics[0])),
                SizedBox(width: spacing),
                Expanded(child: _buildMetricItem(metrics[1])),
              ],
            )
          else
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: metrics.map((metric) => _buildMetricItem(metric)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(ActivityMetric metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon and Title Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container
            Container(
  width: iconContainerSize, // keep or reduce if needed
  height: iconContainerSize,
  decoration: BoxDecoration(
    color: metric.iconBackgroundColor,
    shape: BoxShape.circle,
  ),
  child: Center(
    child: SvgPicture.asset(
      metric.image,
      color: metric.iconColor,
      width: 32, // Reduced from 18
      height: 32,
    ),
  ),
),

            const SizedBox(width: 12),
            
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${metric.title} ${metric.subtitle}" ,
                    style: metricTitleStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Value and Unit
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              metric.value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            if (metric.unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                metric.unit,
                style: unitStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF878686),
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        
        // Description
        Text(
          metric.description,
          style: descriptionStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
