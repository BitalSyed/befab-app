import 'package:flutter/material.dart';

class EditableGoalInputBox extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;

  const EditableGoalInputBox({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF121714),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF638773),
            ),
            filled: true,
            fillColor: const Color(0xFFF0F5F2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Matches original style (no border)
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF638773),
          ),
        ),
      ],
    );
  }
}
