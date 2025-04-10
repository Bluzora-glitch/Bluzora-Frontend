import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

// เพิ่มการ import ของไฟล์ component_crop_recommendation.dart
import 'component_crop_recommendation.dart';

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

  // เพิ่ม state สำหรับ overall summary ที่จะได้จาก API
  Map<String, dynamic>? overallSummary;

  @override
  void initState() {
    super.initState();
    loadVegetableData();
  }

  // ดึงข้อมูลผักจาก Django API
  Future<void> loadVegetableData() async {
    final url = 'http://127.0.0.1:8000/api/crops-list/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> resultList = [];
        if (jsonData == null) {
          resultList = [];
        } else if (jsonData is List) {
          resultList = jsonData;
        } else if (jsonData is Map && jsonData.containsKey("results")) {
          resultList = jsonData["results"] ?? [];
        } else {
          resultList = [];
        }
        setState(() {
          vegetableData = resultList;
        });
        print("Vegetable data loaded: $vegetableData");
      } else {
        print('Error loading crops: ${response.statusCode}');
        setState(() {
          vegetableData = [];
        });
      }
    } catch (e) {
      print('Exception loading crops: $e');
      setState(() {
        vegetableData = [];
      });
    }
  }

  // เรียก API เพื่อดึง overall summary จาก combined_price_forecast endpoint
  Future<void> fetchOverallSummary() async {
    if (selectedVegetable == null ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      return;
    }
    final url =
        'http://127.0.0.1:8000/api/combined-priceforecast/?vegetableName=$selectedVegetable&startDate=$selectedStartDate&endDate=$selectedEndDate';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // overall_summary ควรอยู่ใน jsonData['overall_summary']
        setState(() {
          overallSummary = jsonData['overall_summary'];
        });
      } else {
        print('Error fetching overall summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching overall summary: $e');
    }
  }

  // _selectStartDate() และ _selectEndDate() เหมือนเดิม
  Future<void> _selectStartDate() async {
    final DateTime lastDate = selectedEndDate != null
        ? DateTime.parse(selectedEndDate!)
        : DateTime(2030);
    final DateTime initialDate = selectedStartDate != null
        ? DateTime.parse(selectedStartDate!)
        : DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      fetchOverallSummary(); // เรียกทุกครั้งที่เปลี่ยนวันที่เริ่มต้น
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime today = DateTime.now();
    final DateTime maxEndDate = today.add(Duration(days: 90));
    final DateTime firstDate =
        selectedStartDate != null ? DateTime.parse(selectedStartDate!) : today;
    // ใช้ firstDate เป็น initialDate ถ้า selectedEndDate ยังไม่มีค่า
    final DateTime initialDate =
        selectedEndDate != null ? DateTime.parse(selectedEndDate!) : firstDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: maxEndDate,
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // ฟังก์ชันดาวน์โหลด Excel (ใช้ url_launcher) เหมือนเดิม
  void downloadExcel() async {
    if (selectedVegetable == null ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกผักและวันที่ให้ครบถ้วน')),
      );
      return;
    }
    final url =
        'http://127.0.0.1:8000/api/export-excel/?vegetableName=$selectedVegetable&startDate=$selectedStartDate&endDate=$selectedEndDate';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("ไม่สามารถเปิด URL ได้");
    }
  }

  void onForecastPressed() {
    if (selectedVegetable != null &&
        selectedStartDate != null &&
        selectedEndDate != null) {
      setState(() {
        showGraph = true;
        showRecommendations = true;
      });
      fetchOverallSummary(); // เรียกข้อมูลใหม่เมื่อกดพยากรณ์
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกผักและวันที่ให้ครบถ้วน')),
      );
    }
  }

  void onClearPressed() {
    setState(() {
      selectedVegetable = null;
      selectedStartDate = null;
      selectedEndDate = null;
      showGraph = false;
      showRecommendations = false;
      overallSummary = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // หา details ของผักที่เลือกจาก vegetableData
    final selectedCrop = vegetableData.firstWhere(
      (veg) => veg['crop_name'] == selectedVegetable,
      orElse: () => null,
    );

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
                });
                fetchOverallSummary(); // เรียกข้อมูลใหม่เมื่อเปลี่ยนชื่อผัก
              },
              onForecastPressed: onForecastPressed,
              onClearPressed: onClearPressed,
              onStartDateTap: _selectStartDate,
              onEndDateTap: _selectEndDate,
            ),
            if (showGraph)
              GraphPlaceholder(
                key: ValueKey(
                    'graph-${selectedVegetable}-${selectedStartDate}-${selectedEndDate}'),
                vegetableName: selectedVegetable ?? '',
                startDate: selectedStartDate ?? '',
                endDate: selectedEndDate ?? '',
              ),
            if (showRecommendations &&
                overallSummary != null &&
                selectedCrop != null)
              CropRecommendationWidget(
                key: ValueKey(
                    'recommend-${selectedVegetable}-${selectedStartDate}-${selectedEndDate}'),
                cropName: selectedCrop['crop_name'],
                unit: selectedCrop['unit'],
                minGrowthDuration: selectedCrop['min_growth_duration'] ?? 0,
                maxGrowthDuration: selectedCrop['max_growth_duration'] ?? 0,
                idealSoil: selectedCrop['ideal_soil'] ?? '',
                optimalSeason: selectedCrop['optimal_season'] ?? '',
                cultivationMethod: selectedCrop['cultivation_method'] ?? '',
                careTips: selectedCrop['care_tips'] ?? '',
                forecastDuration:
                    _calculateDuration(selectedStartDate!, selectedEndDate!),
                startDate: selectedStartDate!,
                endDate: selectedEndDate!,
                overallAverage: overallSummary?['overall_average'] ?? 0.0,
                overallMin: overallSummary?['overall_min'] ?? 0.0,
                overallMax: overallSummary?['overall_max'] ?? 0.0,
                volatilityPercent: overallSummary?['volatility_percent'] ?? 0.0,
                priceChangePercent:
                    overallSummary?['price_change_percent'] ?? 0.0,
                onDownloadPressed: downloadExcel,
                onClearPressed: onClearPressed,
              ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันช่วยคำนวณจำนวนวันในช่วง
  int _calculateDuration(String start, String end) {
    final DateTime startD = DateTime.parse(start);
    final DateTime endD = DateTime.parse(end);
    return endD.difference(startD).inDays;
  }
}

// ---------------------------
// ด้านล่างเป็นคลาส ForecastSection และ GraphPlaceholder เหมือนเดิม
// ---------------------------

class ForecastSection extends StatelessWidget {
  final List<dynamic> vegetableData;
  final String? selectedVegetable;
  final String? selectedStartDate;
  final String? selectedEndDate;
  final Function(String?) onVegetableChanged;
  final VoidCallback onForecastPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  const ForecastSection({
    required this.vegetableData,
    required this.selectedVegetable,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onVegetableChanged,
    required this.onForecastPressed,
    required this.onClearPressed,
    required this.onStartDateTap,
    required this.onEndDateTap,
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
                value: veg['crop_name'],
                child: Text(veg['crop_name']),
              );
            }).toList(),
            onChanged: onVegetableChanged,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onStartDateTap,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'วันที่เริ่มต้นการพยากรณ์',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedStartDate != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(selectedStartDate!))
                            : '',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onEndDateTap,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'วันที่สิ้นสุดการพยากรณ์',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedEndDate != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(selectedEndDate!))
                            : '',
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

class GraphPlaceholder extends StatefulWidget {
  final String vegetableName;
  final String startDate;
  final String endDate;

  const GraphPlaceholder({
    Key? key,
    required this.vegetableName,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _GraphPlaceholderState createState() => _GraphPlaceholderState();
}

class _GraphPlaceholderState extends State<GraphPlaceholder> {
  List<ChartData> historicalData = [];
  List<ChartData> predictedData = [];
  String message = "Loading...";
  bool isLoading = true;
  bool isGraphData = false;
  TooltipBehavior? _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        ChartData chartData = data;
        String tooltipText = "";
        if (series.name == "ราคาจริง") {
          tooltipText =
              "ราคาจริง\nวันที่: ${DateFormat('d MMM yyyy').format(chartData.date)}\nราคาเฉลี่ย: ${chartData.avgPrice}\nช่วงราคา: ${chartData.minPrice} - ${chartData.maxPrice}";
        } else if (series.name == "ราคาพยากรณ์") {
          tooltipText =
              "ราคาพยากรณ์\nวันที่: ${DateFormat('d MMM yyyy').format(chartData.date)}\nราคา: ${chartData.predictedPrice}";
        }
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tooltipText,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    fetchData();
  }

  Future<void> fetchData() async {
    final url =
        'http://127.0.0.1:8000/api/combined-priceforecast/?vegetableName=${widget.vegetableName}&startDate=${widget.startDate}&endDate=${widget.endDate}';
    try {
      final response = await http.get(Uri.parse(url));
      print('URL: $url');
      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('results')) {
          final List results = jsonData['results'];
          // เพิ่มเงื่อนไขตรวจสอบกรณี results ว่าง
          if (results.isEmpty) {
            setState(() {
              message = "ไม่พบข้อมูลในช่วงเวลานี้";
              isGraphData = false;
              isLoading = false;
            });
          } else {
            final List historicalResults =
                results.where((item) => item['type'] == 'historical').toList();
            final List predictedResults =
                results.where((item) => item['type'] == 'predicted').toList();

            historicalResults.sort((a, b) =>
                DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
            predictedResults.sort((a, b) =>
                DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

            setState(() {
              historicalData = historicalResults.map((item) {
                final dt = DateTime.parse(item['date']);
                return ChartData(
                  date: dt,
                  minPrice: (item['min_price'] as num).toDouble(),
                  maxPrice: (item['max_price'] as num).toDouble(),
                  avgPrice: (item['price'] as num).toDouble(),
                );
              }).toList();
              predictedData = predictedResults.map((item) {
                final dt = DateTime.parse(item['date']);
                return ChartData(
                  date: dt,
                  predictedPrice: (item['price'] as num).toDouble(),
                );
              }).toList();
              isGraphData = true;
              isLoading = false;
            });
          }
        } else if (jsonData.containsKey('message')) {
          setState(() {
            message = jsonData['message'];
            isGraphData = false;
            isLoading = false;
          });
        } else {
          setState(() {
            message = "Unexpected response format";
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
            ? const Center(child: CircularProgressIndicator())
            : isGraphData
                ? SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat('d MMM'),
                    ),
                    title: ChartTitle(
                        text: 'กราฟพยากรณ์ราคา (${widget.vegetableName})'),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: _tooltipBehavior,
                    series: <CartesianSeries>[
                      RangeAreaSeries<ChartData, DateTime>(
                        dataSource: historicalData,
                        xValueMapper: (ChartData data, _) => data.date,
                        lowValueMapper: (ChartData data, _) => data.minPrice,
                        highValueMapper: (ChartData data, _) => data.maxPrice,
                        name: 'historical range',
                        color: Colors.blue.withOpacity(0.2),
                        enableTooltip: false,
                      ),
                      LineSeries<ChartData, DateTime>(
                        dataSource: historicalData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.avgPrice,
                        name: 'ราคาจริง',
                        color: const Color.fromARGB(255, 141, 198, 245),
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        markerSettings: MarkerSettings(
                            isVisible: true, width: 8, height: 8),
                      ),
                      LineSeries<ChartData, DateTime>(
                        dataSource: predictedData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) =>
                            data.predictedPrice,
                        name: 'ราคาพยากรณ์',
                        color: Colors.red,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        markerSettings: MarkerSettings(
                            isVisible: true, width: 8, height: 8),
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
  final DateTime date;
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;
  final double? predictedPrice;

  ChartData({
    required this.date,
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
    this.predictedPrice,
  });
}
