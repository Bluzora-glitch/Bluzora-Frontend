import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'quarterly_graph.dart';
// import 'quarterly_vegetable_selection.dart';

import 'component_comparison.dart';
import 'component_price_forecast.dart';

class QuarterlyAvgPage extends StatefulWidget {
  final Map<String, dynamic> vegetable;
  const QuarterlyAvgPage({Key? key, required this.vegetable}) : super(key: key);

  @override
  _QuarterlyAvgPageState createState() => _QuarterlyAvgPageState();
}

class _QuarterlyAvgPageState extends State<QuarterlyAvgPage> {
  String? startDate;
  String? endDate;

  @override
  Widget build(BuildContext context) {
    final dailyPrices = widget.vegetable['dailyPrices'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF0),
      appBar: AppBar(
        title: Text(widget.vegetable['name'] ?? 'Vegetable'),
      ),
      body: dailyPrices.isEmpty
          ? const Center(
              child: Text(
                "ไม่พบข้อมูลราคาประจำวัน",
                style: TextStyle(color: Colors.red),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ป้องกัน Column ขยายเกินจอ
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vegetable Selection & Price Table
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height *
                            0.5, // กำหนดความสูงขั้นต่ำ
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vegetable Selection
                          Expanded(
                            flex: 2,
                            child: VegetableSelection(
                              vegetable: widget.vegetable,
                              dailyPrices: dailyPrices,
                              onDateRangeSelected: (start, end) {
                                setState(() {
                                  startDate = start;
                                  endDate = end;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Price Table
                          Expanded(
                            flex: 1,
                            child: startDate == null || endDate == null
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "กรุณาเลือกวันที่เพื่อดูราคา",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : PriceTable(
                                    startDate: startDate!,
                                    endDate: endDate!,
                                    vegetable: widget.vegetable,
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
                                ? 150.0 // เดสก์ท็อป
                                : MediaQuery.of(context).size.width > 600
                                    ? 80.0 // แท็บเล็ต
                                    : 16.0, // มือถือ
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
                                ? 150.0 // เดสก์ท็อป
                                : MediaQuery.of(context).size.width > 600
                                    ? 80.0 // แท็บเล็ต
                                    : 16.0, // มือถือ
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

class VegetableSelection extends StatelessWidget {
  final Map<String, dynamic> vegetable;
  final List<dynamic> dailyPrices;
  final Function(String startDate, String endDate) onDateRangeSelected;

  const VegetableSelection({
    Key? key,
    required this.vegetable,
    required this.dailyPrices,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                vegetable['image'],
                height: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vegetable['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      vegetable['price'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          onPressed: () {},
                          child: const Text("10 วัน"),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          onPressed: () {},
                          child: const Text("1 เดือน"),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          onPressed: () {},
                          child: const Text("3 เดือน"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("วันที่เริ่มต้น"),
                            value: null,
                            items: dailyPrices.map((entry) {
                              final date = entry['date'];
                              return DropdownMenuItem<String>(
                                value: date,
                                child: Text(DateFormat('dd/MM/yyyy')
                                    .format(DateTime.parse(date))),
                              );
                            }).toList(),
                            onChanged: (start) {
                              if (start != null) {
                                onDateRangeSelected(
                                    start,
                                    dailyPrices
                                        .last['date']); // Default to last
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("วันที่สิ้นสุด"),
                            value: null,
                            items: dailyPrices.map((entry) {
                              final date = entry['date'];
                              return DropdownMenuItem<String>(
                                value: date,
                                child: Text(DateFormat('dd/MM/yyyy')
                                    .format(DateTime.parse(date))),
                              );
                            }).toList(),
                            onChanged: (end) {
                              if (end != null) {
                                onDateRangeSelected(dailyPrices.first['date'],
                                    end); // Default to first
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ใช้ `QuarterlyGraph` ที่นำเข้าแทนของเดิม
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: QuarterlyGraph(
                        startDate: dailyPrices.first['date'],
                        endDate: dailyPrices.last['date'],
                        dailyPrices: dailyPrices,
                      ),
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

class PriceTable extends StatelessWidget {
  final String startDate;
  final String endDate;
  final Map<String, dynamic> vegetable;

  const PriceTable({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.vegetable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailyPrices = vegetable['dailyPrices'] as List<dynamic>;
    final filteredPrices = dailyPrices.where((entry) {
      final date = entry['date'];
      return date.compareTo(startDate) >= 0 && date.compareTo(endDate) <= 0;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ตารางราคา",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Header row
          Row(
            children: const [
              SizedBox(width: 40), // Placeholder for image column
              SizedBox(width: 8), // Spacing
              Expanded(
                flex: 2,
                child: Text(
                  "รายการ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "ราคา/หน่วย",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "วันที่",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "ค่าเฉลี่ย",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Space between header and rows
          // Data rows
          for (final entry in filteredPrices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Image.asset(
                    vegetable['image'],
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      vegetable['name'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      entry['price'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      entry['date'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      vegetable['change'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
