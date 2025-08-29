import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(selectedDate);
    final isToday = DateUtils.dateOnly(DateTime.now()) ==
        DateUtils.dateOnly(selectedDate);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: const Color(0xFFFAFBFB),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
              color: const Color(0xFF862633),
            ),
            Column(
              children: [
                if(isToday)
                Text(
                   'Today',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF862633),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
              color: const Color(0xFF862633),
            ),
          ],
        ),
      ),
    );
  }
}
