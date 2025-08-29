import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class ForgotPassword3 extends StatefulWidget {
  const ForgotPassword3({super.key});

  @override
  State<ForgotPassword3> createState() => _ForgotPassword3State();
}

class _ForgotPassword3State extends State<ForgotPassword3> {
  bool isEmailSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Center(
                child: SvgPicture.asset(
                  'assets/images/logo2.svg',
                  width: 40, // adjust as needed
                  height: 40,
                ),
              ),
              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Change Password',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121714),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(64),
                    color: Color.fromRGBO(134, 38, 51, 0.05)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                    child: SvgPicture.asset("assets/images/lock2.svg",color: Color(0xFF862633),width: 24,height: 24,),
                  )
                ),
              ),
              SizedBox(height: 16,),
              // Toggle buttons
Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Congratulations!. your email is verified, please enter your new password',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF121714),
                    ),
                  ),
                ),
              ),
                            const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Password',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
              // Username
                            const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: TextField(
                  style: const TextStyle(
                    color: Color(0xFF767272),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Color(0xFF767272)),
                    filled: true,
                    fillColor: const Color(
                      0xFFFFFFFF,
                    ), // Updated background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Color(0xFF5E6B87))
                    ),
suffixIcon: Padding(
  padding: const EdgeInsets.all(10), // Match your existing padding style
  child: SizedBox(
    width: 14,
    height: 14,
    child: SvgPicture.asset(
      "assets/images/eye.svg",
      fit: BoxFit.contain,
    ),
  ),
),                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Confirm Password',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
              // Username
                            const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: TextField(
                  style: const TextStyle(
                    color: Color(0xFF767272),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your confirm password',
                    hintStyle: const TextStyle(color: Color(0xFF767272)),
                    filled: true,
                    fillColor: const Color(
                      0xFFFFFFFF,
                    ), // Updated background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Color(0xFF5E6B87))
                    ),
suffixIcon: Padding(
  padding: const EdgeInsets.all(10), // Match your existing padding style
  child: SizedBox(
    width: 14,
    height: 14,
    child: SvgPicture.asset(
      "assets/images/eye.svg",
      fit: BoxFit.contain,
    ),
  ),
),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),

              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF862633),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed:
                          () => Navigator.pushNamed(context, '/forgot-password-4'),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        child: Text(
                          'Verify',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailOrSSOSelector extends StatelessWidget {
  final bool isEmailSelected;
  final ValueChanged<bool> onChanged;

  const EmailOrSSOSelector({
    super.key,
    required this.isEmailSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F5),
        borderRadius: BorderRadius.circular(8), // Less curve
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isEmailSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6), // Less curve
                  boxShadow:
                      isEmailSelected
                          ? [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: !isEmailSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6), // Less curve
                  boxShadow:
                      !isEmailSelected
                          ? [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'SSO',
                  style: GoogleFonts.inter(
                    color: Color(0xFF737373),
                    fontWeight: FontWeight.w500,
                    fontSize: 14
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
