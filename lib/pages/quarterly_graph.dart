import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class QuarterlyGraph extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<dynamic> dailyPrices;

  const QuarterlyGraph({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.dailyPrices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กรองข้อมูลให้อยู่ในช่วงวันที่ที่เลือก
    final filteredData = dailyPrices.where((price) {
      final date = DateTime.parse(price['date']);
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList();

    if (filteredData.isEmpty) {
      return Container(
        height: 200,
        child: const Center(child: Text("ไม่มีข้อมูลในช่วงวันที่เลือก")),
      );
    }

    // แปลงข้อมูลที่กรองได้เป็น List<ChartData>
    List<ChartData> chartData = filteredData.map((price) {
      return ChartData(
        date: DateTime.parse(price['date']),
        minPrice: price['min_price'] != null
            ? double.tryParse(price['min_price'].toString()) ?? 0.0
            : 0.0,
        maxPrice: price['max_price'] != null
            ? double.tryParse(price['max_price'].toString()) ?? 0.0
            : 0.0,
        avgPrice: price['average_price'] != null
            ? double.tryParse(price['average_price'].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();

    // เรียงข้อมูลจากวันที่เก่ามาใหม่
    chartData.sort((a, b) => a.date.compareTo(b.date));

    // กำหนด minY และ maxY ให้มี margin เล็กน้อย
    double minY =
        chartData.map((data) => data.minPrice).reduce((a, b) => a < b ? a : b) -
            5;
    double maxY =
        chartData.map((data) => data.maxPrice).reduce((a, b) => a > b ? a : b) +
            5;

    return Container(
      height: 200,
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final ChartData chartData = data;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "วันที่: ${DateFormat('d MMM yyyy').format(chartData.date)}\n"
                "ราคาเฉลี่ย: ฿${chartData.avgPrice}\n"
                "ช่วงราคา: ฿${chartData.minPrice} - ฿${chartData.maxPrice}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          },
        ),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('dd MMM'),
          intervalType: DateTimeIntervalType.days,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '฿{value}',
          minimum: minY,
          maximum: maxY,
        ),
        series: <CartesianSeries<ChartData, DateTime>>[
          // RangeAreaSeries สำหรับแสดงช่วงราคาต่ำสุด-สูงสุด
          RangeAreaSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.date,
            lowValueMapper: (ChartData data, _) => data.minPrice,
            highValueMapper: (ChartData data, _) => data.maxPrice,
            name: 'ช่วงราคา',
            color: Colors.blue.withOpacity(0.2),
            enableTooltip: false,
          ),
          // LineSeries สำหรับแสดงราคาเฉลี่ย
          LineSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.avgPrice,
            name: 'ราคาเฉลี่ย',
            markerSettings:
                const MarkerSettings(isVisible: true, width: 8, height: 8),
            color: Colors.blue,
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;

  ChartData({
    required this.date,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
  });
}
