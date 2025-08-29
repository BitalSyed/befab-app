import 'package:flutter/material.dart';

class BodyMetric {
  final String label;
  final String value;
  final String unit;
  final String? changeText;
  final Color? changeColor;
  final String? status;
  final Color? statusColor;
  final String? additionalInfo;
  final Color? additionalInfoColor;

  const BodyMetric({
    required this.label,
    required this.value,
    this.unit = '',
    this.changeText,
    this.changeColor,
    this.status,
    this.statusColor,
    this.additionalInfo,
    this.additionalInfoColor,
  });
}

class BodyMetricsWidget extends StatelessWidget {
  final List<BodyMetric> primaryMetrics; // Weight and Height (top row)
  final List<BodyMetric> secondaryMetrics; // BMI, Weight%, Weight% (middle row)
  final List<BodyMetric> tertiaryMetrics; // Bone Mass, Water, Visceral Fat (bottom row)
  final EdgeInsets padding;
  final double spacing;
  final double verticalSpacing;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;
  final TextStyle? changeStyle;
  final TextStyle? statusStyle;
  final TextStyle? additionalInfoStyle;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const BodyMetricsWidget({
    Key? key,
    required this.primaryMetrics,
    required this.secondaryMetrics,
    required this.tertiaryMetrics,
    this.padding = const EdgeInsets.all(20.0),
    this.spacing = 16.0,
    this.verticalSpacing = 24.0,
    this.labelStyle,
    this.valueStyle,
    this.unitStyle,
    this.changeStyle,
    this.statusStyle,
    this.additionalInfoStyle,
    this.backgroundColor = Colors.white,
    this.borderRadius,
    this.boxShadow,
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
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Column(
          children: [
            // Primary metrics row (Weight and Height)
            Row(
              children: primaryMetrics.asMap().entries.map((entry) {
                final index = entry.key;
                final metric = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0) SizedBox(width: spacing),
                      Expanded(child: _buildPrimaryMetric(metric)),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Divider(color: Color(0xFFF3F4F6),),
            ),
            // Secondary metrics row (BMI, Weight%, Weight%)
            Row(
              children: secondaryMetrics.asMap().entries.map((entry) {
                final index = entry.key;
                final metric = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0) SizedBox(width: spacing),
                      Expanded(child: _buildSecondaryMetric(metric)),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Divider(color: Color(0xFFF3F4F6),),
            ),
            // Tertiary metrics row (Bone Mass, Water, Visceral Fat)
            Row(
              children: tertiaryMetrics.asMap().entries.map((entry) {
                final index = entry.key;
                final metric = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0) SizedBox(width: spacing),
                      Expanded(child: _buildTertiaryMetric(metric)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryMetric(BodyMetric metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          metric.label,
          style: labelStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        
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
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            if (metric.unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                metric.unit,
                style: unitStyle ??
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        
        // Change text or additional info
        if (metric.changeText != null)
          Text(
            metric.changeText!,
            style: changeStyle ??
                TextStyle(
                  fontSize: 12,
                  color: metric.changeColor ?? const Color(0xFF4CAF50),
                ),
          )
        else if (metric.additionalInfo != null)
          Text(
            metric.additionalInfo!,
            style: additionalInfoStyle ??
                TextStyle(
                  fontSize: 12,
                  color: metric.additionalInfoColor ?? Colors.grey[600],
                ),
          ),
      ],
    );
  }

  Widget _buildSecondaryMetric(BodyMetric metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Text(
          metric.label,
          style: labelStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        
        // Value and Unit
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              metric.value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            if (metric.unit.isNotEmpty) ...[
              Text(
                metric.unit,
                style: unitStyle ??
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        
        // Status badge or additional info
        if (metric.status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (metric.statusColor ?? const Color(0xFF4CAF50)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metric.status!,
              style: statusStyle ??
                  TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: metric.statusColor ?? const Color(0xFF4CAF50),
                  ),
            ),
          )
        else if (metric.additionalInfo != null)
          Text(
            metric.additionalInfo!,
            style: additionalInfoStyle ??
                TextStyle(
                  fontSize: 12,
                  color: metric.additionalInfoColor ?? Colors.grey[600],
                ),
          ),
      ],
    );
  }

  Widget _buildTertiaryMetric(BodyMetric metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Text(
          metric.label,
          style: labelStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        
        // Value and Unit
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              metric.value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            if (metric.unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                metric.unit,
                style: unitStyle ??
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// Simplified version with automatic layout
class SimpleBodyMetricsWidget extends StatelessWidget {
  final List<BodyMetric> metrics;
  final int itemsPerRow;
  final EdgeInsets padding;
  final double spacing;
  final double verticalSpacing;

  const SimpleBodyMetricsWidget({
    Key? key,
    required this.metrics,
    this.itemsPerRow = 3,
    this.padding = const EdgeInsets.all(20.0),
    this.spacing = 16.0,
    this.verticalSpacing = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rows = <List<BodyMetric>>[];
    for (int i = 0; i < metrics.length; i += itemsPerRow) {
      rows.add(metrics.sublist(i, (i + itemsPerRow).clamp(0, metrics.length)));
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: rows.asMap().entries.map((rowEntry) {
          final rowIndex = rowEntry.key;
          final row = rowEntry.value;
          
          return Column(
            children: [
              if (rowIndex > 0) SizedBox(height: verticalSpacing),
              Row(
                children: row.asMap().entries.map((entry) {
                  final index = entry.key;
                  final metric = entry.value;
                  return Expanded(
                    child: Row(
                      children: [
                        if (index > 0) SizedBox(width: spacing),
                        Expanded(child: _buildMetric(metric)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetric(BodyMetric metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (metric.unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                metric.unit,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (metric.status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (metric.statusColor ?? const Color(0xFF4CAF50)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metric.status!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: metric.statusColor ?? const Color(0xFF4CAF50),
              ),
            ),
          )
        else if (metric.changeText != null)
          Text(
            metric.changeText!,
            style: TextStyle(
              fontSize: 12,
              color: metric.changeColor ?? const Color(0xFF4CAF50),
            ),
          )
        else if (metric.additionalInfo != null)
          Text(
            metric.additionalInfo!,
            style: TextStyle(
              fontSize: 12,
              color: metric.additionalInfoColor ?? Colors.grey[600],
            ),
          ),
      ],
    );
  }
}