import 'package:flutter/material.dart';

class MealTypeSelector extends StatefulWidget {
  final List<MealOption> meals;
  final Function(int)? onMealSelected;
  final String title;

  const MealTypeSelector({
    Key? key,
    required this.meals,
    this.onMealSelected,
    this.title = 'Select Meal Type',
  }) : super(key: key);

  @override
  _MealTypeSelectorState createState() => _MealTypeSelectorState();
}

class _MealTypeSelectorState extends State<MealTypeSelector> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: widget.meals.length,
          itemBuilder: (context, index) {
            final meal = widget.meals[index];
            final isSelected = selectedIndex == index;
            
            return Container(
              margin: EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  if (widget.onMealSelected != null) {
                    widget.onMealSelected!(index);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isSelected ? meal.selectedBgColor : meal.bgColor,
                    border: Border.all(
                      color: isSelected ? meal.selectedBorderColor : meal.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? meal.selectedTextColor : meal.textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${meal.calories} Calories',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected 
                              ? meal.selectedSubtextColor 
                              : meal.subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class MealOption {
  final String name;
  final int calories;
  final Color textColor;
  final Color subtextColor;
  final Color bgColor;
  final Color borderColor;
  final Color selectedTextColor;
  final Color selectedSubtextColor;
  final Color selectedBgColor;
  final Color selectedBorderColor;

  MealOption({
    required this.name,
    required this.calories,
    this.textColor = const Color(0xFF862633), // Brown color
    this.subtextColor = const Color(0xFF000000), // Gray color
    this.bgColor = const Color(0xFFFAFBFB), // Light gray background
    this.borderColor = const Color(0xFFE0E0E0), // Light border
    this.selectedTextColor = const Color(0xFF862633), // Brown color
    this.selectedSubtextColor = const Color(0xFF000000), // Gray color
    this.selectedBgColor = const Color.fromRGBO(134, 38, 51, 0.05), // Light pink background
    this.selectedBorderColor = const Color(0xFF862633), // Brown border
  });
}