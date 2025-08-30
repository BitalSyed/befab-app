import 'dart:convert';
import 'package:befab/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:befab/components/CustomBottomNavBar.dart';

class Competition {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> participants; // ✅ store participant IDs

  Competition({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.participants,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      participants:
          (json['participants'] as List<dynamic>? ?? [])
              .map((p) {
                final user = p['user'];
                if (user is String) return user; // already an ID
                if (user is Map<String, dynamic>)
                  return user['_id'] as String; // populated object
                return "";
              })
              .where((id) => id.isNotEmpty)
              .toList(),
    );
  }
}

class CompetitionsListPage extends StatefulWidget {
  @override
  _CompetitionsListPageState createState() => _CompetitionsListPageState();
}

class _CompetitionsListPageState extends State<CompetitionsListPage> {
  late Future<List<Competition>> competitionsFuture;
  Set<String> joinedCompetitions = {}; // ✅ Track joined competitions

  @override
  void initState() {
    super.initState();
    competitionsFuture = fetchCompetitions();
  }

  Future<List<Competition>> fetchCompetitions() async {
    final token = await readSecureData("token");
    final url = "${dotenv.env['BACKEND_URL']}/app/competitions";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final list = body['list'] as List<dynamic>;
      final competitions =
          list.map((json) => Competition.fromJson(json)).toList();

      // ✅ use backend "joined" flag
      final joined =
          list
              .where((json) => json['joined'] == true)
              .map((json) => json['_id'] as String)
              .toSet();

      setState(() {
        joinedCompetitions = joined;
      });

      return competitions;
    } else {
      throw Exception("Failed to load competitions: ${response.body}");
    }
  }

  Future<void> joinCompetition(String competitionId) async {
    final token = await readSecureData("token");
    final url =
        "${dotenv.env['BACKEND_URL']}/app/competitions/$competitionId/join";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        joinedCompetitions.add(competitionId); // ✅ update UI
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Joined successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to join: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Row(
            children: [
              SizedBox(width: 8),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ToggleOptions(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Competition>>(
              future: competitionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final competitions = snapshot.data ?? [];
                if (competitions.isEmpty) {
                  return const Center(child: Text("No competitions available"));
                }

                return ListView.builder(
                  itemCount: competitions.length,
                  itemBuilder: (_, index) {
                    final comp = competitions[index];
                    final isJoined = joinedCompetitions.contains(comp.id);
                    // ✅ always checks state

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey.shade200,
                                  child:
                                      comp.imageUrl != null &&
                                              comp.imageUrl!.isNotEmpty
                                          ? Image.network(
                                            comp.imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                          : Image.asset(
                                            "assets/images/list.png",
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comp.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comp.description,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      // maxLines: 1,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    isJoined
                                        ? null
                                        : () => joinCompetition(comp.id),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor:
                                      isJoined
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isJoined ? "JOINED" : "JOIN",
                                  style: TextStyle(
                                    color:
                                        isJoined
                                            ? Colors.white
                                            : const Color(0xFF862633),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 84.0,
                            right: 16.0,
                          ),
                          child: const Divider(
                            height: 1,
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}

class ToggleOptions extends StatefulWidget {
  @override
  _ToggleOptionsState createState() => _ToggleOptionsState();
}

class _ToggleOptionsState extends State<ToggleOptions> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildOption("My Progress", 0, "competitions-progress"),
        const SizedBox(width: 24),
        _buildOption("Active Competitions", 1, "competitions-list"),
      ],
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
          Container(height: 2, width: 120, color: const Color(0xFFE5E8EB)),
        ],
      ),
    );
  }
}
