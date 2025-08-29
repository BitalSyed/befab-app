import 'package:befab/Screens/ActivityCalendarPage.dart';
import 'package:befab/components/BarCodeScannerWidget.dart';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/FavouritesGridWidget.dart';
import 'package:befab/components/HeadingWithImageRow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/health_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class SearchFood extends StatefulWidget {
  @override
  _SearchFoodState createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  Map<String, dynamic>? nutritionData;
  List<dynamic> foods = [];
  List<dynamic> filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<Map<String, dynamic>?> fetchNutritionData() async {
    try {
      // Get backend URL
      await dotenv.load();
      final String backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      if (backendUrl.isEmpty) {
        print("⚠️ BACKEND_URL is empty in .env");
        return null;
      }

      // Get token from secure storage
      final token = await secureStorage.read(key: 'token');
      if (token == null) {
        print("⚠️ No auth token found in storage");
        return null;
      }

      // Get current date in YYYY-MM-DD format
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Build full URL
      final String url = '$backendUrl/app/nutrition/$currentDate';
      final String url1 = '$backendUrl/app/nutrition/get/foods';
      print("Fetching nutrition data from: $url");

      // Make GET request with Authorization header
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final response1 = await http.get(
        Uri.parse(url1),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response1.statusCode == 200) {
        List<dynamic> data = jsonDecode(response1.body);
        print("✅ Foods: $data");
        setState(() {
          foods = data;
        });
      } else {
        print('⚠️ Failed to fetch foods. Status code: ${response1.statusCode}');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print("✅ Nutrition data fetched successfully");
        return data;
      } else {
        print('⚠️ Failed to fetch data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching nutrition data: $e');
      return null;
    }
  }

  void getData() async {
    final data = await fetchNutritionData();
    if (data != null) {
      setState(() {
        nutritionData = data;
        print("data_nutrition: $nutritionData");
      });
    }
  }

  Future<void> _submitMealData1(String foodName, num calories, {int quantity = 1}) async {
    try {
      // Get token from secure storage
      final token = await secureStorage.read(key: 'token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication required'))
        );
        return;
      }

      // Get current date in YYYY-MM-DD format
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "bucket": "other",
        "item": {
          "name": foodName, 
          "calories": calories,
          "quantity": quantity
        },
      };

      // Make the API call
      await dotenv.load();
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/app/nutrition/$currentDate/meal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal added successfully!'))
        );
        getData(); // Refresh the data
        
        // Clear search and hide results
        setState(() {
          _searchController.clear();
          filteredFoods.clear();
        });
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meal: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  // Get recent foods from all meal categories
  List<dynamic> getRecentFoods() {
    if (nutritionData == null || nutritionData!['meals'] == null) return [];
    
    List<dynamic> allFoods = [];
    final meals = nutritionData!['meals'] as Map<String, dynamic>;
    
    // Combine foods from all meal categories
    meals.forEach((category, items) {
      if (items is List) {
        allFoods.addAll(items);
      }
    });
    
    // Return the most recent foods (limit to 4 for display)
   return allFoods.reversed.toList().sublist(0, allFoods.length > 4 ? 4 : allFoods.length);
  }

  @override
  Widget build(BuildContext context) {
    final List<FavouriteCategory> sampleCategories = [
      FavouriteCategory.withIcon(
        name: 'Fruits',
        icon: Icons.apple,
        iconColor: Color(0xFF862633),
      ),
      FavouriteCategory.withIcon(
        name: 'Vegetables',
        icon: Icons.eco,
        iconColor: Color(0xFF862633),
      ),
      FavouriteCategory.withIcon(
        name: 'Grains',
        icon: Icons.grass,
        iconColor: Color(0xFF862633),
      ),
      FavouriteCategory.withIcon(
        name: 'Dairy',
        icon: Icons.local_drink,
        iconColor: Color(0xFF862633),
      ),
      FavouriteCategory.withIcon(
        name: 'Proteins',
        icon: Icons.restaurant,
        iconColor: Color(0xFF862633),
      ),
      FavouriteCategory.withIcon(
        name: 'More',
        icon: Icons.more_horiz,
        iconColor: Color(0xFF862633),
      ),
    ];
    
    final recentFoods = getRecentFoods();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  'assets/images/Arrow.svg',
                  width: 14,
                  height: 14,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'Back',
                style: GoogleFonts.inter(
                  color: Color(0xFF862633),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          'Search Food',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEDF0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        setState(() {
                          final seen = <String>{};
                          if (query.isEmpty) {
                            filteredFoods = [];
                          } else {
                            filteredFoods = foods.where((food) {
                              final name = food['name']?.toString().toLowerCase() ?? '';
                              return name.contains(query.toLowerCase());
                            }).toList();
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search foods....",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF5E6B87),
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color(0xFF5E6B87),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // Search results
                  if (filteredFoods.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final item = filteredFoods[index];
                        return ListTile(
                          title: Text(item['name'] ?? 'Unknown Food'),
                          subtitle: Text("${item['calories'] ?? 0} cal"),
                          trailing: IconButton(
                            icon: Icon(Icons.add, color: Color(0xFF862633)),
                            onPressed: () {
                              _submitMealData1(
                                item['name'] ?? 'Unknown Food',
                                item['calories'] ?? 0,
                                quantity: item['quantity'] ?? 1,
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: Color(0xFF862633),
                        width: 1,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BarcodeScannerScreen(),
                      ),
                    );
                    if (result != null && result['name'] != null) {
                      await _submitMealData1(
                        result['name'],
                        result['calories'] ?? 0,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBarcode(),
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
            
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFF862633),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(24),
            //         ),
            //       ),
            //       onPressed: () {
            //         // TODO: Implement manual entry functionality
            //         showDialog(
            //           context: context,
            //           builder: (context) => AlertDialog(
            //             title: Text("Manual Entry"),
            //             content: Text("Manual entry functionality to be implemented"),
            //             actions: [
            //               TextButton(
            //                 onPressed: () => Navigator.pop(context),
            //                 child: Text("OK"),
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //       child: Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            //         child: Text(
            //           'Manual Entry',
            //           style: GoogleFonts.lexend(
            //             color: Colors.white,
            //             fontWeight: FontWeight.w700,
            //             fontSize: 16,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            
            // Recent Foods Section
            if (recentFoods.isNotEmpty)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Recent Foods",
                          style: GoogleFonts.lexend(
                            color: Color(0xFF000000),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
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
                  
                  // Display recent foods
                  ...recentFoods.map((food) {
                    final name = food['name'] ?? 'Unknown Food';
                    final calories = food['calories'] ?? 0;
                    final quantity = food['quantity'] ?? 1;
                    
                    return HeadingWithImageRow(
                      heading: name,
                      subtitle: "$quantity serving(s), $calories cal",
                      // trailingWidget: IconButton(
                      //   icon: const Icon(
                      //     Icons.add_circle,
                      //     size: 32,
                      //     color: Color(0xFF862633),
                      //   ),
                      //   onPressed: () {
                      //     _submitMealData1(name, calories, quantity: quantity);
                      //   },
                      // ),
                    );
                  }).toList(),
                ],
              ),
            
            // My Favorites Section
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "My Favourites",
            //         style: GoogleFonts.lexend(
            //           color: Color(0xFF000000),
            //           fontSize: 22,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text(
            //         "view all",
            //         style: GoogleFonts.lexend(
            //           color: Color(0xFF862633),
            //           fontSize: 16,
            //           fontWeight: FontWeight.w400,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            
            // FavouritesGridWidget(
            //   categories: sampleCategories,
            //   onViewAllTap: () {
            //     print('View all tapped!');
            //   },
            //   onCategoryTap: (category) {
            //     print('Category tapped: ${category.name}');
            //   },
            // ),
            
            SizedBox(height: 24),
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

Future<Map<String, dynamic>?> fetchProductFromBarcode(String barcode) async {
  final url = Uri.parse(
    "https://world.openfoodfacts.org/api/v0/product/$barcode.json",
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 1) {
      return data['product'];
    } else {
      return null;
    }
  } else {
    throw Exception("API Error: ${response.statusCode}");
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) async {
          if (_scanned) return;
          _scanned = true;

          final barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;
            if (code != null) {
              try {
                final product = await fetchProductFromBarcode(code);

                if (product != null && mounted) {
                  Navigator.pop(context, {
                    "barcode": code,
                    "name": product["product_name"] ?? "Unknown",
                    "brand": product["brands"] ?? "N/A",
                    "calories": product["nutriments"]?["energy-kcal_100g"],
                  });
                } else {
                  if (mounted) {
                    Navigator.pop(context, {
                      "barcode": code,
                      "error": "Product not found",
                    });
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context, {
                    "barcode": code,
                    "error": "API error: $e",
                  });
                }
              }
            }
          }
        },
      ),
    );
  }
}
