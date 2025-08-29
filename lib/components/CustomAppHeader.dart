import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leftWidget;
  final VoidCallback? onLeftTap;
  final String title;
  final TextStyle? titleStyle;
  final Widget? rightWidget;
  final VoidCallback? onRightTap;
  final Color backgroundColor;
  final bool showShadow;

  const CustomAppBar({
    super.key,
    this.leftWidget,
    this.onLeftTap,
    this.title = "",
    this.titleStyle,
    this.rightWidget,
    this.onRightTap,
    this.backgroundColor = Colors.white,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24,bottom: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      height: preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onLeftTap,
            child: leftWidget ?? SizedBox(width: 24),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: titleStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRightTap,
            child: rightWidget ?? SizedBox(width: 24),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}
