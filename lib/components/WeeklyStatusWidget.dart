import 'package:flutter/material.dart';

class WeeklyStatusWidget extends StatelessWidget {
  final String title;
  final String viewAllText;
  final List<String> weekDays;
  final String averageLabel;
  final String averageValue;
  final String averageUnit;
  final String goalLabel;
  final String goalValue;
  final String goalUnit;
  final VoidCallback? onViewAllTap;
  final Color? titleColor;
  final Color? viewAllColor;
  final Color? averageColor;
  final Color? goalColor;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? dayStyle;
  final TextStyle? averageStyle;
  final TextStyle? goalStyle;

  const WeeklyStatusWidget({
    Key? key,
    this.title = 'Weekly Status',
    this.viewAllText = 'View all',
    this.weekDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.averageLabel = 'Average',
    this.averageValue = '1750',
    this.averageUnit = 'ml',
    this.goalLabel = 'Goal',
    this.goalValue = '2000',
    this.goalUnit = 'ml',
    this.onViewAllTap,
    this.titleColor,
    this.viewAllColor,
    this.averageColor,
    this.goalColor,
    this.backgroundColor,
    this.titleStyle,
    this.dayStyle,
    this.averageStyle,
    this.goalStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and "View all"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: titleStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF8B4513),
                    ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  viewAllText,
                  style: TextStyle(
                    fontSize: 14,
                    color: viewAllColor ?? const Color(0xFF8B4513),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 90),
          
          // Week days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              return Text(
                day,
                style: dayStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 30),
          
          // Average and Goal row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$averageLabel:',
                      style: averageStyle ??
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: averageColor ?? const Color(0xFF8B4513),
                          ),
                    ),
                    TextSpan(
                      text: '$averageValue $averageUnit',
                      style: averageStyle ??
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: averageColor ?? const Color(0xFF8B4513),
                          ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$goalLabel: ',
                      style: goalStyle ??
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: goalColor ?? const Color(0xFF8B4513),
                          ),
                    ),
                    TextSpan(
                      text: '$goalValue $goalUnit',
                      style: goalStyle ??
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: goalColor ?? const Color(0xFF8B4513),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}