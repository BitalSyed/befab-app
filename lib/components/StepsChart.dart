import 'package:flutter/material.dart';

class StepsChart extends StatelessWidget {
  const StepsChart({super.key});

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
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '30d',
              style: TextStyle(color: Color(0xFF638773)),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartRow(context, '0', 0.95),
          const SizedBox(height: 16),
          _buildChartRow(context, '2.5k', 0.25),
          const SizedBox(height: 16),
          _buildChartRow(context, '5k', 0.50),
          const SizedBox(height: 16),
          _buildChartRow(context, '7.5k', 0.75),
          const SizedBox(height: 16),
          _buildChartRow(context, '10k', 0.40),
        ],
      ),
    );
  }

  Widget _buildChartRow(BuildContext context, String label, double progress) {
    return Row(
      children: [
        // Label
        SizedBox(
          width: 35,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF638773),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Progress bar with vertical indicator
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final indicatorLeft = barWidth * progress;

              return Stack(
                children: [
                  // Background bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                  // Progress bar
                  if (progress > 0)
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  // Vertical indicator line at end of progress
                  if (progress > 0)
                    Positioned(
                      left: indicatorLeft - 1, // Adjust to center the 1px line
                      top: -2,
                      child: Container(
                        width: 1,
                        height: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
