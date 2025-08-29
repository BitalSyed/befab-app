import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostOptionsComponent extends StatelessWidget {
  const PostOptionsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          

          // Location option
          _buildOptionTile(
            svgPath: "assets/images/location.svg",
            title: "Add location",
            onTap: () {
              // Handle location tap
              Navigator.pop(context);
              print("Add location tapped");
            },
          ),
          const SizedBox(height: 4),
          Divider(color: Color(0xFFE3E3E3),thickness: 2,),
                    const SizedBox(height: 4),
          // Tag people option
          _buildOptionTile(
            svgPath: "assets/images/man.svg",
            title: "Tag people",
            onTap: () {
              // Handle tag people tap
              Navigator.pop(context);
              print("Tag people tapped");
            },
          ),
          const SizedBox(height: 4),
          Divider(color: Color(0xFFE3E3E3),thickness: 2,),
                    const SizedBox(height: 4),
          // Add music option
          _buildOptionTile(
            svgPath: "assets/images/music.svg",
            title: "Add music",
            onTap: () {
              // Handle add music tap
              Navigator.pop(context);
              print("Add music tapped");
            },
          ),
          const SizedBox(height: 4),
          Divider(color: Color(0xFFE3E3E3),thickness: 2,),
                    const SizedBox(height: 4),
          // Advanced settings option
          _buildOptionTile(
            svgPath: "assets/images/settings2.svg",
            title: "Advanced settings",
            onTap: () {
              // Handle advanced settings tap
              Navigator.pop(context);
              print("Advanced settings tapped");
            },
          ),
          // Bottom padding for safe area
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
  required String svgPath, // 👈 instead of IconData
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            svgPath,
            width: 24,
            height: 24,
            color: Colors.black87, // 👈 optional (applies tint color)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}