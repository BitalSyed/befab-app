import 'package:flutter/material.dart';

class GoalSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 16),
        child: Container(
          width: 560,
          height: 120,
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(width: 8),
              Text(
                "Goal Set Successfully!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
            "Your new goal has been added.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF61788A),
              fontWeight: FontWeight.w400,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
