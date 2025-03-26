import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'quarterly_graph.dart'; // สมมติว่า widget สำหรับกราฟถูกแยกไว้ในไฟล์นี้

class VegetableForecastCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final Map<String, dynamic> summary;
  final String startDate;
  final String endDate;
  final List<dynamic> graphDailyPrices; // ข้อมูล historical สำหรับกราฟ
  final List<dynamic>? graphPredictedPrices; // ข้อมูล predicted สำหรับกราฟ

  const VegetableForecastCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.summary,
    required this.startDate,
    required this.endDate,
    required this.graphDailyPrices,
    this.graphPredictedPrices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // แปลงค่าจาก summary โดยไม่มีทศนิยม
    final overallAverage = summary['overall_average'] != null
        ? summary['overall_average'].toStringAsFixed(0)
        : '-';
    final overallMin = summary['overall_min'] != null
        ? summary['overall_min'].toStringAsFixed(0)
        : '-';
    final overallMax = summary['overall_max'] != null
        ? summary['overall_max'].toStringAsFixed(0)
        : '-';
    final priceChange = summary['price_change'] ?? '-';

    // กำหนดขนาดฟอนต์แบบยืดหยุ่นตามความกว้างหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final double baseFontSize =
        screenWidth > 1024 ? 14 : (screenWidth > 600 ? 12 : 10);
    final double averageFontSize =
        screenWidth > 1024 ? 36 : (screenWidth > 600 ? 32 : 28);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // คอลัมน์ที่ 1: รูปภาพ + ข้อมูลพื้นฐานของผัก
            Expanded(
              flex: 1,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Column(
                  children: [
                    // รูปภาพ
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // ชื่อ + ราคา
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // คอลัมน์ที่ 2: กราฟ (Historical + Predicted)
            Expanded(
              flex: 2,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                ),
                child: QuarterlyGraph(
                  startDate: DateTime.parse(startDate),
                  endDate: DateTime.parse(endDate),
                  dailyPrices: graphDailyPrices,
                  predictedPrices: graphPredictedPrices,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // คอลัมน์ที่ 3: Summary
            Expanded(
              flex: 1,
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, // พื้นหลังสีขาว
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หัวข้อ Summary ติดขอบซ้ายบน
                    Text(
                      "Summary",
                      style: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // เนื้อหาสรุป (จัดให้อยู่ติดกับหัวข้อ)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ราคาเฉลี่ยรวม(บาท/กก.)
                          Text(
                            "ราคาเฉลี่ยรวม(บาท/กก.):",
                            style: TextStyle(
                              fontSize: baseFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Center(
                            child: Text(
                              "$overallAverage",
                              style: TextStyle(
                                fontSize: averageFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ช่วงราคารวมต่ำสุด - สูงสุด
                          Text(
                            "ช่วงราคารวมต่ำสุด - สูงสุด:",
                            style: TextStyle(
                              fontSize: baseFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "฿$overallMin - ฿$overallMax",
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ราคา {price_change}
                          Text(
                            "ราคา $priceChange",
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: priceChange.contains("⭡")
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
