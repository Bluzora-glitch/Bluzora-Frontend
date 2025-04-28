import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
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
  Map<String, dynamic>? overallSummary;

  @override
  void initState() {
    super.initState();
    loadVegetableData();
  }

  // ฟังก์ชันเพื่อให้ API Base URL แตกต่างกันระหว่าง development และ production
  String getApiBaseUrl() {
    if (kReleaseMode) {
      // ใน production (Render)
      return 'https://bluzora-backend.onrender.com/api/';
    } else {
      // ใน development (localhost)
      return 'http://127.0.0.1:8000/api/';
    }
  }

  Future<void> loadVegetableData() async {
    final url =
        '${getApiBaseUrl()}crops-list/'; // ใช้ String Interpolation ที่นี่
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> resultList;
        if (jsonData is List) {
          resultList = jsonData;
        } else if (jsonData is Map && jsonData.containsKey("results")) {
          resultList = jsonData["results"] ?? [];
        } else {
          resultList = [];
        }
        setState(() => vegetableData = resultList);
      } else {
        setState(() => vegetableData = []);
      }
    } catch (e) {
      setState(() => vegetableData = []);
    }
  }

  Future<void> fetchOverallSummary() async {
    if (selectedVegetable == null ||
        selectedStartDate == null ||
        selectedEndDate == null) return;

    // ใช้ String Interpolation และ getApiBaseUrl() เพื่อสร้าง URL
    final url = '${getApiBaseUrl()}combined-priceforecast/'
        '?vegetableName=$selectedVegetable'
        '&startDate=$selectedStartDate'
        '&endDate=$selectedEndDate';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() => overallSummary = jsonData['overall_summary']);
      }
    } catch (_) {}
  }

  Future<void> _selectStartDate() async {
    final DateTime lastDate = selectedEndDate != null
        ? DateTime.parse(selectedEndDate!)
        : DateTime(2030);
    final DateTime initialDate = selectedStartDate != null
        ? DateTime.parse(selectedStartDate!)
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(
          () => selectedStartDate = DateFormat('yyyy-MM-dd').format(picked));
      fetchOverallSummary();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime today = DateTime.now();
    final DateTime maxEndDate = today.add(Duration(days: 90));
    final DateTime firstDate =
        selectedStartDate != null ? DateTime.parse(selectedStartDate!) : today;
    final DateTime initialDate =
        selectedEndDate != null ? DateTime.parse(selectedEndDate!) : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: maxEndDate,
    );
    if (picked != null) {
      setState(() => selectedEndDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void downloadExcel() async {
    if (selectedVegetable == null ||
        selectedStartDate == null ||
        selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกผักและวันที่ให้ครบถ้วน')),
      );
      return;
    }

    // ใช้ String Interpolation และ getApiBaseUrl() เพื่อสร้าง URL
    final url = '${getApiBaseUrl()}export-excel/'
        '?vegetableName=$selectedVegetable'
        '&startDate=$selectedStartDate'
        '&endDate=$selectedEndDate';

    if (await canLaunch(url)) {
      await launch(url);
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
      fetchOverallSummary();
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

  int _calculateDuration(String start, String end) {
    final startD = DateTime.parse(start);
    final endD = DateTime.parse(end);
    return endD.difference(startD).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1024;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isMobile = width < 600;

    // Horizontal padding for ForecastSection
    final double sectionHPadding = isDesktop
        ? 150
        : isTablet
            ? 80
            : 16;

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
              onVegetableChanged: (v) {
                setState(() => selectedVegetable = v);
                fetchOverallSummary();
              },
              onForecastPressed: onForecastPressed,
              onClearPressed: onClearPressed,
              onStartDateTap: _selectStartDate,
              onEndDateTap: _selectEndDate,
            ),
            // GraphPlaceholder with legend repositioned on mobile
            if (showGraph)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GraphPlaceholder(
                  key: ValueKey(
                      'graph-$selectedVegetable-$selectedStartDate-$selectedEndDate'),
                  vegetableName: selectedVegetable ?? '',
                  startDate: selectedStartDate ?? '',
                  endDate: selectedEndDate ?? '',
                  legendPosition:
                      isMobile ? LegendPosition.bottom : LegendPosition.right,
                  legendOrientation: isMobile
                      ? LegendItemOrientation.horizontal
                      : LegendItemOrientation.vertical,
                ),
              ),

            // Recommendations (no layout change)
            if (showRecommendations &&
                overallSummary != null &&
                selectedCrop != null)
              CropRecommendationWidget(
                key: ValueKey(
                    'recommend-$selectedVegetable-$selectedStartDate-$selectedEndDate'),
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
                overallAverage: overallSummary!['overall_average'] ?? 0.0,
                overallMin: overallSummary!['overall_min'] ?? 0.0,
                overallMax: overallSummary!['overall_max'] ?? 0.0,
                volatilityPercent: overallSummary!['volatility_percent'] ?? 0.0,
                priceChangePercent:
                    overallSummary!['price_change_percent'] ?? 0.0,
                onDownloadPressed: downloadExcel,
                onClearPressed: onClearPressed,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// ForecastSection with responsive padding
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
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1024;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isMobile = width < 600;

    final double hPadding = isDesktop
        ? 150
        : isTablet
            ? 80
            : 16;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 50),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'พยากรณ์ราคาผัก',
            style: TextStyle(
              fontSize: isDesktop
                  ? 24
                  : isTablet
                      ? 22
                      : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: onForecastPressed, child: Text('พยากรณ์')),
              const SizedBox(width: 8),
              OutlinedButton(
                  onPressed: onClearPressed, child: Text('ล้างข้อมูล')),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// GraphPlaceholder with responsive legend
// ---------------------------
class GraphPlaceholder extends StatefulWidget {
  final String vegetableName;
  final String startDate;
  final String endDate;
  final LegendPosition legendPosition;
  final LegendItemOrientation legendOrientation;

  const GraphPlaceholder({
    Key? key,
    required this.vegetableName,
    required this.startDate,
    required this.endDate,
    this.legendPosition = LegendPosition.right,
    this.legendOrientation = LegendItemOrientation.vertical,
  }) : super(key: key);

  @override
  _GraphPlaceholderState createState() => _GraphPlaceholderState();
}

// เพิ่มฟังก์ชัน getApiBaseUrl() ตรงนี้
String getApiBaseUrl() {
  if (kReleaseMode) {
    return 'https://bluzora-backend.onrender.com/api/';
  } else {
    return 'http://127.0.0.1:8000/api/';
  }
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
      builder: (dynamic data, dynamic point, dynamic series, int pi, int si) {
        final ChartData d = data as ChartData;

        // ถ้า type จาก API เป็น predicted
        if (d.type == 'predicted') {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "วันที่: ${DateFormat('d MMM yyyy').format(d.date)}\n"
              "ราคาพยากรณ์: ฿${d.predictedPrice?.toStringAsFixed(0) ?? '-'}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }

        // มิฉะนั้นถือเป็น historical
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "วันที่: ${DateFormat('d MMM yyyy').format(d.date)}\n"
            "ราคาเฉลี่ย: ฿${d.avgPrice?.toStringAsFixed(0) ?? '-'}\n"
            "ช่วงราคา: ฿${d.minPrice?.toStringAsFixed(0) ?? '-'} - ฿${d.maxPrice?.toStringAsFixed(0) ?? '-'}",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      },
    );

    fetchData();
  }

  Future<void> fetchData() async {
    final url = '${getApiBaseUrl()}combined-priceforecast/'
        '?vegetableName=${widget.vegetableName}'
        '&startDate=${widget.startDate}'
        '&endDate=${widget.endDate}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('results')) {
          final List results = jsonData['results'];
          if (results.isEmpty) {
            setState(() {
              message = "ไม่พบข้อมูลในช่วงเวลานี้";
              isGraphData = false;
              isLoading = false;
            });
          } else {
            final hist =
                results.where((r) => r['type'] == "historical").toList();
            final pred =
                results.where((r) => r['type'] == "predicted").toList();
            hist.sort((a, b) =>
                DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
            pred.sort((a, b) =>
                DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
            setState(() {
              // สำหรับ historical
              historicalData = hist
                  .map((item) => ChartData(
                        date: DateTime.parse(item['date']),
                        minPrice: (item['min_price'] as num).toDouble(),
                        maxPrice: (item['max_price'] as num).toDouble(),
                        avgPrice: (item['price'] as num).toDouble(),
                        type: item['type'], // เก็บ type จาก API
                      ))
                  .toList();

              // สำหรับ predicted
              predictedData = pred
                  .map((item) => ChartData(
                        date: DateTime.parse(item['date']),
                        predictedPrice: (item['price'] as num).toDouble(),
                        type: item['type'], // เก็บ type จาก API
                      ))
                  .toList();

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
    return Container(
      height: 300,
      width: double.infinity,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isGraphData
              ? SfCartesianChart(
                  primaryXAxis: DateTimeAxis(dateFormat: DateFormat('d MMM')),
                  title: ChartTitle(
                      text: 'กราฟพยากรณ์ราคา (${widget.vegetableName})'),
                  legend: Legend(
                    isVisible: true,
                    position: widget.legendPosition,
                    orientation: widget.legendOrientation,
                  ),
                  tooltipBehavior: _tooltipBehavior,
                  series: <CartesianSeries>[
                    RangeAreaSeries<ChartData, DateTime>(
                      dataSource: historicalData,
                      xValueMapper: (d, _) => d.date,
                      lowValueMapper: (d, _) => d.minPrice,
                      highValueMapper: (d, _) => d.maxPrice,
                      name: 'historical range',
                      color: Colors.blue.withOpacity(0.2),
                      enableTooltip: false,
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: historicalData,
                      xValueMapper: (d, _) => d.date,
                      yValueMapper: (d, _) => d.avgPrice,
                      name: 'ราคาจริง',
                      color: const Color.fromARGB(255, 141, 198, 245),
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                      markerSettings:
                          MarkerSettings(isVisible: true, width: 8, height: 8),
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: predictedData,
                      xValueMapper: (d, _) => d.date,
                      yValueMapper: (d, _) => d.predictedPrice,
                      name: 'ราคาพยากรณ์',
                      color: Colors.red,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                      markerSettings:
                          MarkerSettings(isVisible: true, width: 8, height: 8),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    textAlign: TextAlign.center,
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
  final String type;

  ChartData({
    required this.date,
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
    this.predictedPrice,
    required this.type,
  });
}
