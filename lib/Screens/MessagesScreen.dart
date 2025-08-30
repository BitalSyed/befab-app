// messages_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> searchResults = [];
  bool loading = true;
  String myUserId = "";
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _initData();

    // Listen for changes in search text
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          isSearching = false;
          searchResults = [];
        });
      }
    });
  }

  Future<void> _initData() async {
    await _fetchUserId(); // wait until userId is fetched
    await _fetchChats(); // then fetch chats
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserId() async {
    final id = await storage.read(key: "userId");
    if (id != null) {
      setState(() {
        myUserId = id;
      });
    }
  }

  Future<void> _fetchChats() async {
    try {
      final token = await storage.read(key: "token");
      if (token == null) return;

      final url = "${dotenv.env['BACKEND_URL']}/app/chats";
      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          messages =
              data.map<Map<String, dynamic>>((chat) {
                final lastMessage = chat['lastMessageAt'] ?? {};
                final participant = chat['participants'].firstWhere( (p) => p['_id'] != myUserId, orElse: () => {}, );

                return {
                  "chatId": chat["_id"],
                  "userId": participant['_id'], // ✅ store other participant ID
                  "user": participant['username'], // ✅ store other participant ID
                  "name":
                      "${participant['firstName']} ${participant['lastName']}",
                  "msg": "",
                  "time": lastMessage ?? "",
                  "avatar":
                      (participant['avatarUrl'] as String?)
                                  ?.trim()
                                  .isNotEmpty ==
                              true
                          ? participant['avatarUrl']
                          : "${dotenv.env['BACKEND_URL']}/BeFab.png",
                };
              }).toList();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error fetching chats: $e");
      setState(() => loading = false);
    }
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final token = await storage.read(key: "token");
    if (token == null) return;

    final url = "${dotenv.env['BACKEND_URL']}/app/users/search?q=$query";
    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      setState(() {
        searchResults =
            data.map<Map<String, dynamic>>((user) {
              // "chatId": chat["_id"],
              //     "userId": participant['_id'], // ✅ store other participant ID
              //     "name":
              //         "${participant['firstName']} ${participant['lastName']}",
              //     "msg": "",
              //     "time": lastMessage ?? "",
              //     "avatar":
              //         (participant['avatarUrl'] as String?)
              //                     ?.trim()
              //                     .isNotEmpty ==
              //                 true
              //             ? participant['avatarUrl']
              //             : "${dotenv.env['BACKEND_URL']}/BeFab.png",
              return {
                "chatId": user["chatId"],
                "userId": user['_id'],
                "name": "${user['firstName']} ${user['lastName']}".trim(),
                "avatar":
                    (user['avatarUrl'] as String?)?.trim().isNotEmpty == true
                        ? user['avatarUrl']
                        : "${dotenv.env['BACKEND_URL']}/BeFab.png",
                "msg": "",
                "user": user['username'],
                "time": "",
              };
            }).toList();
      });
    }
  }

  Future<void> _startChatWithUser(Map<String, dynamic> user) async {
    final token = await storage.read(key: "token");
    if (token == null) return;

    final url = "${dotenv.env['BACKEND_URL']}/app/chats";
    final body = jsonEncode({
      "participantIds": [user['userId']], // sending userId in JSON body
    });

    final res = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // important for JSON body
      },
      body: body,
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final chatId = data['_id'];

      if (mounted) {
        // Clear search and return to messages list
        setState(() {
          _searchController.clear();
          isSearching = false;
          searchResults = [];
        });
print("Chat: $chatId $data with user ${user['userId']}");
        // Navigate to chat screen
        Navigator.pushNamed(
          context,
          '/chat-screen',
          arguments: {
            "chatId": chatId,
            "userId": user['userId'],
            "name": user['name'],
          },
        ).then((_) {
          // Refresh chats when returning from chat screen
          _fetchChats();
        });
      }
    } else {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to start chat")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search users...",
                    border: InputBorder.none,
                  ),
                  onChanged: _searchUsers,
                )
                : const Text("Messages"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  _searchController.clear();
                  isSearching = false;
                  searchResults = [];
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Show either search results or message list
          if (isSearching && searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['avatar']),
                    ),
                    title: Text(user['name']),
                    subtitle: Text(user['user']),
                    onTap: () => _startChatWithUser(user),
                  );
                },
              ),
            )
          else if (isSearching && !loading)
            const Expanded(child: Center(child: Text("No users found")))
          else if (loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final chat = messages[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(chat['avatar']),
                    ),
                    title: Text(chat['name']),
                    subtitle: Text(chat['user']),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat-screen',
                        arguments: {
                          "chatId": chat['chatId'],
                          "userId": chat['userId'],
                          "name": chat['name'],
                        },
                      ).then((_) {
                        // Refresh chats when returning from chat screen
                        _fetchChats();
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
