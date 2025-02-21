import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'vegetableForecastCard.dart';

class ComparisonPage extends StatefulWidget {
  @override
  _ComparisonPageState createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  String? startDate;
  String? endDate;
  List<String> selectedVegetables = [];

  List<Map<String, dynamic>> vegetables = [];
  bool isForecastVisible = false;

  @override
  void initState() {
    super.initState();
    loadVegetablesData();
  }

  Future<void> loadVegetablesData() async {
    final String jsonString =
        await rootBundle.loadString('assets/vegetables.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      vegetables = jsonData.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF0),
      body: LayoutBuilder(builder: (context, constraints) {
        // เช็คความกว้างหน้าจอ
        double screenWidth = constraints.maxWidth;
        double paddingHorizontal;
        double cardWidth;
        double dropdownWidth;

        // ปรับขนาดตามหน้าจอ
        if (screenWidth > 1024) {
          // Desktop
          paddingHorizontal = 70;
          cardWidth = 250;
          dropdownWidth = 250;
        } else if (screenWidth > 600) {
          // Tablet
          paddingHorizontal = 50;
          cardWidth = 200;
          dropdownWidth = 200;
        } else {
          // Mobile
          paddingHorizontal = 20;
          cardWidth = 160;
          dropdownWidth = double.infinity;
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // เลือกช่วงเวลา
                const Text(
                  'เลือกช่วงเวลา',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Dropdown เลือกวันที่
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: dropdownWidth,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'วันที่เริ่มต้น',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: vegetables
                            .expand(
                                (veg) => veg['dailyPrices'] as List<dynamic>)
                            .map((priceData) => priceData['date'] as String)
                            .toSet()
                            .toList()
                            .map((date) {
                          return DropdownMenuItem(
                              value: date, child: Text(date));
                        }).toList(),
                        onChanged: (value) => setState(() => startDate = value),
                      ),
                    ),
                    SizedBox(
                      width: dropdownWidth,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'วันที่สิ้นสุด',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: vegetables
                            .expand(
                                (veg) => veg['dailyPrices'] as List<dynamic>)
                            .map((priceData) => priceData['date'] as String)
                            .toSet()
                            .toList()
                            .map((date) {
                          return DropdownMenuItem(
                              value: date, child: Text(date));
                        }).toList(),
                        onChanged: (value) => setState(() => endDate = value),
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
                    decoration: InputDecoration(
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
                      if (value != null &&
                          !selectedVegetables.contains(value)) {
                        setState(() {
                          selectedVegetables.add(value);
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // การ์ดผักที่เลือก
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
                              Image.asset(
                                vegetable['image'],
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                vegetable['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
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

                // ปุ่มสำหรับทำการคำนวณการพยากรณ์
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic สำหรับการคำนวณ
                      setState(() {
                        isForecastVisible = true; // กดแล้วจะแสดงการ์ดใหม่
                      });
                      print('เริ่มการคำนวณ...');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('ทำการคำนวณการพยากรณ์'),
                  ),
                ),

                const SizedBox(height: 32),

                // การ์ดใหม่แสดงผลการคำนวณ
                if (isForecastVisible && selectedVegetables.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ผลการคำนวณการพยากรณ์',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedVegetables.length,
                        itemBuilder: (context, index) {
                          final vegName = selectedVegetables[index];
                          final vegetable = vegetables
                              .firstWhere((v) => v['name'] == vegName);

                          // ใช้ VegetableForecastCard แทน
                          return VegetableForecastCard(
                            imageUrl:
                                vegetable['image'], // เปลี่ยนเป็นพาธของรูปภาพ
                            name: vegetable['name'], // ชื่อผัก
                            price:
                                'ราคาพยากรณ์: ${vegetable['price']}', // ราคาที่ต้องการแสดง
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
