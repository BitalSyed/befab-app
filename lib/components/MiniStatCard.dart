import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class MiniHealthStat {
  final String image;
  final Color imageColor;
  final Color imageBgColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final String unit;

  MiniHealthStat({
    required this.image,
    required this.imageColor,
    required this.imageBgColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.unit,
  });
}

class MiniStatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const MiniStatsGrid({
    super.key,
    required this.stats,
  });


  @override
  Widget build(BuildContext context) {
  final List<MiniHealthStat> miniStats = [
    MiniHealthStat(
      image: "assets/images/heartbeat.svg",
      imageColor: Color(0xFF862633),
      imageBgColor: const Color.fromRGBO(134, 38, 51, 0.2),      
      backgroundColor: Color.fromRGBO(134, 38, 51, 0.05),
      label: 'Heart Rate',
      value: stats['h']?['data'] ?? '--',
      unit: stats['h']?['unit'] ?? '--',
    ),
    MiniHealthStat(
      image: "assets/images/steps.svg",
      imageColor: Color(0xFF2563EB),
      imageBgColor: const Color.fromRGBO(37, 99, 235, 0.2),
      backgroundColor: Color.fromRGBO(37, 99, 235, 0.06),
      label: 'Steps',
      value: stats['s']?['data'] ?? '--',
      unit: '',
    ),
    MiniHealthStat(
      image: "assets/images/fire.svg",
      imageColor: Color(0xFF16A34A),
      imageBgColor: const Color.fromRGBO(22, 163, 74, 0.2),
      backgroundColor: Color.fromRGBO(22, 163, 74, 0.05),
      label: 'Calories',
      value: stats['calories']?['data'] ?? '--',
      unit: '',
    ),
    MiniHealthStat(
      image: "assets/images/moon.svg",
      imageColor: Color(0xFF9333EA),
      imageBgColor: const Color.fromRGBO(147, 51, 234, 0.2),
      backgroundColor: Color.fromRGBO(147, 51, 234, 0.06),
      label: 'Sleep',
      value: stats['sleep']?['data'] ?? '--',
      unit: stats['sleep']?['unit'] ?? '--',
    ),
  ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2, // Width:Height ratio
      children: miniStats
          .map((stat) => MiniStatCard(stat: stat))
          .toList(),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final MiniHealthStat stat;

  const MiniStatCard({Key? key, required this.stat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        decoration: BoxDecoration(
          color: stat.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon container
            Container(
  width: 36,  // reduced from 36
  height: 36,
  decoration: BoxDecoration(
    color: stat.imageBgColor,
    shape: BoxShape.circle,
  ),
  child: Center(
    child: SvgPicture.asset(
      stat.image,
      color: stat.imageColor,
      width: 22,  // reduced from 18
      height: 22,
    ),
  ),
),

            const SizedBox(width: 12),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4E4E4E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: stat.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (stat.unit.isNotEmpty)
                          TextSpan(
                            text: ' ${stat.unit}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}