import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:befab/Screens/GoalSetSuccessPage.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/InputBox.dart';
import 'package:befab/components/ProgressSwitchRow.dart';
import 'package:befab/components/StepsChart.dart';

class NewGoalPage extends StatefulWidget {
  const NewGoalPage({Key? key}) : super(key: key);

  @override
  State<NewGoalPage> createState() => _NewGoalPageState();
}

class _NewGoalPageState extends State<NewGoalPage> {
  final TextEditingController goalController = TextEditingController();
  final TextEditingController monthsController = TextEditingController();
  final TextEditingController milestoneController = TextEditingController();

  bool trackProgress = true; // from ProgressSwitchRow (you can bind later)

  @override
  void dispose() {
    goalController.dispose();
    monthsController.dispose();
    milestoneController.dispose();
    super.dispose();
  }

  // create storage instance (at class level)
final storage = const FlutterSecureStorage();

Future<void> _setGoal() async {
  final String? baseUrl = dotenv.env['BACKEND_URL'];
  if (baseUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("BACKEND_URL not set")),
    );
    return;
  }

  try {
    // get token from secure storage
    final token = await storage.read(key: "token");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No token found, please login again.")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/app/goals"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": goalController.text.trim(),
        "durationDays": int.tryParse(monthsController.text.trim()) ?? 0,
        "milestones": milestoneController.text.trim(),
        "trackProgress": trackProgress, // make sure this is defined in your state
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Reset fields
      goalController.clear();
      monthsController.clear();
      milestoneController.clear();

      // Navigate to dashboard
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/dashboard",
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
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
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/images/cross.svg',
                width: 15,
                height: 15,
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'New Goal',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EditableGoalInputBox(
                title: "What's your goal",
                hintText: "Drink more water, sleep better, get fit",
                controller: goalController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EditableGoalInputBox(
                title: "By when (days)",
                hintText: "e.g., 150",
                controller: monthsController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EditableGoalInputBox(
                title: "Milestones",
                hintText: "1,000 steps",
                controller: milestoneController,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Get Personalized Tips",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ProgressSwitchRow(), // later bind this to `trackProgress`

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Steps in 20 days"),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "10k",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
              ),
            ),
            const StepsChart(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF862633),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _setGoal,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('Set Goal', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }
}
