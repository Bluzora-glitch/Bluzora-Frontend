import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

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

  // เลือกวันที่เริ่มต้นผ่าน DatePicker
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate != null
          ? DateTime.parse(selectedStartDate!)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // เลือกวันที่สิ้นสุดผ่าน DatePicker
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate != null
          ? DateTime.parse(selectedEndDate!)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = DateFormat('yyyy-MM-dd').format(picked);
      });
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
                });
              },
              onForecastPressed: onForecastPressed,
              onClearPressed: onClearPressed,
              onStartDateTap: _selectStartDate,
              onEndDateTap: _selectEndDate,
            ),
            if (showGraph)
              // ใช้ ValueKey เพื่อให้ GraphPlaceholder ถูก rebuild ทุกครั้งที่ค่าพารามิเตอร์เปลี่ยน
              GraphPlaceholder(
                key: ValueKey(
                    '$selectedVegetable-$selectedStartDate-$selectedEndDate'),
                vegetableName: selectedVegetable ?? '',
                startDate: selectedStartDate ?? '',
                endDate: selectedEndDate ?? '',
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
          // Dropdown สำหรับเลือกผัก
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
          // Row สำหรับเลือกวันที่ผ่าน DatePicker
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
          // ปุ่มพยากรณ์และล้างข้อมูล
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
    // กำหนด tooltip behavior ด้วย custom builder สำหรับ LineSeries เท่านั้น
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tooltipText,
            style: TextStyle(color: Colors.white),
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
          // แยกข้อมูล historical กับ predicted
          final List historicalResults =
              results.where((item) => item['type'] == 'historical').toList();
          final List predictedResults =
              results.where((item) => item['type'] == 'predicted').toList();

          // Sort โดยใช้ DateTime.parse เพื่อเรียงลำดับ
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
            ? Center(child: CircularProgressIndicator())
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
                      // RangeAreaSeries สำหรับ historical range (min - max) แบบ background
                      RangeAreaSeries<ChartData, DateTime>(
                        dataSource: historicalData,
                        xValueMapper: (ChartData data, _) => data.date,
                        lowValueMapper: (ChartData data, _) => data.minPrice,
                        highValueMapper: (ChartData data, _) => data.maxPrice,
                        name: 'ราคาจริง', // ชื่อ series เดิม
                        color: Colors.blue.withOpacity(0.2),
                        //borderColor: Colors.blue,
                        //borderWidth: 2,
                        enableTooltip: false, // ปิด tooltip ใน range area
                      ),
                      // LineSeries สำหรับ historical average (ราคาจริง)
                      LineSeries<ChartData, DateTime>(
                        dataSource: historicalData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.avgPrice,
                        name: 'ราคาจริง',
                        color: Colors.blue,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        markerSettings: MarkerSettings(
                            isVisible: true, width: 8, height: 8),
                        pointColorMapper: (ChartData data, _) {
                          final now = DateTime.now();
                          if (data.date.year == now.year &&
                              data.date.month == now.month &&
                              data.date.day == now.day) {
                            return Colors.green.shade700;
                          } else {
                            return Colors.blue;
                          }
                        },
                      ),
                      // LineSeries สำหรับ predicted price (ราคาพยากรณ์)
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
                        pointColorMapper: (ChartData data, _) {
                          final now = DateTime.now();
                          if (data.date.year == now.year &&
                              data.date.month == now.month &&
                              data.date.day == now.day) {
                            return Colors.green.shade700;
                          } else {
                            return Colors.red;
                          }
                        },
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

class RecommendationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double marginSize;
        double paddingSize;
        double fontSizeTitle;
        double fontSizeContent;
        double buttonSpacing;

        if (screenWidth > 1024) {
          marginSize = 70.0;
          paddingSize = 50.0;
          fontSizeTitle = 24;
          fontSizeContent = 18;
          buttonSpacing = 16;
        } else if (screenWidth > 600) {
          marginSize = 40.0;
          paddingSize = 30.0;
          fontSizeTitle = 22;
          fontSizeContent = 16;
          buttonSpacing = 12;
        } else {
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
