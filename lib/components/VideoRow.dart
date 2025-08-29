import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VideoRow extends StatelessWidget {
  const VideoRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Video dropdown with rectangular container
          GestureDetector(
            onTap: () {
              // Handle dropdown tap
              print('Video dropdown tapped');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6.0),
                
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Video',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
          // SVG icon in circular container
          GestureDetector(
            onTap: () {
              // Handle copy tap
              print('Copy icon tapped');
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Color(0xFFE9E9E9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/copy.svg', // Replace with your SVG path
                  width: 16.0,
                  height: 16.0,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}