import 'package:flutter/material.dart';

class ProgressSwitchRow extends StatefulWidget {
  @override
  _ProgressSwitchRowState createState() => _ProgressSwitchRowState();
}

class _ProgressSwitchRowState extends State<ProgressSwitchRow> {
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF121714),
            ),
          ),
        ),
        Switch(
  value: isSwitched,
  onChanged: (value) {
    setState(() {
      isSwitched = value;
    });
  },
  activeColor: Colors.white,                         // Thumb when ON
  activeTrackColor: Color(0xFF862633),                // Track when ON (deep red)
  inactiveThumbColor: Color(0xFF862633),              // Thumb when OFF
  inactiveTrackColor: Color(0xFF862633).withOpacity(0.3), // Track when OFF (lighter red)
),


      ],
    );
  }
}
