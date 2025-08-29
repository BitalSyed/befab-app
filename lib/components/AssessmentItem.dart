import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

enum AssessmentIconType { clock, check, calendar, star, target, alert, play, pause }

enum AssessmentStatus { completed, pending, inProgress, overdue, scheduled }

class AssessmentItem extends StatelessWidget {
  final String title;
  final String statusText;
  final AssessmentIconType iconType;
  final AssessmentStatus status;
  final Color? titleColor;
  final Color? statusColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showChevron;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AssessmentItem({
    Key? key,
    this.title = "Weekly Fitness Assessment",
    this.statusText = "Completed On 17, 2025",
    this.iconType = AssessmentIconType.clock,
    this.status = AssessmentStatus.completed,
    this.titleColor,
    this.statusColor,
    this.iconColor,
    this.backgroundColor,
    this.showChevron = true,
    this.onTap,
    this.padding,
    this.margin,
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFFFAFBFB),
        borderRadius: BorderRadius.circular(8),
        boxShadow: backgroundColor != null ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF862633),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset("assets/images/clock.svg"),
                          SizedBox(width: 8,),
                          Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                        
                            color: Colors.black,
                          ),
                        ),
                        ]
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                if (showChevron)
                  Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Color(0xFF862633),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}