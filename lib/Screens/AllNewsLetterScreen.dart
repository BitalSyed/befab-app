import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

final secureStorage = const FlutterSecureStorage();

class AllNewslettersScreen extends StatefulWidget {
  const AllNewslettersScreen({super.key});

  @override
  State<AllNewslettersScreen> createState() => _AllNewslettersScreenState();
}

class _AllNewslettersScreenState extends State<AllNewslettersScreen> {
  List<dynamic> newsletters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNewsletters();
  }

  Future<void> fetchNewsletters() async {
    final url = "${dotenv.env['BACKEND_URL']}/app/newsletters";

    try {
      // read token from secure storage
      final token = await secureStorage.read(key: "token");

      final res = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          newsletters = jsonDecode(res.body);
          loading = false;
        });
      } else {
        throw Exception("Failed to fetch (status: ${res.statusCode})");
      }
    } catch (e) {
      print("Error fetching newsletters: $e");
      setState(() => loading = false);
    }
  }

  Future<void> writeSecureData(String key, String value) async {
    await secureStorage.write(key: key, value: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Newsletter"), centerTitle: true),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: newsletters.length,
                itemBuilder: (context, index) {
                  final n = newsletters[index];
                  return GestureDetector(
                    onTap: () async {
                      await writeSecureData("newsletter_id", n["_id"]);
                      Navigator.pushNamed(
  context,
  '/single-newsletter',
  arguments: {'newsletterId': n["_id"]}, // <-- pass Map
);

                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (n["picture"] != null && n["picture"].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child:
                                  (n["picture"] != null &&
                                          n["picture"].toString().isNotEmpty)
                                      ? Image.network(
                                        "${dotenv.env['BACKEND_URL']}${n["picture"]}",
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => const Icon(
                                              Icons.image_not_supported,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                      )
                                      : const Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                            ),

                          const SizedBox(height: 16),
                          Text(
                            n["title"] ?? "No Title",
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            n["description"] ?? "",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9C9B9D),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Published By: ${n["author"]?["username"] ?? "Unknown"}",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Chip(
                                backgroundColor: const Color(0x1A862633),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                label: Text(
                                  "Read",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF862633),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
