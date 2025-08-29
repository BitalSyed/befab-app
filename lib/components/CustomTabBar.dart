import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class TabItem {
  final String label;
  final String image;

  TabItem({required this.label, required this.image});
}

class CustomTabBar extends StatefulWidget {
  final List<TabItem> tabs;
  final List<String> routes;

  final Color selectedColor;
  final Color unselectedColor;
  final Function(int)? onTabChanged;
  final double underlineWidth;
  final int selectedIndex;

const CustomTabBar({
  Key? key,
  required this.tabs,
  required this.routes, // new
  this.selectedColor = const Color(0xFF862633),
  this.unselectedColor = const Color(0xFF9CA3AF),
  this.onTabChanged,
  this.underlineWidth = 200,
  this.selectedIndex = 0,
}) : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  void _onTabTap(int index) {
  setState(() {
    selectedIndex = index;
  });
  if (widget.onTabChanged != null) {
    widget.onTabChanged!(index);
  }

  if (index < widget.routes.length) {
    Navigator.pushNamed(context, widget.routes[index]);
  }
}


  @override
Widget build(BuildContext context) {
  double screenHalfWidth = MediaQuery.of(context).size.width / 2;

  return Container(
    color: Colors.white,
    child: Row(
      children: List.generate(widget.tabs.length, (index) {
        final tab = widget.tabs[index];
        final isSelected = selectedIndex == index;
        final underlineColor = isSelected
            ? widget.selectedColor
            : widget.unselectedColor;

        return Expanded(
          child: GestureDetector(
            onTap: () => _onTabTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      tab.image,
                      height: 24,
                      width: 24,
                      color: isSelected
                          ? widget.selectedColor
                          : widget.unselectedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected
                            ? widget.selectedColor
                            : widget.unselectedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Gap between text and underline
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 1.2,
                  width: screenHalfWidth,
                  color: underlineColor,
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

}
