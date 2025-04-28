import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/foundation.dart';
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

  List<Map<String, dynamic>> vegetables = [];
  bool isForecastVisible = false;

  @override
  void initState() {
    super.initState();
    loadVegetablesData();
  }

  // ฟังก์ชันที่ให้ API Base URL แตกต่างกันระหว่าง development และ production
  String getApiBaseUrl() {
    if (kReleaseMode) {
      // ใน production (Render)
      return 'https://bluzora-backend.onrender.com/api/';
    } else {
      // ใน development (localhost)
      return 'http://127.0.0.1:8000/api/';
    }
  }

  Future<void> loadVegetablesData() async {
    final url =
        '${getApiBaseUrl()}crop-info-list/'; // ใช้ String Interpolation ที่นี่
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> resultList = [];
        if (jsonData is List) {
          resultList = List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey("results")) {
          resultList = List<Map<String, dynamic>>.from(jsonData["results"]);
        }
        setState(() => vegetables = resultList);
      } else {
        setState(() => vegetables = []);
      }
    } catch (e) {
      setState(() => vegetables = []);
    }
  }

  Future<Map<String, dynamic>> fetchForecastData(String cropName) async {
    // ใช้ String Interpolation และ getApiBaseUrl() เพื่อสร้าง URL
    final url = '${getApiBaseUrl()}combined-priceforecast/'
        '?vegetableName=$cropName'
        '&startDate=$startDate'
        '&endDate=$endDate';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load forecast data');
    }
    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final results = (json['results'] as List<dynamic>);
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

    final name =
        results.isNotEmpty ? (results.first['crop_name'] as String) : cropName;
    final summary = (json['overall_summary'] as Map<String, dynamic>?) ?? {};

    return {
      'name': name,
      'dailyPrices': dailyPrices,
      'predictedPrices': predictedPrices,
      'summary': summary,
    };
  }

  Future<List<Map<String, dynamic>>> _fetchAllForecastData() async {
    final List<Map<String, dynamic>> list = [];
    for (final veg in selectedVegetables) {
      final data = await fetchForecastData(veg);
      list.add({
        'name': data['name'],
        'dailyPrices': data['dailyPrices'] ?? [],
        'predictedPrices': data['predictedPrices'] ?? [],
        'summary': data['summary'] ?? {},
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;
    final bool isTablet = screenWidth > 600 && screenWidth <= 1024;
    final bool isMobile = screenWidth <= 600;

    final paddingHorizontal = isDesktop ? 70.0 : (isTablet ? 50.0 : 20.0);
    // เปลี่ยนตรงนี้: บนมือถือกำหนด width คงที่ 160 แทน double.infinity
    final cardWidth = isDesktop ? 250.0 : (isTablet ? 200.0 : 160.0);
    final dropdownWidth =
        isDesktop ? 250.0 : (isTablet ? 200.0 : double.infinity);

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
              const Text(
                'เลือกช่วงเวลา',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              if (isMobile) ...[
                SizedBox(width: dropdownWidth, child: _buildStartDatePicker()),
                const SizedBox(height: 16),
                SizedBox(width: dropdownWidth, child: _buildEndDatePicker()),
              ] else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                        width: dropdownWidth, child: _buildStartDatePicker()),
                    SizedBox(
                        width: dropdownWidth, child: _buildEndDatePicker()),
                  ],
                ),

              const SizedBox(height: 16),
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
                    final name = veg['name'] as String? ?? '';
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && !selectedVegetables.contains(value)) {
                      setState(() => selectedVegetables.add(value));
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),
              // แสดงการ์ดผักที่เลือก ด้วย Wrap + fixed cardWidth
              if (selectedVegetables.isNotEmpty)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: selectedVegetables.map((vegName) {
                    final vegetable =
                        vegetables.firstWhere((v) => v['name'] == vegName);
                    final imageUrl = (vegetable['image'] as String)
                        .replaceFirst('http:', 'https:');
                    return SizedBox(
                      width: cardWidth,
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Image.network(
                              imageUrl,
                              height: 120,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
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
                  onPressed: () => setState(() => isForecastVisible = true),
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
              if (isForecastVisible && selectedVegetables.isNotEmpty) ...[
                const Text(
                  'แดชบอร์ดเปรียบเทียบราคาพืช',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedVegetables.length,
                  itemBuilder: (context, idx) {
                    final vegName = selectedVegetables[idx];
                    final veg =
                        vegetables.firstWhere((v) => v['name'] == vegName);
                    final imageUrl = (veg['image'] as String)
                        .replaceFirst('http:', 'https:');
                    return FutureBuilder<Map<String, dynamic>>(
                      future: (startDate == null || endDate == null)
                          ? Future.error("ยังไม่ได้เลือกวันที่")
                          : fetchForecastData(vegName),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snap.hasError) {
                          return Center(child: Text("Error: ${snap.error}"));
                        } else {
                          final data = snap.data!;
                          return VegetableForecastCard(
                            imageUrl: imageUrl,
                            name: veg['name'],
                            price: 'ราคาพยากรณ์: ${veg['price']}',
                            startDate: startDate!,
                            endDate: endDate!,
                            summary: data['summary'] ?? {},
                            graphDailyPrices: data['dailyPrices'] ?? [],
                            graphPredictedPrices: data['predictedPrices'] ?? [],
                          );
                        }
                      },
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),
              const Text(
                'กราฟเปรียบเทียบราคาผัก',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchAllForecastData(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snap.hasError) {
                      return Center(child: Text("Error: ${snap.error}"));
                    } else {
                      final list = snap.data!;
                      return ComparisonGraph(
                        forecastDataList: list,
                        startDate: DateTime.parse(startDate!),
                        endDate: DateTime.parse(endDate!),
                        legendPosition: isMobile
                            ? LegendPosition.bottom
                            : LegendPosition.right,
                        legendOrientation: isMobile
                            ? LegendItemOrientation.horizontal
                            : LegendItemOrientation.vertical,
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

  Widget _buildStartDatePicker() {
    return GestureDetector(
      onTap: () async {
        final initial =
            startDate != null ? DateTime.parse(startDate!) : DateTime.now();
        final last =
            endDate != null ? DateTime.parse(endDate!) : DateTime(2030);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: last,
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
    );
  }

  Widget _buildEndDatePicker() {
    return GestureDetector(
      onTap: () async {
        final initial =
            endDate != null ? DateTime.parse(endDate!) : DateTime.now();
        final today = DateTime.now();
        final maxEnd = today.add(Duration(days: 90));
        final first =
            startDate != null ? DateTime.parse(startDate!) : DateTime(2020);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: first,
          lastDate: maxEnd,
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
    );
  }
}
