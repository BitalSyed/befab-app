import 'dart:convert';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Secure storage instance
final secureStorage = const FlutterSecureStorage();

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> events = [];
  DateTime _selectedDate = DateTime.now();

  // Fetch events from backend
  Future<void> fetchEvents() async {
    try {
      final token = await secureStorage.read(key: 'token');
      final url = "${dotenv.env['BACKEND_URL']}/app/events";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          events = data.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        debugPrint("Error fetching events: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
  }

  // Map event color based on status
  Color getColorFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return const Color(0xFF0074C4); // blue
      case 'active':
        return const Color(0xFFE73C1A); // orange
      case 'completed':
        return const Color(0xFF862633); // red
      default:
        return Colors.grey;
    }
  }

  // Format date for Google Calendar
  String _formatGoogleDate(DateTime date) {
    return date.toUtc().toIso8601String()
        .replaceAll("-", "")
        .replaceAll(":", "")
        .split(".")[0] + "Z";
  }

  // Open Google Calendar with event details
  Future<void> openInGoogleCalendar(Map<String, dynamic> event) async {
    final startDate = DateTime.parse(event['date']);
    final endDate = startDate.add(const Duration(hours: 1));

    final start = _formatGoogleDate(startDate);
    final end = _formatGoogleDate(endDate);

    final title = Uri.encodeComponent(event['title'] ?? "Event");
    final details = Uri.encodeComponent(
      "Status: ${event['status']}\n"
      "Author: ${event['author']?['firstName'] ?? ''} ${event['author']?['lastName'] ?? ''}\n"
      "Created: ${event['createdAt'] ?? ''}"
    );
    final location = Uri.encodeComponent(event['location'] ?? "");

    final url =
        "https://www.google.com/calendar/render?action=TEMPLATE&text=$title&details=$details&location=$location&dates=$start/$end";

    final uri = Uri.parse(url);

    // ✅ FIXED: url_launcher new API
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch Google Calendar");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Fetch events on page load
  }

  @override
  Widget build(BuildContext context) {
    // Filter events for selected date
    final dailyEvents = events.where((event) {
      if (event['date'] == null) return false;
      final eventDate = DateTime.parse(event['date']).toLocal();
      return eventDate.year == _selectedDate.year &&
          eventDate.month == _selectedDate.month &&
          eventDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.arrow_back, color: Colors.black, size: 18),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text('Calendar',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        actions: [
          // IconButton(
          //   icon: SvgPicture.asset(
          //     'assets/images/settings2.svg',
          //     width: 18,
          //     height: 18,
          //     color: Color(0xFF862633),
          //   ),
          //   onPressed: () {},
          // ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar widget
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF862633),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2022),
                lastDate: DateTime(2026),
                onDateChanged: (value) {
                  setState(() {
                    _selectedDate = value; // update selected date
                  });
                },
              ),
            ),

            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Daily Tasks",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (dailyEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No events for this day."),
              )
            else
              ...dailyEvents.map((event) {
                final color = getColorFromStatus(event['status'] ?? 'grey');
                return GestureDetector(
                  onTap: () => openInGoogleCalendar(event),
                  child: buildEventContainer(event, color),
                );
              }).toList(),

            const SizedBox(height: 24),
          ],
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}

// Build individual event container
Widget buildEventContainer(Map<String, dynamic> event, Color bgColor) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          event['title'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          event['date'] != null
              ? DateTime.parse(event['date']).toLocal().toString().split(' ')[0]
              : '',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    ),
  );
}
