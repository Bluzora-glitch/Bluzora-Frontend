import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quarterly_graph.dart';
import 'component_comparison.dart';
import 'component_price_forecast.dart';
import 'package:url_launcher/url_launcher.dart';

class QuarterlyAvgPage extends StatefulWidget {
  // รับเฉพาะ key: name, image (URL), unit
  final Map<String, dynamic> vegetable;
  const QuarterlyAvgPage({Key? key, required this.vegetable}) : super(key: key);

  @override
  _QuarterlyAvgPageState createState() => _QuarterlyAvgPageState();
}

class _QuarterlyAvgPageState extends State<QuarterlyAvgPage> {
  late String startDate;
  late String endDate;
  Map<String, dynamic>? fetchedData; // ข้อมูลที่ดึงมาจาก API
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // ตั้งค่า default: 30 วันก่อนถึงวันนี้
    final now = DateTime.now();
    final defaultStart = now.subtract(const Duration(days: 30));
    startDate = DateFormat('yyyy-MM-dd').format(defaultStart);
    endDate = DateFormat('yyyy-MM-dd').format(now);
    // เรียก API อัตโนมัติเมื่อหน้าจอเปิด
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final cropName = widget.vegetable['name'];
    final url =
        'http://127.0.0.1:8000/api/quarterly-avg/?crop_name=$cropName&startDate=$startDate&endDate=$endDate';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fetchedData = data;
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
    setState(() {
      isLoading = false;
    });
  }

  // ฟังก์ชันอัพเดทวันที่และเรียก API ใหม่ทันที
  void _updateDateRange(String newStart, String newEnd) {
    setState(() {
      startDate = newStart;
      endDate = newEnd;
    });
    _fetchData();
  }

  /// ฟังก์ชันดาวน์โหลดข้อมูล (เรียก API Excel) -- อยู่ในหน้าหลัก
  Future<void> _downloadExcel() async {
    final cropName = widget.vegetable['name'];
    final url =
        'http://127.0.0.1:8000/api/export-excel/?vegetableName=$cropName&startDate=$startDate&endDate=$endDate';

    // ใช้ url_launcher เพื่อเปิดลิงก์ในเบราว์เซอร์
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      // เปิดลิงก์ในเบราว์เซอร์ภายนอก
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF0),
      appBar: AppBar(
        title: Text(widget.vegetable['name'] ?? 'Vegetable'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // ใช้ Column + Row เหมือนเดิม
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนซ้าย: VegetableSelection (เลือกวันที่, แสดงข้อมูลผัก) + กราฟ
              // ส่วนขวา: ตารางราคา
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------
                    // คอลัมน์ซ้าย (Expanded flex: 2)
                    // ------------------------------------
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // ส่ง callback _downloadExcel ไปให้ VegetableSelection
                          VegetableSelection(
                            vegetable: widget.vegetable,
                            onDateRangeSelected: (start, end) {
                              _updateDateRange(start, end);
                            },
                            onDownloadExcel: _downloadExcel,
                          ),
                          const SizedBox(height: 16),
                          // ส่วนแสดงกราฟ
                          Container(
                            width: double.infinity,
                            height: 300, // กำหนดความสูงกราฟ
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
                                            style:
                                                TextStyle(color: Colors.grey),
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
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ------------------------------------
                    // คอลัมน์ขวา (Expanded flex: 1)
                    // ------------------------------------
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Comparison Section
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
              // Price Forecast Section
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
/// VegetableSelection: widget ย่อย มีหน้าที่แค่เลือกวันที่ + แสดงข้อมูลผัก
/// แต่จะได้รับ callback onDownloadExcel จาก parent เพื่อเรียกดาวน์โหลด
/// --------------------------------------------------------------------------
class VegetableSelection extends StatefulWidget {
  final Map<String, dynamic> vegetable;
  final Function(String startDate, String endDate) onDateRangeSelected;
  final VoidCallback onDownloadExcel; // รับ callback จาก parent

  const VegetableSelection({
    Key? key,
    required this.vegetable,
    required this.onDateRangeSelected,
    required this.onDownloadExcel,
  }) : super(key: key);

  @override
  _VegetableSelectionState createState() => _VegetableSelectionState();
}

class _VegetableSelectionState extends State<VegetableSelection> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> _pickStartDate() async {
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now();
    final initialDate =
        selectedStartDate ?? DateTime.now().subtract(const Duration(days: 30));

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
    final firstDate = DateTime(2000);
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
    // ถ้ายังไม่เลือก ให้ default เป็น 30 วันก่อน - วันนี้
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนบน: รูปซ้าย + ชื่อผัก + หน่วย
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ใช้ Image.network แทน Image.asset
              Container(
                width: 150,
                height: 150,
                child: Image.network(
                  widget.vegetable['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text("Image not available"),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // ข้อมูลผัก
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vegetable['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "หน่วย: ${widget.vegetable['unit']}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ปุ่ม 10 วัน, 1 เดือน, 3 เดือน
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
                              DateFormat('yyyy-MM-dd')
                                  .format(selectedStartDate!),
                              DateFormat('yyyy-MM-dd').format(selectedEndDate!),
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
                              DateFormat('yyyy-MM-dd')
                                  .format(selectedStartDate!),
                              DateFormat('yyyy-MM-dd').format(selectedEndDate!),
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
                              DateFormat('yyyy-MM-dd')
                                  .format(selectedStartDate!),
                              DateFormat('yyyy-MM-dd').format(selectedEndDate!),
                            );
                          },
                          child: const Text("3 เดือน"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickStartDate,
                            child: Text(
                              "วันที่เริ่มต้น: ${DateFormat('dd/MM/yyyy').format(displayStart)}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickEndDate,
                            child: Text(
                              "วันที่สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(displayEnd)}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // เพิ่ม Expanded ครอบปุ่มดาวน์โหลดข้อมูล
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onDownloadExcel,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: const Text("ดาวน์โหลดข้อมูล"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
        // หัวข้อของตาราง
        const Text(
          "ตารางราคาสินค้า",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // แสดง Summary ด้านบนของตาราง (ข้อความนี้ใช้ตัวปกติ)
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
        // Header row ของตาราง
        Row(
          children: [
            const Expanded(
              flex: 5,
              child: Text(
                "รายการ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                "วันที่",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "ราคา/$unit",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                "ราคาต่ำสุด-สูงสุด",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Data rows ของตาราง
        for (final entry in sortedPrices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                // คอลัมน์ "รายการ": รูปและชื่อผัก
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
                                "No image",
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
                // คอลัมน์ "วันที่"
                Expanded(
                  flex: 3,
                  child: Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(entry['date'])),
                  ),
                ),
                // คอลัมน์ "ราคา/หน่วย": แสดง "฿ {average_price}"
                Expanded(
                  flex: 2,
                  child: Text(
                    "฿ ${entry['average_price']}",
                  ),
                ),
                // คอลัมน์ "ราคาต่ำสุด-สูงสุด"
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
        // แสดงจำนวนรายการ
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
