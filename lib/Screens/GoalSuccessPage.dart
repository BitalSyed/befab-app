import 'package:flutter/material.dart';

class GoalSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Color(0xFFF0FFF4), // Light background (optional)
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 12),
            Text(
              "Goal Set Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "Your new goal has been added.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF61788A),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}