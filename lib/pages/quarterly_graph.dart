import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ChartData {
  final DateTime date;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final double? predictedPrice;

  ChartData({
    required this.date,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    this.predictedPrice,
  });
}

class QuarterlyGraph extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<dynamic> dailyPrices; // Historical data
  final List<dynamic>? predictedPrices; // Predicted data (optional)

  const QuarterlyGraph({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.dailyPrices,
    this.predictedPrices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();

    // Parse historical data จาก dailyPrices
    List<ChartData> historicalData = dailyPrices
        .map((item) {
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
        })
        .where((data) =>
            data.date.isBefore(currentDate) ||
            data.date.isAtSameMomentAs(currentDate))
        .toList();
    historicalData.sort((a, b) => a.date.compareTo(b.date));

    // สำหรับ RangeAreaSeries ให้ใช้ข้อมูลที่มีอยู่จริงในฐานข้อมูล (ไม่รวมจุดที่สร้างขึ้นเอง)
    List<ChartData> rangeHistoricalData = List.from(historicalData);

    // ไม่ต้องสร้าง todayMarker ตอนนี้เราไม่ต้องแสดงจุดเขียวเพิ่มขึ้นมา

    // Parse predicted data (ถ้ามี) และกรองให้แสดงเฉพาะข้อมูลที่มีวันที่หลังจากข้อมูล historical จริง
    List<ChartData> predictedData = [];
    if (predictedPrices != null && predictedPrices!.isNotEmpty) {
      predictedData = predictedPrices!
          .map((item) {
            return ChartData(
              date: DateTime.parse(item['date']),
              minPrice: 0,
              maxPrice: 0,
              avgPrice: 0,
              predictedPrice: item['predicted_price'] != null
                  ? double.tryParse(item['predicted_price'].toString()) ?? 0.0
                  : 0.0,
            );
          })
          .where((data) => rangeHistoricalData.isNotEmpty
              ? data.date.isAfter(rangeHistoricalData.last.date)
              : true)
          .toList();
      predictedData.sort((a, b) => a.date.compareTo(b.date));

      // เชื่อมต่อ predicted data กับ historical dataโดยแทรกจุดสุดท้ายของ historical
      if (rangeHistoricalData.isNotEmpty && predictedData.isNotEmpty) {
        if (predictedData.first.date.isAfter(rangeHistoricalData.last.date)) {
          predictedData.insert(
            0,
            ChartData(
              date: rangeHistoricalData.last.date,
              minPrice: rangeHistoricalData.last.minPrice,
              maxPrice: rangeHistoricalData.last.maxPrice,
              avgPrice: rangeHistoricalData.last.avgPrice,
              predictedPrice: rangeHistoricalData.last.avgPrice,
            ),
          );
        }
      }
    }

    // คำนวณค่า minY และ maxY จาก rangeHistoricalData
    double minY = rangeHistoricalData
            .map((d) => d.minPrice)
            .reduce((a, b) => a < b ? a : b) -
        5;
    double maxY = rangeHistoricalData
            .map((d) => d.maxPrice)
            .reduce((a, b) => a > b ? a : b) +
        5;

    // สร้าง series ของกราฟ
    List<CartesianSeries<ChartData, DateTime>> seriesList = [
      // RangeAreaSeries สำหรับแสดงช่วงราคาต่ำสุด-สูงสุด (Historical)
      RangeAreaSeries<ChartData, DateTime>(
        dataSource: rangeHistoricalData,
        xValueMapper: (ChartData data, _) => data.date,
        lowValueMapper: (ChartData data, _) => data.minPrice,
        highValueMapper: (ChartData data, _) => data.maxPrice,
        name: 'ช่วงราคา',
        color: Colors.blue.withOpacity(0.2),
        enableTooltip: false,
      ),
      // LineSeries สำหรับแสดงราคาเฉลี่ย Historical (สีฟ้า)
      LineSeries<ChartData, DateTime>(
        dataSource: historicalData,
        xValueMapper: (ChartData data, _) => data.date,
        yValueMapper: (ChartData data, _) => data.avgPrice,
        name: 'Historical',
        color: Colors.blue,
        // ย้าย pointColorMapper มาอยู่ที่ระดับของ LineSeries
        pointColorMapper: (ChartData data, _) {
          // ไม่ต้องแสดง marker สีเขียวสำหรับวันนี้อีกต่อไป
          return Colors.blue;
        },
        markerSettings:
            const MarkerSettings(isVisible: true, width: 8, height: 8),
        enableTooltip: true,
      ),
    ];

    // ถ้ามีข้อมูล predicted ให้เพิ่ม series สำหรับ predicted data (สีส้ม)
    if (predictedData.isNotEmpty) {
      seriesList.add(
        LineSeries<ChartData, DateTime>(
          dataSource: predictedData,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.predictedPrice ?? 0.0,
          name: 'Predicted',
          color: Colors.orange,
          markerSettings:
              const MarkerSettings(isVisible: true, width: 8, height: 8),
          enableTooltip: true,
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('d MMM'),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '฿{value}',
          minimum: minY,
          maximum: maxY,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final ChartData chartData = data;
            if (series.name == 'Predicted') {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "วันที่: ${DateFormat('d MMM yyyy').format(chartData.date)}\n"
                  "ราคาพยากรณ์: ฿${chartData.predictedPrice?.toStringAsFixed(0) ?? '-'}",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "วันที่: ${DateFormat('d MMM yyyy').format(chartData.date)}\n"
                  "ราคาเฉลี่ย: ฿${chartData.avgPrice.toStringAsFixed(0)}\n"
                  "ช่วงราคา: ฿${chartData.minPrice.toStringAsFixed(0)} - ฿${chartData.maxPrice.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            }
          },
        ),
        series: seriesList,
      ),
    );
  }
}
