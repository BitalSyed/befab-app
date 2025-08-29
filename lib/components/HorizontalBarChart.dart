
import 'package:flutter/material.dart';

class BarChartItem {
  final String label;
  final double value;
  final double maxValue;
  final Color barColor;
  final String? displayValue;

  BarChartItem({
    required this.label,
    required this.value,
    required this.maxValue,
    this.barColor = const Color(0xFFE5E7EB), // gray-200
    this.displayValue,
  });

  double get progress => maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
  String get formattedValue => displayValue ?? value.toString();
}

class HorizontalBarChart extends StatelessWidget {
  final List<BarChartItem> items;
  final double barHeight;
  final double spacing;
  final double labelWidth;
  final double valueWidth;
  final Color backgroundColor;
  final Color barBackgroundColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showGrid;
  final Color gridColor;

  const HorizontalBarChart({
    Key? key,
    required this.items,
    this.barHeight = 16.0,
    this.spacing = 16.0,
    this.labelWidth = 40.0,
    this.valueWidth = 60.0,
    this.backgroundColor = Colors.transparent,
    this.barBackgroundColor = const Color(0xFFE5E7EB), // gray-200
    this.labelStyle,
    this.valueStyle,
    this.padding,
    this.margin,
    this.showGrid = false,
    this.gridColor = const Color(0xFFE5E7EB),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[700],
      fontWeight: FontWeight.w400,
    );
    

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: backgroundColor != Colors.transparent ? BorderRadius.circular(8) : null,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Row(
                children: [
                  // Label
                  SizedBox(
                    width: labelWidth,
                    child: Text(
                      item.label,
                      style: labelStyle ?? defaultLabelStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Bar
                  Expanded(
                    child: Stack(
                      children: [
                        // Background bar
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barBackgroundColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Progress bar
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item.progress,
                          child: Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: item.barColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Grid lines (optional)
                        if (showGrid) ...[
                          Positioned.fill(
                            child: Row(
                              children: List.generate(5, (i) => Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: gridColor,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  

                ],
              ),
              if (!isLast) SizedBox(height: spacing),
            ],
          );
        }).toList(),
      ),
    );
  }
}