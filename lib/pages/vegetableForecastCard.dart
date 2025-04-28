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
    // แปลงค่าจาก summary
    final overallAverage = summary['overall_average'] != null
        ? summary['overall_average'].toStringAsFixed(2)
        : '-';
    final overallMin = summary['overall_min'] != null
        ? summary['overall_min'].toStringAsFixed(2)
        : '-';
    final overallMax = summary['overall_max'] != null
        ? summary['overall_max'].toStringAsFixed(2)
        : '-';
    final priceChangePercent = summary['price_change_percent'] != null
        ? '${summary['price_change_percent'].toStringAsFixed(2)}%'
        : '-';
    final volatilityPercent = summary['volatility_percent'] != null
        ? '${summary['volatility_percent'].toStringAsFixed(2)}%'
        : '-';

    // เช็คว่ามีข้อมูลกราฟหรือไม่
    final bool hasGraphData = graphDailyPrices.isNotEmpty ||
        (graphPredictedPrices != null && graphPredictedPrices!.isNotEmpty);

    // กำหนดขนาดฟอนต์ตามหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 767;
    final double baseFontSize = isMobile ? 12 : (screenWidth > 1024 ? 14 : 12);
    final double averageFontSize =
        isMobile ? 28 : (screenWidth > 1024 ? 36 : 32);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 10),
                  _buildGraphSection(hasGraphData, baseFontSize),
                  const SizedBox(height: 10),
                  _buildSummarySection(
                      baseFontSize,
                      averageFontSize,
                      overallAverage,
                      overallMin,
                      overallMax,
                      priceChangePercent,
                      volatilityPercent),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildImageSection()),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 2,
                      child: _buildGraphSection(hasGraphData, baseFontSize)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildSummarySection(
                        baseFontSize,
                        averageFontSize,
                        overallAverage,
                        overallMin,
                        overallMax,
                        priceChangePercent,
                        volatilityPercent),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Column(
        children: [
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
    );
  }

  Widget _buildGraphSection(bool hasGraphData, double fontSize) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
      ),
      child: hasGraphData
          ? QuarterlyGraph(
              startDate: DateTime.parse(startDate),
              endDate: DateTime.parse(endDate),
              dailyPrices: graphDailyPrices,
              predictedPrices: graphPredictedPrices,
            )
          : Center(
              child: Text(
                "ไม่มีข้อมูลในช่วงเวลาที่เลือก",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Widget _buildSummarySection(
    double baseFontSize,
    double averageFontSize,
    String overallAverage,
    String overallMin,
    String overallMax,
    String priceChangePercent,
    String volatilityPercent,
  ) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Summary",
            style: TextStyle(
              fontSize: baseFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ราคาเฉลี่ยรวม(บาท/กก.):",
                  style: TextStyle(
                    fontSize: baseFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Center(
                  child: Text(
                    overallAverage,
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
                Text(
                  "ช่วงราคารวมต่ำสุด - สูงสุด: ฿$overallMin - ฿$overallMax",
                  style: TextStyle(
                    fontSize: baseFontSize,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "ความผันผวนราคา: $volatilityPercent",
                  style: TextStyle(
                    fontSize: baseFontSize,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "แนวโน้มราคา: $priceChangePercent",
                  style: TextStyle(
                    fontSize: baseFontSize,
                    color: priceChangePercent.startsWith('-')
                        ? Colors.red
                        : Colors.green,
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
