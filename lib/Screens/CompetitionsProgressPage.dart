import 'dart:convert';

import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/WaveGraph.dart';
import 'package:befab/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CompetitionsProgressPage extends StatefulWidget {
  @override
  _CompetitionsProgressPageState createState() =>
      _CompetitionsProgressPageState();
}

class _CompetitionsProgressPageState extends State<CompetitionsProgressPage> {
  Map<String, dynamic> competitionsJson = {};
  bool isLoading = true;

  Future<Map<String, dynamic>> fetchCompetitionsRaw() async {
    final token = await readSecureData("token");
    final url = "${dotenv.env['BACKEND_URL']}/app/competitions";
    final url1 = "${dotenv.env['BACKEND_URL']}/app/competitions/get";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    final response1 = await http.get(
      Uri.parse(url1),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 && response1.statusCode == 200) {
      return jsonDecode(response1.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to load competitions: ${response1.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompetitionsRaw()
        .then((data) {
          setState(() {
            competitionsJson = data;
            debugPrint("Competitions Data: $competitionsJson");
            isLoading = false;
          });
        })
        .catchError((error) {
          setState(() {
            isLoading = false;
          });
          // Handle error appropriately
          print("Error fetching competitions: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Prevent M3 tint
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.arrow_back, color: Colors.black),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Competitions',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ToggleOptions(), // this should be aligned left
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Text(
                  "Your Progress",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6,
                ),
                child: Text(
                  "${competitionsJson?['stats']?['totalWins'] ?? 0} won",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6,
                ),
                // child: RichText(
                //   text: TextSpan(
                //     style: const TextStyle(fontSize: 16, color: Colors.black),
                //     children: [
                //       const TextSpan(
                //         text: "Last 30 Days ",
                //         style: TextStyle(color: Colors.grey, fontSize: 14),
                //       ),
                //       TextSpan(
                //         text: "+12%",
                //         style: const TextStyle(
                //           fontSize: 14,
                //           color: Color(0xFF862633),
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: WaveGraph(),
              ),
              SizedBox(height: 20),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16.0,
              //     vertical: 8.0,
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Text(
              //           "You've completed 2 of 4 milestones in the Invest in Women competition",
              //           style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w400),
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //       Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Progress",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${competitionsJson?['stats']?['avgProgress']?.toStringAsFixed(1) ?? '0'}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), // curved corners
                  child: Container(
                    height: 6, // increase height here
                    child: LinearProgressIndicator(
                      value:
                          ((competitionsJson?['stats']?['avgProgress'] ?? 0)
                              as num) /
                          100,
                      color: Color(0xFF862633),
                      backgroundColor:
                          Colors.grey.shade300, // optional for contrast
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "You're currently ranked ${competitionsJson?['stats']?['avgRank'] ?? 'N/A'} in all competitions",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    // Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
              SizedBox(height: 6),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16.0,
              //     vertical: 16,
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Text(
              //           "You've made 10 trades this month. Keep going to hit your goal of 20",
              //           style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w400),
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //       Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              //     ],
              //   ),
              // ),
              SizedBox(height: 36),
            ],
          ),
        ),
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}

class ToggleOptions extends StatefulWidget {
  @override
  _ToggleOptionsState createState() => _ToggleOptionsState();
}

class _ToggleOptionsState extends State<ToggleOptions> {
  int selectedIndex = 0; // 0 for first, 1 for second

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildOption("My Progress", 0, "competitions-progress"),
          const SizedBox(width: 24),
          _buildOption("Competitions", 1, 'competitions-list'),
        ],
      ),
    );
  }

  Widget _buildOption(String text, int index, String url) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        if (url.isNotEmpty) {
          Navigator.pushNamed(context, '/$url');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 2, width: 120, color: Color(0xFFE5E8EB)),
        ],
      ),
    );
  }
}
