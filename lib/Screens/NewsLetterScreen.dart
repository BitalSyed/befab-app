import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class NewsletterScreen extends StatelessWidget {
  const NewsletterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/images/mobile.svg'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 10),
          child: RichText(
            textAlign: TextAlign.center,
            text:  TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text: 'APP CONTENT AREA\n\n',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'The dock navigation is displayed in the bottom',
                  style: GoogleFonts.inter(color: Color(0xFF4E4E4E),fontSize: 17,fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: IconButton(
          icon: const Icon(
            Icons.add_circle,
            size: 70,
            color: Color(0xFF862633),
          ),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
);

  }
}

