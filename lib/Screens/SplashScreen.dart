// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacementNamed(context, '/welcome');
//     });

//     return Scaffold(
//       backgroundColor: const Color(0xFF862633),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 96,
//               height: 96,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(Radius.circular(12)),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: SvgPicture.asset('assets/images/logo.svg'),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Use LayoutBuilder to determine the max width
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 const double fixedWidth = 280; // Choose a width large enough to fit both texts

//                 return Column(
//                   children: [
//                     SizedBox(
//                       width: fixedWidth,
//                       child: Text(
//                         'BeFAB HBCU',
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.lexend(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 36,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: fixedWidth,
//                       child: Text(
//                         'BE FIT,ACTIVE & BALANCED',
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.lexend(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });

    return Scaffold(
      backgroundColor: const Color(0xFF862633),
      body:SizedBox()
    );
  }
}
