import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// โมเดลข้อมูลสำหรับกราฟ
class ChartData {
  final DateTime date;
  final double minPrice;
  final double maxPrice;
  final double? avgPrice; // ใช้สำหรับ historical
  final double? predictedPrice; // ใช้สำหรับ predicted

  ChartData({
    required this.date,
    required this.minPrice,
    required this.maxPrice,
    this.avgPrice,
    this.predictedPrice,
  });
}

/// Widget สำหรับแสดงกราฟเปรียบเทียบราคาผัก
/// โดยรวมข้อมูล historical และ predicted เข้าด้วยกันเป็น series เดียว
class ComparisonGraph extends StatelessWidget {
  /// forecastDataList: รายการข้อมูล forecast ของผักแต่ละชนิด
  /// แต่ละ element มี key: "name", "dailyPrices", "predictedPrices"
  final List<Map<String, dynamic>> forecastDataList;
  final DateTime startDate;
  final DateTime endDate;

  const ComparisonGraph({
    Key? key,
    required this.forecastDataList,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กำหนดชุดสีพื้นฐานสำหรับแต่ละผัก
    final List<Color> baseColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
    ];

    List<CartesianSeries<ChartData, DateTime>> seriesList = [];

    // สำหรับแต่ละผักที่เลือก
    for (int i = 0; i < forecastDataList.length; i++) {
      final forecast = forecastDataList[i];
      final vegetableName = forecast['name'] as String;
      final List<dynamic> dailyPrices = forecast['dailyPrices'] ?? [];
      final List<dynamic> predictedPrices = forecast['predictedPrices'] ?? [];

      // Process historical data
      List<ChartData> historicalData = dailyPrices.map((item) {
        DateTime dt = DateTime.parse(item['date']);
        return ChartData(
          date: dt,
          minPrice: item['min_price'] != null
              ? double.tryParse(item['min_price'].toString()) ?? 0.0
              : 0.0,
          maxPrice: item['max_price'] != null
              ? double.tryParse(item['max_price'].toString()) ?? 0.0
              : 0.0,
          avgPrice: item['average_price'] != null
              ? double.tryParse(item['average_price'].toString()) ?? 0.0
              : 0.0,
        );
      }).toList();
      historicalData.sort((a, b) => a.date.compareTo(b.date));

      // Process predicted data
      List<ChartData> predictedData = [];
      if (predictedPrices.isNotEmpty) {
        predictedData = predictedPrices.map((item) {
          DateTime dt = DateTime.parse(item['date']);
          return ChartData(
            date: dt,
            minPrice: 0,
            maxPrice: 0,
            predictedPrice: item['predicted_price'] != null
                ? double.tryParse(item['predicted_price'].toString()) ?? 0.0
                : 0.0,
          );
        }).toList();
        predictedData.sort((a, b) => a.date.compareTo(b.date));

        // กรองเฉพาะ predicted ที่อยู่หลังจาก historical วันสุดท้าย
        if (historicalData.isNotEmpty) {
          DateTime lastHistoricalDate = historicalData.last.date;
          predictedData = predictedData
              .where((data) => data.date.isAfter(lastHistoricalDate))
              .toList();
        }
      }

      // Merge historical and predicted data
      List<ChartData> mergedData = List.from(historicalData);
      if (predictedData.isNotEmpty) {
        // แทรก predicted data หลังสุดของ historical
        mergedData.addAll(predictedData);
      }
      mergedData.sort((a, b) => a.date.compareTo(b.date));

      // กำหนดสีสำหรับผักชนิดนี้
      Color baseColor = baseColors[i % baseColors.length];
      Color historicalColor = baseColor; // ใช้สำหรับ historical
      Color predictedColor = baseColor.withOpacity(0.5); // ใช้สำหรับ predicted

      // เก็บวันสุดท้ายของ historical เพื่อใช้ใน tooltip
      DateTime lastHistoricalDate = historicalData.isNotEmpty
          ? historicalData.last.date
          : DateTime.fromMillisecondsSinceEpoch(0);

      // สร้าง series เดียวสำหรับผักชนิดนี้
      seriesList.add(
        LineSeries<ChartData, DateTime>(
          dataSource: mergedData,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) {
            // ถ้าวันที่อยู่ในช่วง historical ใช้ avgPrice, ถ้าเป็น predicted ใช้ predictedPrice (fallback เป็น avgPrice)
            if (data.date.isBefore(lastHistoricalDate) ||
                data.date.isAtSameMomentAs(lastHistoricalDate)) {
              return data.avgPrice ?? 0.0;
            } else {
              return data.predictedPrice ?? data.avgPrice ?? 0.0;
            }
          },
          // กำหนดสีของจุดตามช่วงเวลา
          pointColorMapper: (ChartData data, _) {
            if (data.date.isBefore(lastHistoricalDate) ||
                data.date.isAtSameMomentAs(lastHistoricalDate)) {
              return historicalColor;
            } else {
              return predictedColor;
            }
          },
          markerSettings:
              const MarkerSettings(isVisible: true, width: 8, height: 8),
          enableTooltip: true,
          name:
              vegetableName, // series นี้แสดงชื่อผักเดียว ซึ่งจะ toggle ได้เป็นรายการเดียว
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SfCartesianChart(
        legend: Legend(
          isVisible: true,
          toggleSeriesVisibility: true,
        ),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('d MMM'),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '฿{value}',
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final ChartData chartData = data;
            final String vegName = series.name ?? '';
            // ถ้า predictedPrice มีค่า (> 0) ให้ถือว่าเป็นข้อมูล predicted
            bool isPredicted = (chartData.predictedPrice != null &&
                chartData.predictedPrice! > 0);
            String typeText = isPredicted ? "ราคาพยากรณ์" : "ราคาย้อนหลัง";
            String priceText = isPredicted
                ? (chartData.predictedPrice?.toStringAsFixed(0) ?? '-')
                : (chartData.avgPrice?.toStringAsFixed(0) ?? '-');

            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$typeText\n$vegName\n${DateFormat('d MMM yyyy').format(chartData.date)}\n฿$priceText",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          },
        ),
        series: seriesList,
      ),
    );
  }
}
