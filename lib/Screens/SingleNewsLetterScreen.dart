import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

final secureStorage = const FlutterSecureStorage();

class SingleNewsletterScreen extends StatefulWidget {
  final String newsletterId;
  const SingleNewsletterScreen({super.key, required this.newsletterId});

  @override
  State<SingleNewsletterScreen> createState() => _SingleNewsletterScreenState();
}

class _SingleNewsletterScreenState extends State<SingleNewsletterScreen> {
  Map<String, dynamic>? newsletter;
  bool loading = true;

  Future<void> fetchNewsletter() async {
    try {
      final token = await secureStorage.read(key: "token");
      final id = await secureStorage.read(key: "newsletter_id");
      final res = await http.get(
        Uri.parse("${dotenv.env['BACKEND_URL']}/app/newsletters/${id}"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        setState(() {
          newsletter = jsonDecode(res.body);
          loading = false;
        });
      } else {
        throw Exception("Failed to fetch single newsletter");
      }
    } catch (e) {
      print("Error fetching single newsletter: $e");
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNewsletter();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (newsletter == null) {
      return const Scaffold(body: Center(child: Text("Not found")));
    }

    final pdfUrl =
        newsletter?["pdf"] != null
            ? "${dotenv.env['BACKEND_URL']}${newsletter!["pdf"]}"
            : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  'assets/images/Arrow.svg',
                  width: 14,
                  height: 14,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF862633),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Newsletter',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          pdfUrl != null
              ? SfPdfViewer.network(pdfUrl)
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (newsletter?["picture"] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          "${dotenv.env['BACKEND_URL']}${newsletter!["picture"]}",
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      newsletter?["title"] ?? "Headline",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "PUBLISHED ON: ${DateTime.parse(newsletter?["createdAt"]).toLocal().toString().split(' ')[0]}",
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      newsletter?["description"] ?? "",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9C9B9D),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/deep-dive',
                      arguments: {'deepDives': newsletter?['deepDives'] ?? []},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF862633),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Done Reading"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
