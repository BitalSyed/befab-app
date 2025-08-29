import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeightLossProgressChart extends StatefulWidget {
  const WeightLossProgressChart({Key? key}) : super(key: key);

  @override
  State<WeightLossProgressChart> createState() => _WeightLossProgressChartState();
}

class _WeightLossProgressChartState extends State<WeightLossProgressChart> {
  List<Map<String, dynamic>> _nutritionData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  double _maxCalories = 1000; // Default max calories for scaling

  @override
  void initState() {
    super.initState();
    _fetchNutritionDataForChart();
  }

  Future<void> _fetchNutritionDataForChart() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Fetch data for the last 6 days (including today)
      final List<Map<String, dynamic>> dataList = [];
      final DateTime now = DateTime.now();
      
      for (int i = 5; i >= 0; i--) {
        final DateTime date = now.subtract(Duration(days: i));
        final Map<String, dynamic>? data = await _fetchNutritionDataForDate(date);
        
        if (data != null) {
          final double totalCalories = _calculateTotalCalories(data);
          dataList.add({
            'date': date,
            'data': data,
            'totalCalories': totalCalories,
          });
        }
      }

      // Calculate max calories for scaling
      if (dataList.isNotEmpty) {
        _maxCalories = dataList
            .map((data) => data['totalCalories'])
            .cast<double>()
            .reduce((a, b) => a > b ? a : b);
        
        // Ensure maxCalories is at least 500 for better chart visibility
        _maxCalories = _maxCalories < 500 ? 500 : _maxCalories;
      }

      setState(() {
        _nutritionData = dataList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data';
      });
      print('❌ Error fetching nutrition data for chart: $e');
    }
  }

  Future<Map<String, dynamic>?> _fetchNutritionDataForDate(DateTime date) async {
    try {
      final String backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      if (backendUrl.isEmpty) {
        throw Exception('BACKEND_URL is empty in .env');
      }

      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('No auth token found in storage');
      }

      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final String url = '$backendUrl/app/nutrition/$formattedDate';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Return empty data structure for dates with no data
        return {
          'meals': {
            'other': [],
            'breakfast': [],
            'lunch': [],
            'dinner': [],
            'snacks': []
          },
          'date': formattedDate
        };
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching nutrition data for date: $e');
      return null;
    }
  }

  double _calculateTotalCalories(Map<String, dynamic> data) {
    try {
      double totalCalories = 0;
      
      if (data.containsKey('meals') && data['meals'] is Map) {
        final Map<String, dynamic> meals = data['meals'];
        
        meals.forEach((category, items) {
          if (items is List) {
            for (var item in items) {
              if (item is Map<String, dynamic> && item.containsKey('calories')) {
                totalCalories += (item['calories'] as num).toDouble();
              }
            }
          }
        });
      }
      
      return totalCalories;
    } catch (e) {
      print('❌ Error calculating total calories: $e');
      return 0;
    }
  }

  List<FlSpot> _getChartSpots() {
    if (_nutritionData.isEmpty) {
      return [];
    }

    return List.generate(_nutritionData.length, (index) {
      return FlSpot(index.toDouble(), _nutritionData[index]['totalCalories']);
    });
  }

  List<String> _getDayLabels() {
    if (_nutritionData.isEmpty) {
      return [];
    }

    return _nutritionData.map((data) {
      final DateTime date = data['date'];
      return DateFormat('d').format(date); // Day of month without leading zero
    }).toList();
  }

  List<double> _getYAxisValues() {
    if (_maxCalories <= 0) return [0, 250, 500, 750, 1000];
    
    final double interval = _maxCalories / 4;
    return [
      0,
      interval,
      interval * 2,
      interval * 3,
      _maxCalories
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories Progress',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.grey[600], size: 24),
                onPressed: _fetchNutritionDataForChart,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage.isNotEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_nutritionData.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    verticalInterval: 1,
                    horizontalInterval: _maxCalories / 4,
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [3, 3],
                      );
                    },
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [3, 3],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          );
                          
                          if (value >= 0 && value < _nutritionData.length) {
                            final dayLabel = _getDayLabels()[value.toInt()];
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(dayLabel, style: style),
                            );
                          }
                          return const Text('', style: style);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _maxCalories / 4,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          );
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toInt().toString(), style: style),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                  minX: 0,
                  maxX: _nutritionData.length > 1 ? (_nutritionData.length - 1).toDouble() : 1,
                  minY: 0,
                  maxY: _maxCalories,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getChartSpots(),
                      isCurved: true,
                      curveSmoothness: 0.4,
                      color: const Color(0xFF8B1538),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF8B1538),
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B1538).withOpacity(0.3),
                            const Color(0xFF8B1538).withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < _nutritionData.length) {
                            final actualCalories = _nutritionData[index]['totalCalories'];
                            final date = _nutritionData[index]['date'];
                            return LineTooltipItem(
                              '${actualCalories.toStringAsFixed(0)} cal\n${DateFormat('MMM d').format(date)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return LineTooltipItem('', const TextStyle());
                        }).toList();
                      },
                      // tooltipBgColor: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}