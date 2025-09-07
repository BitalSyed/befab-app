import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/gestures.dart';

// Import your two new screens
import 'privacy_policy_screen.dart';
import 'terms_of_agreement_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for each field
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final userIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); // ✅ New confirm password

  // Controllers for 2FA
  final twoFactorEmailController = TextEditingController();
  final otpController = TextEditingController();

  bool isLoading = false;
  bool isSendingCode = false;

  // ✅ Track password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submitForm() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Passwords do not match")),
      );
      return;
    }

    final url = "${dotenv.env['BACKEND_URL']}/auth/signup";
    final body = {
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "username": usernameController.text.trim(),
      "userId": userIdController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text,
      "code": otpController.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${data['message']}")),
        );
        Navigator.pushNamed(context, '/signin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${res.body}")),
        );
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $err")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendTwoFactorCode() async {
    final email = twoFactorEmailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() => isSendingCode = true);

    try {
      final url = "${dotenv.env['BACKEND_URL']}/auth/twofactor";
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("📩 OTP sent to your email")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${res.body}")),
        );
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $err")),
      );
    } finally {
      setState(() => isSendingCode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fields = [
      {
        "label": "First name",
        "iconPath": "assets/images/icon1.svg",
        "controller": firstNameController,
      },
      {
        "label": "Last name",
        "iconPath": "assets/images/icon1.svg",
        "controller": lastNameController,
      },
      {
        "label": "Username",
        "iconPath": "assets/images/icon1.svg",
        "suffixText": "@befab",
        "controller": usernameController,
      },
      {
        "label": "User ID",
        "iconPath": "assets/images/icon1.svg",
        "controller": userIdController,
        "hint": "Enter your Record ID Number",
      },
      {
        "label": "Email address",
        "iconPath": "assets/images/icon2.svg",
        "controller": emailController,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/Arrow.svg',
                        width: 14,
                        height: 14,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/logo2.svg',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/signup_illustration.png',
                      height: 180,
                      width: 360,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join BeFAB NCCU',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: const Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic fields
                  ...fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextField(
                        controller: field["controller"],
                        style: GoogleFonts.inter(
                          color: const Color(0xFF638773),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: field["hint"] ?? field["label"],
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF638773),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF0F5F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: field["label"] == "Username"
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      field["suffixText"],
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF638773),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8, left: 6),
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: SvgPicture.asset(
                                          field["iconPath"],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: SvgPicture.asset(
                                      field["iconPath"],
                                      color: const Color(0xFF638773),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Password field with toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF638773),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: "Create password",
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF638773),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF638773),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // Confirm Password field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF638773),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: "Confirm password",
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF638773),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF638773),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // 2FA Section Title
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 6),
                    child: Text(
                      "Two-Factor Authentication",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Email Field with Get Code button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: twoFactorEmailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF638773),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton(
                            onPressed:
                                isSendingCode ? null : _sendTwoFactorCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF638773),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: isSendingCode
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Get Code",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // OTP Field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter the 6 digit OTP",
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF638773),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Updated clickable Terms and Privacy
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to the ',
                      style: GoogleFonts.inter(color: const Color(0xFF638773)),
                      children: [
                        TextSpan(
                          text: 'Terms of Use',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF862633),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TermsOfAgreementScreen(),
                                ),
                              );
                            },
                        ),
                        TextSpan(
                          text: '. Read our ',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF638773),
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF862633),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF862633),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: isLoading ? null : _submitForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Continue',
                                style: GoogleFonts.lexend(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
