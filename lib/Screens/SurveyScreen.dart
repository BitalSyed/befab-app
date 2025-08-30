import 'dart:convert';
import 'package:befab/components/AssessmentCard.dart';
import 'package:befab/components/AssessmentItem.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

enum IconType { alert, clock, check, calendar, star, target }

class Surveyscreen extends StatefulWidget {
  @override
  State<Surveyscreen> createState() => _SurveyscreenState();
}

class _SurveyscreenState extends State<Surveyscreen> {
  final storage = const FlutterSecureStorage();
  List<dynamic> requiredSurveys = [];
  List<dynamic> optionalSurveys = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    try {
      String? token = await storage.read(key: "token");
      final res = await http.get(
        Uri.parse("${dotenv.env['BACKEND_URL']}/app/surveys"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          requiredSurveys =
              data.where((s) => s["type"] == "required").toList();
          optionalSurveys =
              data.where((s) => s["type"] == "optional").toList();
          loading = false;
        });
      } else {
        print("Error fetching surveys: ${res.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
    }
  }

  void startSurvey(String id) {
    Navigator.pushNamed(context, "/survey-start", arguments: {"surveyId": id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Surveys",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // ===== Required Surveys =====
                  buildSection(
                    title: "Required Surveys",
                    count: requiredSurveys.length,
                    items: requiredSurveys,
                  ),

                  // ===== Optional Surveys =====
                  buildSection(
                    title: "Optional Surveys",
                    count: optionalSurveys.length,
                    items: optionalSurveys,
                  ),

                  // ===== Past Surveys (Static Placeholder) =====
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Text(
                  //         "Past Surveys",
                  //         style: GoogleFonts.lexend(
                  //           color: const Color(0xFF121714),
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w400,
                  //         ),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.all(8.0),
                  //       child: Text(
                  //         "view all",
                  //         style: TextStyle(
                  //           color: Color(0xFF862633),
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w400,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // AssessmentItem(
                  //   title: "Weekly fitness assessment",
                  //   statusText: "Completed on 17, 2025",
                  //   status: AssessmentStatus.inProgress,
                  //   onTap: () {},
                  // ),
                  // AssessmentItem(
                  //   title: "Nutrition Tracking",
                  //   statusText: "Completed on 17, 2025",
                  //   status: AssessmentStatus.inProgress,
                  //   onTap: () {},
                  // ),
                  const SizedBox(height: 24),
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }

  Widget buildSection({
    required String title,
    required int count,
    required List items,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  color: const Color(0xFF121714),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: const Color(0x1A862633),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "$count ${title == "Required Surveys" ? "Pending" : "Available"}",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF862633),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
        ...items.map((s) => AssessmentCard(
              title: s["title"] ?? "Untitled",
              subtitle: s["description"] ?? "",
              duration: "${s["durationMin"] ?? 5} min.",
              timeText: s["dueDate"] != null
                  ? "due on ${s["dueDate"].toString().substring(0, 10)}"
                  : "",
              buttonText: "Start Survey",
              image: "assets/images/alert.svg", // you can improve mapping icons later
              onButtonPressed: () => startSurvey(s["_id"]),
            )),
      ],
    );
  }
}
