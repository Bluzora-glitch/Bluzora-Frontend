import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'vegetableForecastCard.dart';
import 'ComparisonGraph.dart';

class ComparisonPage extends StatefulWidget {
  @override
  _ComparisonPageState createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  String? startDate;
  String? endDate;
  List<String> selectedVegetables = [];

  // โหลดข้อมูลผักจาก API
  List<Map<String, dynamic>> vegetables = [];
  bool isForecastVisible = false;

  @override
  void initState() {
    super.initState();
    loadVegetablesData();
  }

  // โหลดข้อมูลผักจาก API (/api/crop-info-list/)
  Future<void> loadVegetablesData() async {
    const url = 'http://127.0.0.1:8000/api/crop-info-list/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> resultList = [];
        if (jsonData == null) {
          resultList = [];
        } else if (jsonData is List) {
          resultList = List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey("results")) {
          resultList = List<Map<String, dynamic>>.from(jsonData["results"]);
        }
        setState(() {
          vegetables = resultList;
        });
        print("Vegetable data loaded from API: $vegetables");
      } else {
        print('Error loading vegetables: ${response.statusCode}');
        setState(() {
          vegetables = [];
        });
      }
    } catch (e) {
      print('Exception loading vegetables: $e');
      setState(() {
        vegetables = [];
      });
    }
  }

  // ฟังก์ชันสำหรับเรียก API /api/quarterly-avg/ เพื่อดึงข้อมูล forecast
  Future<Map<String, dynamic>> fetchForecastData(String cropName) async {
    final url = 'http://127.0.0.1:8000/api/combined-priceforecast/'
        '?vegetableName=$cropName'
        '&startDate=$startDate'
        '&endDate=$endDate';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load forecast data');
    }
    final String utf8Body = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> json = jsonDecode(utf8Body);

    // 1. แยก results ออกเป็น historical vs predicted
    final List<dynamic> results = json['results'] as List<dynamic>;
    final dailyPrices = results
        .where((e) => e['type'] == 'historical')
        .map((e) => <String, String>{
              'date': e['date'] as String,
              'min_price': e['min_price'].toString(),
              'max_price': e['max_price'].toString(),
              'average_price': e['price'].toString(),
            })
        .toList();
    final predictedPrices = results
        .where((e) => e['type'] == 'predicted')
        .map((e) => <String, String>{
              'date': e['date'] as String,
              'predicted_price': e['price'].toString(),
            })
        .toList();

    // 2. อ่านชื่อผัก (crop_name) จากผลลัพธ์
    final name =
        results.isNotEmpty ? (results.first['crop_name'] as String) : cropName;

    // 3. ดึง summary จาก overall_summary
    final summary = (json['overall_summary'] as Map<String, dynamic>?) ?? {};

    // คืนข้อมูลในรูปแบบที่ UI เดิมคาดหวัง
    return {
      'name': name,
      'dailyPrices': dailyPrices,
      'predictedPrices': predictedPrices,
      'summary': summary,
    };
  }

  // ฟังก์ชันรวบรวมข้อมูล forecast สำหรับผักที่เลือกทั้งหมด
  Future<List<Map<String, dynamic>>> _fetchAllForecastData() async {
    List<Map<String, dynamic>> results = [];
    for (var vegName in selectedVegetables) {
      final data = await fetchForecastData(vegName);
      // ให้แน่ใจว่ามี key สองอันนี้แม้ API คืนมาเป็น null
      final dp = data['dailyPrices'] as List<dynamic>? ?? [];
      final pp = data['predictedPrices'] as List<dynamic>? ?? [];
      results.add({
        'name': data['name'] ?? vegName,
        'dailyPrices': dp,
        'predictedPrices': pp,
        'summary': data['summary'] ?? {},
      });
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingHorizontal;
    double cardWidth;
    double dropdownWidth;

    if (screenWidth > 1024) {
      paddingHorizontal = 70;
      cardWidth = 250;
      dropdownWidth = 250;
    } else if (screenWidth > 600) {
      paddingHorizontal = 50;
      cardWidth = 200;
      dropdownWidth = 200;
    } else {
      paddingHorizontal = 20;
      cardWidth = 160;
      dropdownWidth = double.infinity;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF0),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนเลือกช่วงเวลา
              const Text(
                'เลือกช่วงเวลา',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
// DatePicker สำหรับ startDate
                  SizedBox(
                    width: dropdownWidth,
                    child: GestureDetector(
                      onTap: () async {
                        DateTime initialDate = startDate != null
                            ? DateTime.parse(startDate!)
                            : DateTime.now();
                        // กำหนด lastDate เป็นวันที่สิ้นสุดที่เลือกไว้ (ถ้ามี) ไม่เช่นนั้นใช้ DateTime(2030)
                        final DateTime lastDate = endDate != null
                            ? DateTime.parse(endDate!)
                            : DateTime(2030);
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(2020),
                          lastDate: lastDate,
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'วันที่เริ่มต้น',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        child: Text(startDate ?? ''),
                      ),
                    ),
                  ),

// DatePicker สำหรับ endDate
                  SizedBox(
                    width: dropdownWidth,
                    child: GestureDetector(
                      onTap: () async {
                        DateTime initialDate = endDate != null
                            ? DateTime.parse(endDate!)
                            : DateTime.now();
                        final DateTime today = DateTime.now();
                        // กำหนด maxEndDate ให้เป็น 90 วันล่วงหน้าจากวันนี้
                        final DateTime maxEndDate =
                            today.add(Duration(days: 90));
                        // กำหนด firstDate เป็นวันที่เริ่มต้นที่เลือกไว้ (ถ้ามี) ไม่เช่นนั้นใช้ DateTime(2020)
                        final DateTime firstDate = startDate != null
                            ? DateTime.parse(startDate!)
                            : DateTime(2020);
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate:
                              maxEndDate, // จำกัดให้เลือกไม่เกิน 90 วันล่วงหน้าจากวันนี้
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'วันที่สิ้นสุด',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        child: Text(endDate ?? ''),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // ผักที่ต้องการเปรียบเทียบ
              const Text(
                'ผักที่ต้องการเปรียบเทียบ',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'เลือกผักที่ต้องการเปรียบเทียบ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  items: vegetables.map((veg) {
                    final name = veg['name'] as String? ?? 'ไม่ระบุชื่อ';
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && !selectedVegetables.contains(value)) {
                      setState(() {
                        selectedVegetables.add(value);
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),
              // แสดงการ์ดผักที่เลือก
              if (selectedVegetables.isNotEmpty)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: selectedVegetables.map((vegName) {
                    final vegetable =
                        vegetables.firstWhere((v) => v['name'] == vegName);
                    return SizedBox(
                      width: cardWidth,
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Image.network(
                              vegetable['image'],
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/vegetables.jpg',
                                  height: 120,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vegetable['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              vegetable['price'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  selectedVegetables.remove(vegName);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isForecastVisible = true;
                    });
                    print('เริ่มการคำนวณ...');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('เปรียบเทียบราคาพืช'),
                ),
              ),

              const SizedBox(height: 32),
              // แสดงผลการคำนวณการพยากรณ์
              if (isForecastVisible && selectedVegetables.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'แดชบอร์ดเปรียบเทียบราคาพืช',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedVegetables.length,
                      itemBuilder: (context, index) {
                        final vegName = selectedVegetables[index];
                        final vegetable =
                            vegetables.firstWhere((v) => v['name'] == vegName);
                        return FutureBuilder<Map<String, dynamic>>(
                          future: (startDate == null || endDate == null)
                              // ถ้า startDate หรือ endDate ยังเป็น null, ให้ส่ง Future.error หรือ Future.value({})
                              ? Future.error("ยังไม่ได้เลือกวันที่")
                              : fetchForecastData(vegName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            } else {
                              final forecastData = snapshot.data ?? {};
                              return VegetableForecastCard(
                                imageUrl: vegetable['image'],
                                name: vegetable['name'],
                                price: 'ราคาพยากรณ์: ${vegetable['price']}',
                                startDate: startDate ?? '',
                                endDate: endDate ?? '',
                                summary: forecastData['summary'] ??
                                    {
                                      "overall_average": 0.0,
                                      "overall_min": 0.0,
                                      "overall_max": 0.0,
                                      "price_change": "-"
                                    },
                                graphDailyPrices:
                                    forecastData['dailyPrices'] ?? [],
                                graphPredictedPrices:
                                    forecastData['predictedPrices'] ?? [],
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 32),
              // ส่วนแสดงกราฟเปรียบเทียบราคาผัก
              const Text(
                'กราฟเปรียบเทียบราคาผัก',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // ตรวจสอบก่อนว่า startDate / endDate เป็น null หรือไม่
              if (startDate == null || endDate == null)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Text(
                    "กรุณาเลือกวันที่",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                // เมื่อมี startDate และ endDate แล้ว จึงเรียก FutureBuilder
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchAllForecastData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      final forecastDataList = snapshot.data ?? [];
                      return ComparisonGraph(
                        forecastDataList: forecastDataList,
                        startDate: DateTime.parse(startDate!),
                        endDate: DateTime.parse(endDate!),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
