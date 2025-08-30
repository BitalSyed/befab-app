import 'package:befab/Screens/ActivityCalendarPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/chat_service.dart'; // <-- your socket service
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String name;

  const ChatScreen({
    required this.chatId,
    required this.userId,
    this.name = '',
    super.key,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchPreviousMessages();
    _setupSocket();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    // Stop listening & disconnect
    _chatService.leaveChat(widget.chatId);
    _chatService.disconnect();

    super.dispose();
  }

  // 1️⃣ Fetch old messages from backend
  Future<void> _fetchPreviousMessages() async {
    try {
      final token = await secureStorage.read(
        key: "token",
      ); // 🔑 read from secure storage
      if (token == null) {
        debugPrint("No token found");
        return;
      }

      final url =
          "${dotenv.env['BACKEND_URL']}/app/chats/${widget.chatId}/messages";

      final res = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);

        // ✅ sort messages by createdAt
        data.sort(
          (a, b) => DateTime.parse(
            a['createdAt'],
          ).compareTo(DateTime.parse(b['createdAt'])),
        );

        setState(() {
          messages =
              data
                  .map(
                    (msg) => ChatMessage(
                      text: msg['content'] ?? '',
                      isMe: msg['sender'] == widget.userId,
                      timestamp: _formatTimestamp(msg['createdAt']),
                    ),
                  )
                  .toList(); // oldest at top → newest at bottom
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        debugPrint("Failed to load messages: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    }
  }

  // 2️⃣ Setup Socket.IO for real-time messages
  void _setupSocket() {
    _chatService.connect(widget.userId);
    _chatService.joinChat(widget.chatId);

    _chatService.onNewMessage((data) {
      if (!mounted) return; // ✅ prevent setState after dispose

      final newMsg = ChatMessage(
        text: data['content'] ?? '',
        isMe: data['sender'] == widget.userId,
        timestamp: _formatTimestamp(data['createdAt']),
      );

      setState(() => messages.add(newMsg));
      _scrollToBottom();
    });
  }

  // Scroll helper
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Format timestamp nicely
  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return "";
    }
  }

  // 3️⃣ Send message
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: widget.userId,
      content: text,
    );

    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ✅ Custom AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
      title: Text(
        widget.name.isNotEmpty ? widget.name : "Chat",
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 12),
      //     child: Stack(
      //       children: [
      //         const CircleAvatar(
      //           radius: 18,
      //           backgroundImage: AssetImage('assets/imas/pic8.jpg'),
      //         ),
      //         Positioned(
      //           bottom: 2,
      //           right: 2,
      //           child: Container(
      //             width: 10,
      //             height: 10,
      //             decoration: const BoxDecoration(
      //               color: Colors.green,
      //               shape: BoxShape.circle,
      //               border: Border.fromBorderSide(
      //                 BorderSide(color: Colors.white, width: 1.5),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      ],
    );
  }

  // ✅ Message input field
  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 60),
      child: Row(
        children: [
          // Container(
          //   width: 32,
          //   height: 32,
          //   decoration: const BoxDecoration(
          //     color: Color(0xFF4CAF50),
          //     shape: BoxShape.circle,
          //   ),
          //   child: const Icon(Icons.add, color: Colors.white, size: 20),
          // ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFFCCCCCC), width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF862633),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Chat bubble widget
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              message.isMe ? const Color(0xFF862633) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : const Color(0xFF333333),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.timestamp,
              style: TextStyle(
                color: message.isMe ? Colors.white70 : const Color(0xFF999999),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Message model
class ChatMessage {
  final String text;
  final bool isMe;
  final String timestamp;

  ChatMessage({this.text = "", required this.isMe, this.timestamp = ""});
}
