import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'quarterly_avg.dart'; // อย่าลืมนำเข้า QuarterlyGraph จากไฟล์เดิม
import 'quarterly_graph.dart';

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
                    // ใช้ QuarterlyGraph ที่นำเข้าแทนของเดิม
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
