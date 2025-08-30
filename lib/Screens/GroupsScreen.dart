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
  List<Map<String, dynamic>> _allGroups = [];
  List<Map<String, dynamic>> _filteredGroups = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupsFuture = fetchGroups();
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredGroups = List.from(_allGroups);
      });
    } else {
      setState(() {
        _filteredGroups = _allGroups.where((group) {
          final name = group['name']?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      });
    }
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

      final result = groups.map<Map<String, dynamic>>((g) {
        return {...Map<String, dynamic>.from(g), "state": g["state"] ?? "JOIN"};
      }).toList();
      
      setState(() {
        _allGroups = List.from(result);
        _filteredGroups = List.from(result);
      });
      
      return result;
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
        
        // Update both lists to reflect the change
        final index = _allGroups.indexWhere((g) => g["_id"] == group["_id"]);
        if (index != -1) {
          _allGroups[index] = {...group};
        }
        
        final filteredIndex = _filteredGroups.indexWhere((g) => g["_id"] == group["_id"]);
        if (filteredIndex != -1) {
          _filteredGroups[filteredIndex] = {...group};
        }
      });
    } else {
      print("Error joining/leaving group: ${res.body}");
    }
  }

  /// Navigate to group details page
  void _openGroup(Map<String, dynamic> group) {
    Navigator.pushNamed(
      context,
      "/group-details",
      arguments: {
        'groupId': group['_id'],
        'groupName': group['name'],
      },
    );
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
          }

          return Column(
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
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search groups",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: const TextStyle(
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

              /// Groups list
              Expanded(
                child: _filteredGroups.isEmpty
                    ? const Center(
                        child: Text(
                          "No groups found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredGroups.length,
                        itemBuilder: (context, index) {
                          final group = _filteredGroups[index];
                          return GestureDetector(
                            onTap: () => _openGroup(group),
                            child: GroupCard(
                              groupImage: group["imageUrl"] != null
                                  ? "${dotenv.env['BACKEND_URL']}${group["imageUrl"]}"
                                  : "${dotenv.env['BACKEND_URL']}/BeFab.png",
                              groupName: group["name"],
                              groupType: group["visibility"] == "public"
                                  ? "Public group"
                                  : "Private group",
                              postedTime: "",
                              membersCount: group["members"] is List
                                  ? "${group["members"].length}"
                                  : "${group["members"] ?? 0}",
                              description: group["description"],
                              imageUrls:
                                  "${dotenv.env['BACKEND_URL']}${group["bannerUrl"]}",
                              state: group["state"],
                              groupId: group['_id'],
                              onJoinPressed: () => handleJoinLeave(group),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 11),
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