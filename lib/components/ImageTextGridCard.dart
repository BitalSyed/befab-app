import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class ImageTextGridItemCards extends StatelessWidget {
  final List<Map<String, dynamic>> items; // Each item: {'image': Image, 'text': String, 'imageBgColor': Color}
  final Color imageBgColor;

  const ImageTextGridItemCards({
    Key? key,
    required this.items,
    this.imageBgColor = const Color(0xFFE5E7EB),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 140,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: item['imageBgColor'] ?? imageBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SizedBox(
                            height: 30,
                            child: item['image'] as SvgPicture,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['text'] ?? '',
                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item['a'] ?? '',
                        style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
