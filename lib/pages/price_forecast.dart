import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

Future<void> fetchData() async {
  final url =
      'http://127.0.0.1:5000/api/priceforecast?vegetableName=ผักชีไทย&startDate=2025-01-20&endDate=2025-01-24';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response Data: $data');
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

class PriceForecastPage extends StatefulWidget {
  const PriceForecastPage({Key? key}) : super(key: key);

  @override
  _PriceForecastPageState createState() => _PriceForecastPageState();
}

class _PriceForecastPageState extends State<PriceForecastPage> {
  List<dynamic> vegetableData = [];
  String? selectedVegetable;
  String? selectedStartDate;
  String? selectedEndDate;
  bool showGraph = false;
  bool showRecommendations = false;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/vegetables.json');
    final data = jsonDecode(jsonString);
    setState(() {
      vegetableData = data;
    });
  }

  void onForecastPressed() {
    setState(() {
      showGraph = true;
      showRecommendations = true;
    });
  }

  void onClearPressed() {
    setState(() {
      selectedVegetable = null;
      selectedStartDate = null;
      selectedEndDate = null;
      showGraph = false;
      showRecommendations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForecastSection(
              vegetableData: vegetableData,
              selectedVegetable: selectedVegetable,
              selectedStartDate: selectedStartDate,
              selectedEndDate: selectedEndDate,
              onVegetableChanged: (value) {
                setState(() {
                  selectedVegetable = value;
                  final selected =
                      vegetableData.firstWhere((veg) => veg['name'] == value);
                  selectedStartDate = selected['dailyPrices'].first['date'];
                  selectedEndDate = selected['dailyPrices'].last['date'];
                });
              },
              onForecastPressed: onForecastPressed,
              onClearPressed: onClearPressed,
            ),
            if (showGraph)
              GraphPlaceholder(
                vegetableName: selectedVegetable!,
                startDate: selectedStartDate!,
                endDate: selectedEndDate!,
              ),
            if (showRecommendations) RecommendationsSection(),
          ],
        ),
      ),
    );
  }
}

class ForecastSection extends StatelessWidget {
  final List<dynamic> vegetableData;
  final String? selectedVegetable;
  final String? selectedStartDate;
  final String? selectedEndDate;
  final Function(String?) onVegetableChanged;
  final VoidCallback onForecastPressed;
  final VoidCallback onClearPressed;

  const ForecastSection({
    required this.vegetableData,
    required this.selectedVegetable,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onVegetableChanged,
    required this.onForecastPressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 50.0),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'พยากรณ์ราคาผัก',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'เลือกผักที่ต้องการพยากรณ์',
              border: OutlineInputBorder(),
            ),
            value: selectedVegetable,
            items: vegetableData.map((veg) {
              return DropdownMenuItem<String>(
                value: veg['name'],
                child: Text(veg['name']),
              );
            }).toList(),
            onChanged: onVegetableChanged,
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // ระยะห่าง Row ซ้าย-ขวา
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'วันที่เริ่มต้นการพยากรณ์',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    value: selectedStartDate,
                    items: selectedVegetable != null
                        ? vegetableData
                            .firstWhere((veg) =>
                                veg['name'] == selectedVegetable)['dailyPrices']
                            .map<DropdownMenuItem<String>>((entry) {
                            return DropdownMenuItem<String>(
                              value: entry['date'],
                              child: Text(DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(entry['date']))),
                            );
                          }).toList()
                        : [],
                    onChanged: (value) {}, // Read-only
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'วันที่สิ้นสุดการพยากรณ์',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    value: selectedEndDate,
                    items: selectedVegetable != null
                        ? vegetableData
                            .firstWhere((veg) =>
                                veg['name'] == selectedVegetable)['dailyPrices']
                            .map<DropdownMenuItem<String>>((entry) {
                            return DropdownMenuItem<String>(
                              value: entry['date'],
                              child: Text(DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(entry['date']))),
                            );
                          }).toList()
                        : [],
                    onChanged: (value) {}, // Read-only
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onForecastPressed,
                child: Text('พยากรณ์'),
              ),
              SizedBox(width: 8),
              OutlinedButton(
                onPressed: onClearPressed,
                child: Text('ล้างข้อมูล'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// คลาสกราฟ อันนี้แหละที่เรียกจาก python
class GraphPlaceholder extends StatefulWidget {
  final String vegetableName;
  final String startDate;
  final String endDate;

  GraphPlaceholder({
    required this.vegetableName,
    required this.startDate,
    required this.endDate,
  });

  @override
  _GraphPlaceholderState createState() => _GraphPlaceholderState();
}

class _GraphPlaceholderState extends State<GraphPlaceholder> {
  List<ChartData> dataPoints = [];
  List<ChartData> trendPoints = [];
  String message = "Loading...";
  bool isLoading = true;
  bool isGraphData = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url =
        'http://127.0.0.1:5000/api/priceforecast?vegetableName=${widget.vegetableName}&startDate=${widget.startDate}&endDate=${widget.endDate}';

    try {
      final response = await http.get(Uri.parse(url));
      print('URL: $url'); // ตรวจสอบ URL
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ตรวจสอบว่า API ส่งกลับมาเป็นกราฟหรือข้อความธรรมดา
        if (data.containsKey('message')) {
          setState(() {
            message = data['message'];
            isGraphData = false;
            isLoading = false;
          });
        } else {
          List<dynamic> dates = data['dates'];
          List<dynamic> prices = data['prices'];
          List<dynamic> trend = data['trend'];

          setState(() {
            dataPoints = List.generate(dates.length, (index) {
              return ChartData(dates[index], prices[index]);
            });
            trendPoints = List.generate(dates.length, (index) {
              return ChartData(dates[index], trend[index]);
            });
            isGraphData = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          message = "Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Exception: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 300,
        width: double.infinity,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : isGraphData
                ? SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(
                        text: 'กราฟพยากรณ์ราคา (${widget.vegetableName})'),
                    legend: Legend(isVisible: true), // แสดง Legend
                    tooltipBehavior:
                        TooltipBehavior(enable: true), // แสดง Tooltip
                    series: <ChartSeries>[
                      LineSeries<ChartData, String>(
                        dataSource: dataPoints,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.price,
                        name: 'ราคาจริง',
                        color: Colors.blue,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                      LineSeries<ChartData, String>(
                        dataSource: trendPoints,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.price,
                        name: 'แนวโน้มราคา',
                        color: Colors.red,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
      ),
    );
  }
}

class ChartData {
  final String date;
  final double price;

  ChartData(this.date, this.price);
}

class RecommendationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ตรวจสอบความกว้างของหน้าจอ
        double screenWidth = constraints.maxWidth;
        double marginSize;
        double paddingSize;
        double fontSizeTitle;
        double fontSizeContent;
        double buttonSpacing;

        // ปรับขนาดตามความกว้างของหน้าจอ
        if (screenWidth > 1024) {
          // เดสก์ท็อป
          marginSize = 70.0;
          paddingSize = 50.0;
          fontSizeTitle = 24;
          fontSizeContent = 18;
          buttonSpacing = 16;
        } else if (screenWidth > 600) {
          // แท็บเล็ต
          marginSize = 40.0;
          paddingSize = 30.0;
          fontSizeTitle = 22;
          fontSizeContent = 16;
          buttonSpacing = 12;
        } else {
          // มือถือ
          marginSize = 20.0;
          paddingSize = 20.0;
          fontSizeTitle = 20;
          fontSizeContent = 14;
          buttonSpacing = 8;
        }

        return Container(
          margin: EdgeInsets.all(marginSize),
          padding: EdgeInsets.all(paddingSize),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'คำแนะนำ: กุญแจสู่ความสำเร็จในตลาดเกษตร',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '- เรียนรู้เทคนิคและวิเคราะห์พยากรณ์ราคาอย่างมีประสิทธิภาพ\n'
                '- ใช้ข้อมูลในการตัดสินใจซื้อขายอย่างถูกต้อง\n'
                '- วางแผนการผลิตให้เหมาะสมกับตลาด',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSizeContent),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Logic ดาวน์โหลดการพยากรณ์
                    },
                    child: Text('ดาวน์โหลดการพยากรณ์'),
                  ),
                  SizedBox(width: buttonSpacing),
                  OutlinedButton(
                    onPressed: () {
                      // Logic ล้างข้อมูลทั้งหมด
                    },
                    child: Text('ล้างข้อมูลทั้งหมด'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
