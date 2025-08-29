import 'package:flutter/material.dart';

class MetricsOverview extends StatelessWidget {
  final Map<String, Map<String, dynamic>> healthData;

  const MetricsOverview({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: healthData.entries.map((entry) {
          final label = entry.key;
          final data = entry.value['data'];
          final unit = entry.value['unit'] ?? '';
          return _buildMetricItem(label, data, unit);
        }).toList(),
      ),
    );
  }

  Widget _buildMetricItem(String label, dynamic data, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFAFBFB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$data$unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
