// single_video_screen.dart
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:google_fonts/google_fonts.dart';
class SingleReel extends StatelessWidget {
  const SingleReel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: Container(
      margin: const EdgeInsets.only(top: 10), // 👈 add top margin
      child: AppBar(
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  leadingWidth: 310, // give more room for cross + InfoTile
  leading: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const SizedBox(width: 8),
      Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/cross.svg',
            color: Color(0xFF4B5563),
            width: 12,
            height: 12,
          ),
        ),
      ),
      const SizedBox(width: 24), // spacing between cross & InfoTile
      Expanded(
        child: InfoTile(
          title: "Suggested audio",
          subtitle: "Tap to apply",
          image: "assets/images/music.svg",
          isAssetImage: false,
          iconBgColor: Color(0xFFE9D5FF),
          onTap: () {
            print("Vehicle tapped!");
          },
        ),
      ),
    ],
  ),
  centerTitle: false, // so it stays aligned with leading
)

    ),
  ),


      body: Column(
  children: [
    Expanded(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/FRAME10.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ✅ keep IconsRow inside the stack
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: IconsRow(),
            ),
          ),
        ],
      ),
    ),

    // ✅ buttons row now outside the stack
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // First Button (Edit Video + NEW)
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3F4F6),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Edit Video',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFf0e4e4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'NEW',
              style: TextStyle(
                color: Color(0xFF862633),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 12),

    // Second Button (Next)
    ElevatedButton(
      onPressed: () {
                        Navigator.pushNamed(context, '/dashboard');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF862633),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Next'),
          const SizedBox(width: 6),
          SvgPicture.asset(
            'assets/images/rightarrow.svg',
            width: 14,
            height: 14,
          ),
        ],
      ),
    ),
  ],
)

    ),
  ],
),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 11), // adjust as needed
        child: SizedBox(
          width: 70,
          height: 70,
          child: IconButton(
            icon: const Icon(
              Icons.add_circle,
              size: 70,
              color: Color(0xFF862633),
            ),
          onPressed: () {
            Navigator.pushNamed(context, "/all-reels");
          },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }
}

class IconsRow extends StatelessWidget {
  const IconsRow({super.key});

  final List<String> icons = const [
    'assets/images/i1.svg',
    'assets/images/i2.svg',
    'assets/images/i3.svg',
    'assets/images/i4.svg',
    'assets/images/i5.svg',
    'assets/images/i6.svg',
    'assets/images/i7.svg',

  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFFFFF)),
          ),
          child: Row(
            children: icons.map((icon) {
              return Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    icon,
                    height: 22,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF111827), // fixed color
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}




class InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool isAssetImage; 
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const InfoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    this.isAssetImage = true,
    this.iconBgColor = const Color(0xFFE5E7EB),
    this.iconColor = const Color(0xFF9333EA),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 👈 shrink-wrap width
          children: [
            // Icon container
            Container(
              width: 28,
              height: 24,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isAssetImage
                    ? Image.asset(image, width: 18, height: 16, color: iconColor)
                    : SvgPicture.asset(image, width: 18, height: 16, color: iconColor),
              ),
            ),
            const SizedBox(width: 8),

            // Texts
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(width: 66),

            // Chevron
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF4B5563)),
          ],
        ),
      ),
    );
  }
}

