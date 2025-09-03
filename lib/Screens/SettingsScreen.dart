import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Settings',
      theme: ThemeData(
        primaryColor: const Color(0xFF862633),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;
  File? _selectedImage;
  final storage = const FlutterSecureStorage();

  // Common function to get token and backend URL
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'token');
    final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Backend-URL': backendUrl,
    };
  }

  Future<void> _fetchUserData() async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      final token = await storage.read(key: 'token');
      if (backendUrl.isEmpty || token == null) return;

      final response = await http.get(
        Uri.parse('$backendUrl/app/get'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _showImageUpdateDialog();
    }
  }

  Future<void> _updateProfilePicture(File imageFile) async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      final token = await storage.read(key: 'token');
      if (backendUrl.isEmpty || token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/app/updateProfile'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        _fetchUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile picture')),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
    }
  }

  void _showImageUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : const NetworkImage('assets/default_avatar.png') as ImageProvider,
              ),
              const SizedBox(height: 16),
              const Text('Do you want to set this as your new profile picture?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF862633)),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (_selectedImage != null) {
                  _updateProfilePicture(_selectedImage!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateField(String field, String value) async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      final token = await storage.read(key: 'token');
      if (backendUrl.isEmpty || token == null) return;

      String endpoint = '';
      switch (field.toLowerCase()) {
        case 'username':
          endpoint = '/app/username';
          break;
        case 'first name':
          endpoint = '/app/firstName';
          break;
        case 'last name':
          endpoint = '/app/lastName';
          break;
        case 'email':
          endpoint = '/app/email';
          break;
        default:
          return;
      }

      final response = await http.post(
        Uri.parse('$backendUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({field.toLowerCase().replaceAll(' ', ''): value}),
      );

      if (response.statusCode == 200) {
        _fetchUserData();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$field updated successfully!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update $field')));
      }
    } catch (e) {
      debugPrint('Error updating $field: $e');
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF862633)),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateField(field, controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword(String oldPass, String newPass) async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      final token = await storage.read(key: 'token');
      if (backendUrl.isEmpty || token == null) return;

      final response = await http.post(
        Uri.parse('$backendUrl/app/password'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'oldPassword': oldPass, 'newPassword': newPass}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to update password')));
      }
    } catch (e) {
      debugPrint('Error updating password: $e');
    }
  }

  void _showPasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Old Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF862633)),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('New passwords do not match!')));
                  return;
                }
                Navigator.pop(context);
                _updatePassword(oldPasswordController.text, newPasswordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
  try {
    final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
    final token = await storage.read(key: 'token');
    if (backendUrl.isEmpty || token == null) return;

    final response = await http.post(
      Uri.parse('$backendUrl/app/deleteAccount'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Delete token and id
      await storage.delete(key: 'token');
      await storage.delete(key: 'userId');

      // Show snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account deleted successfully')));

      // Navigate to /signin and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete account')));
    }
  } catch (e) {
    debugPrint('Error deleting account: $e');
  }
}

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF862633)),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
  await storage.delete(key: 'token');
  await storage.delete(key: 'id');

  // Navigate to /signin and remove all previous routes
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/signin',
    (Route<dynamic> route) => false,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Logged out successfully')),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      userData?['avatarUrl'] != null && dotenv.env['BACKEND_URL'] != null
                          ? "${dotenv.env['BACKEND_URL']}${userData?['avatarUrl']}"
                          : "${dotenv.env['BACKEND_URL']}/BeFab.png",
                    ) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF862633),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Tap to change picture",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF862633)),
                    title: const Text("Username"),
                    subtitle: Text(userData?['username'] ?? "Loading..."),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog('Username', userData?['username'] ?? ""),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge, color: Color(0xFF862633)),
                    title: const Text("First Name"),
                    subtitle: Text(userData?['firstName'] ?? "Loading..."),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog('First Name', userData?['firstName'] ?? ""),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: Color(0xFF862633)),
                    title: const Text("Last Name"),
                    subtitle: Text(userData?['lastName'] ?? "Loading..."),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog('Last Name', userData?['lastName'] ?? ""),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFF862633)),
                    title: const Text("Email"),
                    subtitle: Text(userData?['email'] ?? "Loading..."),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog('Email', userData?['email'] ?? ""),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Color(0xFF862633)),
                    title: const Text("Change Password"),
                    trailing: const Icon(Icons.edit),
                    onTap: _showPasswordDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete, color: Color(0xFF862633)),
                    title: const Text(
                      "Delete Account",
                      style: TextStyle(color: Color(0xFF862633)),
                    ),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF862633)),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Color(0xFF862633)),
                ),
                onTap: _logout,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
