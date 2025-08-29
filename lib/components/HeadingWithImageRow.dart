import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeadingWithImageRow extends StatelessWidget {
  final String heading;
  final String subtitle;
  final String? imagePath; // local asset or network path
  final bool isAsset; // true for local assets, false for network images
  final Widget? trailingWidget; // optional trailing widget (icon or any)

  const HeadingWithImageRow({
    Key? key,
    required this.heading,
    required this.subtitle,
    this.imagePath,
    this.isAsset = true,
    this.trailingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFAFBFB)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Texts on Left
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF862633),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black
                                          ,fontWeight: FontWeight.w400,),
                  ),
                ],
              ),
            ),
        
            // Trailing widget (icon or image)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: trailingWidget ??
                  (imagePath != null
                      ? (isAsset
                          ? Image.asset(
                              imagePath!,
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              imagePath!,
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ))
                      : const SizedBox()),
            ),
          ],
        ),
      ),
    );
  }
}
