import 'package:flutter/material.dart';

class PreferenceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String infoText;
  final String buttonText;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? leadingIconColor;
  final Color? trailingIconColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color infoTextColor;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onTrailingIconPressed;

  const PreferenceCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.infoText,
    required this.buttonText,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingIconColor,
    this.trailingIconColor,
    this.buttonColor = const Color(0xFF8B5A3C),
    this.buttonTextColor = Colors.white,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.titleColor = const Color(0xFF8B5A3C),
    this.subtitleColor = Colors.black87,
    this.infoTextColor = Colors.black54,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(0),
    this.onButtonPressed,
    this.onTrailingIconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and trailing icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              if (trailingIcon != null)
                GestureDetector(
                  onTap: onTrailingIconPressed,
                  child: Icon(
                    trailingIcon,
                    color: trailingIconColor ?? titleColor,
                    size: 20,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info row with leading icon and text
          Row(
            children: [
              if (leadingIcon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: leadingIconColor ?? titleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    leadingIcon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  infoText,
                  style: TextStyle(
                    fontSize: 14,
                    color: infoTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}