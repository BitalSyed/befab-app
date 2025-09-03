import 'dart:convert';
import 'package:befab/Screens/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final String backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      if (backendUrl.isEmpty) {
        debugPrint("⚠️ BACKEND_URL is empty in .env");
        return null;
      }

      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token == null) {
        debugPrint("⚠️ No auth token found in storage");
        return null;
      }

      final String url = '$backendUrl/app/get';
      debugPrint("Fetching profile from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          debugPrint("✅ Profile fetched successfully");
          return data;
        } else {
          debugPrint("⚠️ Unexpected response format: $data");
          return null;
        }
      } else {
        debugPrint(
          '⚠️ Failed to fetch profile. Status code: ${response.statusCode}',
        );
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      return null;
    }
  }

  Future<void> _loadProfile() async {
    final data = await fetchProfile();
    if (mounted) {
      setState(() {
        profileData = data ?? {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String avatarUrl =
        profileData['avatarUrl'] != null && dotenv.env['BACKEND_URL'] != null
            ? "${dotenv.env['BACKEND_URL']}${profileData['avatarUrl']}"
            : "${dotenv.env['BACKEND_URL']}/BeFab.png";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        // backgroundColor: const Color(0xFF862633),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 20),
            Text(
              "${profileData['firstName']} ${profileData['lastName']}" ?? "Name not available",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              profileData['email'] ?? "Email not available",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Details
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Username"),
              subtitle: Text(profileData['username'] ?? "-"),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text("Full Name"),
              subtitle: Text("${profileData['firstName']} ${profileData['lastName']}" ?? "-"),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email Address"),
              subtitle: Text(profileData['email'] ?? "-"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
