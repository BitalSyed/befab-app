import 'package:flutter/material.dart';

class ProgressSummaryWidget extends StatelessWidget {
  final String title;
  final int consumed;
  final int goal;
  final int? burned;
  final Color progressColor;
  final Color backgroundColor;
  final String? unit;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final double progressBarHeight;
  final BorderRadius? progressBarBorderRadius;

  const ProgressSummaryWidget({
    Key? key,
    required this.title,
    required this.consumed,
    required this.goal,
    this.burned,
    this.progressColor = Colors.red,
    this.backgroundColor = Colors.grey,
    this.unit,
    this.titleStyle,
    this.valueStyle,
    this.labelStyle,
    this.progressBarHeight = 8.0,
    this.progressBarBorderRadius,
  }) : super(key: key);

  double get progressPercentage => (consumed / goal).clamp(0.0, 1.0);
  int get remaining => (goal - consumed).clamp(0, goal);
  int get net => consumed - (burned ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTitleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Color(0xFF862633),
    );
    final defaultValueStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color(0xFF000000),
    );
    final defaultLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Color(0xFF000000),
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );
    final defaultLabel2Style = theme.textTheme.bodyMedium?.copyWith(
      color: Color(0xFF862633),
      fontWeight: FontWeight.w400,
      fontSize: 16,
    );

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFFFAFBFB),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFAFBFB),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: titleStyle ?? defaultTitleStyle,
              ),
              Text(
                '${(progressPercentage * 100).toInt()}% Of Goal',
                style: (labelStyle ?? defaultLabelStyle)!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000)
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress section with consumed and goal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${consumed} Consumed',
                style: valueStyle ?? defaultValueStyle,
              ),
              Text(
                '${goal} goal',
                style: labelStyle ?? defaultLabelStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          Container(
            height: progressBarHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: progressBarBorderRadius ?? 
                BorderRadius.circular(progressBarHeight / 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF862633),
                  borderRadius: progressBarBorderRadius ?? 
                    BorderRadius.circular(progressBarHeight / 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats section
          Column(
            children: [
              _buildStatRow('Remaining', remaining, unit, labelStyle ?? defaultLabel2Style!, valueStyle ?? defaultValueStyle!),
              if (burned != null) ...[
                const SizedBox(height: 8),
                _buildStatRow('Burned', burned!, unit, labelStyle ?? defaultLabel2Style!, valueStyle ?? defaultValueStyle!),
                const SizedBox(height: 8),
                _buildStatRow('Net', net, unit, labelStyle ?? defaultLabel2Style!, valueStyle ?? defaultValueStyle!),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, String? unit, TextStyle labelStyle, TextStyle valueStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(
          '${value}',
          style: valueStyle,
        ),
      ],
    );
  }
}