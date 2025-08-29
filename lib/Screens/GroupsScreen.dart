import 'dart:convert';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/GroupComponent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

final secureStorage = const FlutterSecureStorage();

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Future<List<Map<String, dynamic>>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = fetchGroups();
  }

  /// 🔑 Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await secureStorage.read(key: "token");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// 🔑 Fetch all groups
  Future<List<Map<String, dynamic>>> fetchGroups() async {
    final headers = await _getHeaders();

    final res = await http.get(
      Uri.parse("${dotenv.env['BACKEND_URL']}/app/groups"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final List groups;
      if (data is Map && data['groups'] is List) {
        groups = data['groups'];
      } else if (data is List) {
        groups = data;
      } else {
        throw Exception("Unexpected groups format: $data");
      }

      return groups.map<Map<String, dynamic>>((g) {
        return {...Map<String, dynamic>.from(g), "state": g["state"] ?? "JOIN"};
      }).toList();
    } else {
      throw Exception("Failed to load groups → ${res.body}");
    }
  }

  /// 🔑 Join / Leave / Request group
  Future<void> handleJoinLeave(Map<String, dynamic> group) async {
    String id = group["_id"];
    String state = group["state"];
    String visibility = group["visibility"];

    String endpoint = "";
    if (state == "JOIN") {
      // private groups also use join endpoint, but shown as REQUESTED
      endpoint = "/app/groups/$id/join";
    } else {
      // LEAVE or REQUESTED → leave
      endpoint = "/app/groups/$id/leave";
    }

    final headers = await _getHeaders();

    final res = await http.post(
      Uri.parse("${dotenv.env['BACKEND_URL']}$endpoint"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      setState(() {
        if (state == "JOIN") {
          group["state"] = visibility == "private" ? "REQUESTED" : "LEAVE";
        } else {
          group["state"] = "JOIN";
        }
      });
    } else {
      print("Error joining/leaving group: ${res.body}");
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
          'Groups',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No groups found"));
          }

          final groups = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                /// Search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search groups",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF637587),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Discover Groups",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                /// 👇 Dynamically render groups
                for (var g in groups)
                  GroupCard(
                    groupImage:
                        g["imageUrl"] != null
                            ? "${dotenv.env['BACKEND_URL']}${g["imageUrl"]}"
                            : "${dotenv.env['BACKEND_URL']}/BeFab.png",
                    groupName: g["name"],
                    groupType:
                        g["visibility"] == "public"
                            ? "Public group"
                            : "Private group",
                    postedTime: "",
                    membersCount:
                        g["members"] is List
                            ? "${g["members"].length}"
                            : "${g["members"] ?? 0}",
                    description: g["description"],
                    imageUrls: "${dotenv.env['BACKEND_URL']}${g["bannerUrl"]}",
                    state: g["state"],
                    groupId: g['_id'],
                    onJoinPressed: () => handleJoinLeave(g),
                  ),
              ],
            ),
          );
        },
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
          onPressed: () {
            // Navigate to create new group
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
