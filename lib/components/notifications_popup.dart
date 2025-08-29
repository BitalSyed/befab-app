import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationItem {
  final String title;
  final String timeAgo;
  final String iconPath;

  NotificationItem({
    required this.title,
    required this.timeAgo,
    required this.iconPath,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'],
      timeAgo: json['timeAgo'],
      iconPath: json['iconPath'],
    );
  }
}

class NotificationsPopup extends StatefulWidget {
  const NotificationsPopup({super.key});

  @override
  State<NotificationsPopup> createState() => _NotificationsPopupState();
}

class _NotificationsPopupState extends State<NotificationsPopup> {
  bool isLoading = true;
  List<NotificationItem> todayNotifications = [];
  List<NotificationItem> earlierNotifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);

    try {
      final res = await http.get(Uri.parse("https://your-backend.com/notifications"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          todayNotifications = (data['today'] as List)
              .map((json) => NotificationItem.fromJson(json))
              .toList();
          earlierNotifications = (data['earlier'] as List)
              .map((json) => NotificationItem.fromJson(json))
              .toList();
        });
      } else {
        throw Exception("Failed to load notifications");
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $err")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildNotificationCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            item.iconPath,
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.timeAgo,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/notification_bell.svg",
                              width: 20,
                              height: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Notifications",
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle clear all
                          },
                          child: Text(
                            "Clear all",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (todayNotifications.isNotEmpty)
                      Text(
                        "Today",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ...todayNotifications.map(buildNotificationCard).toList(),

                    if (earlierNotifications.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Earlier",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      ...earlierNotifications.map(buildNotificationCard).toList(),
                    ]
                  ],
                ),
              ),
      ),
    );
  }
}
