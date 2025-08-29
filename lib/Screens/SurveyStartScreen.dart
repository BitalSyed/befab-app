import 'dart:convert';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SurveyStartScreen extends StatefulWidget {
  final String surveyId;
  const SurveyStartScreen({super.key, required this.surveyId});

  @override
  State<SurveyStartScreen> createState() => _SurveyStartScreenState();
}

class _SurveyStartScreenState extends State<SurveyStartScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? survey;
  bool loading = true;
  Map<String, dynamic> answers = {}; // key: question, value: answer

  @override
  void initState() {
    super.initState();
    fetchSurvey();
  }

  Future<void> fetchSurvey() async {
    try {
      String? token = await storage.read(key: "token");
      final res = await http.get(
        Uri.parse(
          "${dotenv.env['BACKEND_URL']}/app/surveys/${widget.surveyId}",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          survey = data;
          loading = false;
        });
      } else {
        print("Error fetching survey: ${res.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
    }
  }

  Future<void> submitSurvey() async {
    try {
      String? token = await storage.read(key: "token");
      final res = await http.post(
        Uri.parse(
          "${dotenv.env['BACKEND_URL']}/app/surveys/${widget.surveyId}/response",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "answers":
              answers.entries
                  .map((e) => {"question": e.key, "answer": e.value})
                  .toList(),
        }),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        if (body["error"] != null) {
          // 🔴 Backend responded with an error despite 200
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("${body["error"]}")));
        } else {
          // ✅ Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Survey submitted successfully!")),
          );
        }
          Navigator.pushReplacementNamed(context, "/survey");
      } else {
        print("Error submitting survey: ${res.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget buildQuestion(Map<String, dynamic> q) {
    switch (q["kind"]) {
      case "text":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q["q"], // 👈 full question text
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Enter your answer", // 👈 not truncated
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: null,
              onChanged: (val) => answers[q["q"]] = val,
            ),
          ],
        );

      case "number":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q["q"],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: "Enter a number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              minLines: 1,
              maxLines: null,
              onChanged: (val) => answers[q["q"]] = val,
            ),
          ],
        );

      case "single":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q["q"],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            ...q["options"].map<Widget>((opt) {
              return RadioListTile(
                title: Text(opt),
                value: opt,
                groupValue: answers[q["q"]],
                onChanged: (val) {
                  setState(() => answers[q["q"]] = val);
                },
              );
            }).toList(),
          ],
        );

      case "multi":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q["q"],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            ...q["options"].map<Widget>((opt) {
              final selected = (answers[q["q"]] ?? <String>[]) as List<String>;
              return CheckboxListTile(
                title: Text(opt),
                value: selected.contains(opt),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selected.add(opt);
                    } else {
                      selected.remove(opt);
                    }
                    answers[q["q"]] = selected;
                  });
                },
              );
            }).toList(),
          ],
        );

      default:
        return const Text("Unsupported question type");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey?["title"] ?? "Survey",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      survey?["description"] ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider(height: 32),
                    ...((survey?["questions"] as List<dynamic>? ?? [])
                        .map<Widget>(
                          (q) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: buildQuestion(Map<String, dynamic>.from(q)),
                          ),
                        )),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: submitSurvey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF862633),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Submit Survey",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}
