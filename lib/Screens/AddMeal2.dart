import 'package:befab/components/AddedItemsList.dart';
import 'package:befab/components/CustomAppHeader.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/DateSelector.dart';
import 'package:befab/components/HeadingWithImageRow.dart';
import 'package:befab/components/MealTypeSelector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class AddMeal2 extends StatefulWidget {
  @override
  _AddMeal2State createState() => _AddMeal2State();
}

class _AddMeal2State extends State<AddMeal2> {
DateTime selectedDate = DateTime.now();
  final List<MealOption> sampleMeals = [
    MealOption(
      name: 'Breakfast',
      calories: 320,
    ),
    MealOption(
      name: 'Lunch',
      calories: 480,
    ),
    MealOption(
      name: 'Dinner',
      calories: 450,
    ),
    MealOption(
      name: 'Snack',
      calories: 0,
    ),
  ];
  final List<AddedItem> sampleItems = [
    AddedItem.food(
      name: 'Scrambled Eggs',
      servingInfo: '2 Large Eggs',
      calories: 140,
      quantity: 2,
    ),
    AddedItem.food(
      name: 'Whole White Toast',
      servingInfo: '1 Slice',
      calories: 80,
      quantity: 1,
    ),
    
  ];
  void _goToPrevious() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNext() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leftWidget: Row(
          children: [
            SvgPicture.asset('assets/images/Arrow.svg', width: 14, height: 14),
            SizedBox(width: 4),
            Text(
              "Back",
              style: TextStyle(
                color: Color(0xFF862633),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        onLeftTap: () => Navigator.pop(context),
        title: "Add Meal",
        // rightWidget: Icon(Icons.more_vert, color: Colors.black),
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            DateSelector(
              selectedDate: selectedDate,
              onPrevious: _goToPrevious,
              onNext: _goToNext,
            ),
            MealTypeSelector(
              title: 'Select Meal Type',
              meals: sampleMeals,
              onMealSelected: (index) {
                print('Selected meal: ${sampleMeals[index].name}');

              },
              
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Add Food Items",
                  style: GoogleFonts.lexend(
                          color: Color(0xFF000000),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEBEDF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search foods....",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF5E6B87),
                    ),
                    border: InputBorder.none,
                    isCollapsed: true, // removes extra vertical space
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ), // better vertical alignment
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF5E6B87),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity, // Makes the button take full width

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: Color(0xFF862633), // Border color
                        width: 1,
                      ),
                    ),
                  ),
onPressed: () {},                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBarcode(), // Ensure this has no padding/margin
                        // No SizedBox or spacing here
                        Text(
                          'Scan Barcode',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF862633),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity, // Makes the button take full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF862633),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
onPressed: () {},                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: Text(
                      'Manual Entry',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700, // Optional: make it a bit bolder
                        fontSize: 16, // Optional: specify a font size
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            
            
           
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Recent Foods",
                    style: GoogleFonts.inter(
                            color: Color(0xFF000000),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  Text(
                    "view all",
                    style: GoogleFonts.lexend(
                            color: Color(0xFF862633),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                  ),
                ),
              ],
            ),
            
            
            
            HeadingWithImageRow(
              heading: "Scrambled Eggs",
              subtitle: "2 Large eggs, 140 cal",
              trailingWidget: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                  color: Color(0xFF862633),
                ),
                onPressed: () {}
              ),
            ),
            HeadingWithImageRow(
              heading: "Whole white toast",
              subtitle: "1 slice, 80 cal",
              trailingWidget: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                  color: Color(0xFF862633),
                ),
                onPressed: () {}
              ),
            ),
            HeadingWithImageRow(
              heading: "Apple",
              subtitle: "1 Medium, 140 cal",
              trailingWidget: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                  color: Color(0xFF862633),
                ),
                onPressed: () {}
              ),
            ),
            HeadingWithImageRow(
              heading: "Coffee with milk",
              subtitle: "2 cups, 40 cal",
              trailingWidget: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                  color: Color(0xFF862633),
                ),
                onPressed: () {}
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "My Favourits",
                    style: GoogleFonts.inter(
                            color: Color(0xFF000000),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  Text(
                    "view all",
                    style: GoogleFonts.lexend(
                            color: Color(0xFF862633),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                  ),
                ),
              ],
            ),
            
            
            
            HeadingWithImageRow(
              heading: "Breakfast bowel",
              subtitle: "320 cal",
              trailingWidget: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                  color: Color(0xFF862633),
                ),
                          onPressed: () {},

              ),
            ),
            HeadingWithImageRow(
              heading: "Greek Yogurt",
              subtitle: "140 cal",
              trailingWidget: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                  color: Color(0xFF862633),
                ),
                          onPressed: () {},

              ),
            ),

            AddedItemsList(
              title: 'Added Items',
              items: sampleItems,
              onItemRemoved: (index) {
                print('Item removed at index: $index');
              },
              onQuantityChanged: (index, newQuantity) {
                print('Quantity changed for item $index: $newQuantity');
              },
            ),
            
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Total calories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
          Text("Proteins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
          Text("Carbs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
          Text("Fat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("250 cal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
          Text("14 g", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
          Text("12 g", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
          Text("15 g", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xFF000000))),
        ],
      ),
    ),
  ],
),
    
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity, // Makes the button take full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF862633),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: Text(
                      'Save Breakfast',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700, // Optional: make it a bit bolder
                        fontSize: 16, // Optional: specify a font size
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24,)
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}


Widget _buildBarcode() {
  return Container(
    height: 20,
    width: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBarcodeBar(width: 2, height: 25),
        SizedBox(width: 2),
        _buildBarcodeBar(width: 1, height: 30),
        SizedBox(width: 3),
        _buildBarcodeBar(width: 3, height: 20),
        SizedBox(width: 2),
        _buildBarcodeBar(width: 2, height: 25),
        SizedBox(width: 1),
        _buildBarcodeBar(width: 2, height: 25),
        SizedBox(width: 4),
        _buildBarcodeBar(width: 3, height: 30),
        SizedBox(width: 2),
        _buildBarcodeBar(width: 2, height: 20),
        SizedBox(width: 1),
        _buildBarcodeBar(width: 1, height: 25),
        SizedBox(width: 3),
        _buildBarcodeBar(width: 2, height: 25),
      ],
    ),
  );
}

Widget _buildBarcodeBar({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Color(0xFF862633),
      borderRadius: BorderRadius.circular(0.5),
    ),
  );
}