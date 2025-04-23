import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quarterly_graph.dart';
import 'component_comparison.dart';
import 'component_price_forecast.dart';
import 'yearly_comparison_graph.dart';
import 'package:url_launcher/url_launcher.dart';

class QuarterlyAvgPage extends StatefulWidget {
  final Map<String, dynamic> vegetable;
  final bool showAppBar;

  const QuarterlyAvgPage({
    Key? key,
    required this.vegetable,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  _QuarterlyAvgPageState createState() => _QuarterlyAvgPageState();
}

class _QuarterlyAvgPageState extends State<QuarterlyAvgPage> {
  late String startDate;
  late String endDate;
  Map<String, dynamic>? fetchedData;
  bool isLoading = false;
  bool showYearlyComparison = false;
  List<Map<String, dynamic>>? yearlyData;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultStart = now.subtract(const Duration(days: 30));
    startDate = DateFormat('yyyy-MM-dd').format(defaultStart);
    endDate = DateFormat('yyyy-MM-dd').format(now);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final cropName = widget.vegetable['name'];
    final url =
        'http://127.0.0.1:8000/api/quarterly-avg/?crop_name=$cropName&startDate=$startDate&endDate=$endDate';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          fetchedData = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
    setState(() => isLoading = false);
  }

  void _updateDateRange(String newStart, String newEnd) {
    setState(() {
      startDate = newStart;
      endDate = newEnd;
      showYearlyComparison = false;
    });
    _fetchData();
  }

  Future<void> _downloadExcel() async {
    final cropName = widget.vegetable['name'];
    final url =
        'http://127.0.0.1:8000/api/export-excel/?vegetableName=$cropName&startDate=$startDate&endDate=$endDate';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  Future<void> _fetchYearlyComparisonData() async {
    if (startDate.isEmpty || endDate.isEmpty) return;
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final currentYear = start.year;
    List<Map<String, dynamic>> tempResults = [];

    Future<Map<String, dynamic>> _fetchOneYear(int yearDiff) async {
      final newStart = DateTime(currentYear - yearDiff, start.month, start.day);
      final newEnd = DateTime(currentYear - yearDiff, end.month, end.day);
      final cropName = widget.vegetable['name'];
      final url = 'http://127.0.0.1:8000/api/quarterly-avg/?crop_name=$cropName'
          '&startDate=${newStart.toString().split(" ")[0]}'
          '&endDate=${newEnd.toString().split(" ")[0]}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data['year'] = newStart.year;
        return data;
      } else {
        return {};
      }
    }

    setState(() => isLoading = true);
    for (int i = 0; i <= 3; i++) {
      final oneYearData = await _fetchOneYear(i);
      if (oneYearData.isNotEmpty) tempResults.add(oneYearData);
    }
    setState(() {
      yearlyData = tempResults;
      showYearlyComparison = true;
      isLoading = false;
    });
  }

  void _onYearlyComparisonPressed() {
    _fetchYearlyComparisonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(widget.vegetable['name']))
          : null,
      backgroundColor: const Color(0xFFEBEDF0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // *** Responsive Section ***
              LayoutBuilder(builder: (context, constraints) {
                // ถ้าความกว้าง < 800: Column, else: Row
                if (constraints.maxWidth < 800) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VegetableSelection(
                        vegetable: widget.vegetable,
                        onDateRangeSelected: (s, e) => _updateDateRange(s, e),
                        onDownloadExcel: _downloadExcel,
                        onYearlyComparisonPressed: _onYearlyComparisonPressed,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: fetchedData == null
                            ? Center(
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        "กรุณาเลือกวันที่เพื่อดูกราฟ",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                              )
                            : (fetchedData!['dailyPrices'] == null ||
                                    (fetchedData!['dailyPrices'] as List)
                                        .isEmpty)
                                ? const Center(
                                    child: Text(
                                      "ไม่พบข้อมูลในช่วงเวลานี้",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : QuarterlyGraph(
                                    startDate: DateFormat('yyyy-MM-dd')
                                        .parse(startDate),
                                    endDate:
                                        DateFormat('yyyy-MM-dd').parse(endDate),
                                    dailyPrices: fetchedData!['dailyPrices'],
                                  ),
                      ),
                      const SizedBox(height: 16),
                      fetchedData == null
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        "กรุณาเลือกวันที่เพื่อดูตาราง",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                              ),
                            )
                          : Container(
                              height: 500,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                child: PriceTableNew(
                                  dailyPrices: fetchedData!['dailyPrices'],
                                  summary: fetchedData!['summary'],
                                  unit: widget.vegetable['unit'],
                                  imageUrl: widget.vegetable['image'],
                                  name: widget.vegetable['name'],
                                ),
                              ),
                            ),
                    ],
                  );
                } else {
                  // desktop / tablet
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              VegetableSelection(
                                vegetable: widget.vegetable,
                                onDateRangeSelected: (s, e) =>
                                    _updateDateRange(s, e),
                                onDownloadExcel: _downloadExcel,
                                onYearlyComparisonPressed:
                                    _onYearlyComparisonPressed,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: fetchedData == null
                                    ? Center(
                                        child: isLoading
                                            ? const CircularProgressIndicator()
                                            : const Text(
                                                "กรุณาเลือกวันที่เพื่อดูกราฟ",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                      )
                                    : (fetchedData!['dailyPrices'] == null ||
                                            (fetchedData!['dailyPrices']
                                                    as List)
                                                .isEmpty)
                                        ? const Center(
                                            child: Text(
                                              "ไม่พบข้อมูลในช่วงเวลานี้",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          )
                                        : QuarterlyGraph(
                                            startDate: DateFormat('yyyy-MM-dd')
                                                .parse(startDate),
                                            endDate: DateFormat('yyyy-MM-dd')
                                                .parse(endDate),
                                            dailyPrices:
                                                fetchedData!['dailyPrices'],
                                          ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: fetchedData == null
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const CircularProgressIndicator()
                                        : const Text(
                                            "กรุณาเลือกวันที่เพื่อดูตาราง",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                  ),
                                )
                              : Container(
                                  height: 500,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SingleChildScrollView(
                                    child: PriceTableNew(
                                      dailyPrices: fetchedData!['dailyPrices'],
                                      summary: fetchedData!['summary'],
                                      unit: widget.vegetable['unit'],
                                      imageUrl: widget.vegetable['image'],
                                      name: widget.vegetable['name'],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                }
              }),
              const SizedBox(height: 32),
              if (showYearlyComparison)
                YearlyComparisonGraph(
                  mainStartDate: startDate,
                  mainEndDate: endDate,
                  yearlyData: yearlyData ?? [],
                ),
              const SizedBox(height: 32),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/comparison');
                  },
                  splashColor: Colors.green.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 1024
                          ? 150.0
                          : MediaQuery.of(context).size.width > 600
                              ? 80.0
                              : 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'การเปรียบเทียบ'),
                        const ComparisonComponent(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/price_forecast');
                  },
                  splashColor: Colors.green.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 1024
                          ? 150.0
                          : MediaQuery.of(context).size.width > 600
                              ? 80.0
                              : 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'พยากรณ์ราคาผัก'),
                        const PriceForecastComponent(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// VegetableSelection: widget ย่อย ปรับขนาดรูป + Wrap ปุ่มอัตโนมัติ
/// --------------------------------------------------------------------------
class VegetableSelection extends StatefulWidget {
  final Map<String, dynamic> vegetable;
  final Function(String startDate, String endDate) onDateRangeSelected;
  final VoidCallback onDownloadExcel;
  final VoidCallback onYearlyComparisonPressed;

  const VegetableSelection({
    Key? key,
    required this.vegetable,
    required this.onDateRangeSelected,
    required this.onDownloadExcel,
    required this.onYearlyComparisonPressed,
  }) : super(key: key);

  @override
  _VegetableSelectionState createState() => _VegetableSelectionState();
}

class _VegetableSelectionState extends State<VegetableSelection> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> _pickStartDate() async {
    final firstDate = DateTime(2000);
    final lastDate = selectedEndDate ?? DateTime.now();
    final initialDate =
        selectedStartDate ?? lastDate.subtract(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked;
      });
      if (selectedEndDate != null) {
        widget.onDateRangeSelected(
          DateFormat('yyyy-MM-dd').format(selectedStartDate!),
          DateFormat('yyyy-MM-dd').format(selectedEndDate!),
        );
      }
    }
  }

  Future<void> _pickEndDate() async {
    final firstDate = selectedStartDate ?? DateTime(2000);
    final lastDate = DateTime.now();
    final initialDate = selectedEndDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = picked;
      });
      if (selectedStartDate != null) {
        widget.onDateRangeSelected(
          DateFormat('yyyy-MM-dd').format(selectedStartDate!),
          DateFormat('yyyy-MM-dd').format(selectedEndDate!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize =
        screenWidth > 600 ? 150.0 : (screenWidth > 400 ? 120.0 : 80.0);

    final defaultStart = DateTime.now().subtract(const Duration(days: 30));
    final defaultEnd = DateTime.now();
    final displayStart = selectedStartDate ?? defaultStart;
    final displayEnd = selectedEndDate ?? defaultEnd;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปผัก
          Container(
            width: imageSize,
            height: imageSize,
            child: Image.network(
              widget.vegetable['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Text("Image not available")),
            ),
          ),
          const SizedBox(width: 16),

          // คอลัมน์ขวา: ชื่อ/หน่วย, ปุ่ม quick range, ปุ่ม date/comparison/download
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อ + หน่วย
                Text(
                  widget.vegetable['name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "หน่วย: ${widget.vegetable['unit']}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // ——— ปุ่ม 10 วัน / 1 เดือน / 3 เดือน ———
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        final now = DateTime.now();
                        final tenDaysAgo =
                            now.subtract(const Duration(days: 10));
                        setState(() {
                          selectedStartDate = tenDaysAgo;
                          selectedEndDate = now;
                        });
                        widget.onDateRangeSelected(
                          DateFormat('yyyy-MM-dd').format(tenDaysAgo),
                          DateFormat('yyyy-MM-dd').format(now),
                        );
                      },
                      child: const Text("10 วัน"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        final now = DateTime.now();
                        final oneMonthAgo =
                            now.subtract(const Duration(days: 30));
                        setState(() {
                          selectedStartDate = oneMonthAgo;
                          selectedEndDate = now;
                        });
                        widget.onDateRangeSelected(
                          DateFormat('yyyy-MM-dd').format(oneMonthAgo),
                          DateFormat('yyyy-MM-dd').format(now),
                        );
                      },
                      child: const Text("1 เดือน"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        final now = DateTime.now();
                        final threeMonthsAgo =
                            now.subtract(const Duration(days: 90));
                        setState(() {
                          selectedStartDate = threeMonthsAgo;
                          selectedEndDate = now;
                        });
                        widget.onDateRangeSelected(
                          DateFormat('yyyy-MM-dd').format(threeMonthsAgo),
                          DateFormat('yyyy-MM-dd').format(now),
                        );
                      },
                      child: const Text("3 เดือน"),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ——— ปุ่ม วันที่–เปรียบเทียบ–ดาวน์โหลด (Wrap) ———
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _pickStartDate,
                      child: Text(
                        "วันที่เริ่มต้น: ${DateFormat('dd/MM/yyyy').format(displayStart)}",
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickEndDate,
                      child: Text(
                        "วันที่สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(displayEnd)}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: widget.onYearlyComparisonPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text("เปรียบเทียบราคาพืชรายปี"),
                    ),
                    ElevatedButton(
                      onPressed: widget.onDownloadExcel,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text("ดาวน์โหลดข้อมูล"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PriceTableNew extends StatelessWidget {
  final List<dynamic> dailyPrices;
  final Map<String, dynamic> summary;
  final String unit;
  final String imageUrl;
  final String name;

  const PriceTableNew({
    Key? key,
    required this.dailyPrices,
    required this.summary,
    required this.unit,
    required this.imageUrl,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เรียงลำดับข้อมูลจากวันที่ใหม่ไปเก่า
    List<dynamic> sortedPrices = List.from(dailyPrices);
    sortedPrices.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ตารางราคาสินค้า",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          "ราคาเฉลี่ยรวม: ${double.tryParse(summary['overall_average'].toString())?.toStringAsFixed(2) ?? '-'}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "ราคารวมสูงสุด: ${summary['overall_max']}",
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          "ราคารวมต่ำสุด: ${summary['overall_min']}",
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          "การเปลี่ยนแปลงราคา: ${summary['price_change'] ?? '-'}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              flex: 5,
              child: Text(
                "รายการ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "วันที่",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "ราคา/หน่วย",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "ราคาต่ำสุด-สูงสุด",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final entry in sortedPrices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                "Image not available",
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(entry['date'])),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text("฿ ${entry['average_price']}"),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${entry['min_price']} - ${entry['max_price']}",
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        Text(
          "รวมทั้งหมด ${sortedPrices.length} รายการ",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
