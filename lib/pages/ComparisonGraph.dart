// lib/pages/ComparisonGraph.dart

import 'dart:ui' as ui; // สำหรับสร้าง gradient shader
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// โมเดลข้อมูลสำหรับกราฟ
class ChartData {
  final DateTime date;
  final double minPrice;
  final double maxPrice;
  final double? avgPrice; // ราคาย้อนหลัง
  final double? predictedPrice; // ราคาพยากรณ์

  ChartData({
    required this.date,
    required this.minPrice,
    required this.maxPrice,
    this.avgPrice,
    this.predictedPrice,
  });
}

/// Widget สำหรับแสดงกราฟเปรียบเทียบราคาผัก
class ComparisonGraph extends StatelessWidget {
  final List<Map<String, dynamic>> forecastDataList;
  final DateTime startDate;
  final DateTime endDate;

  /// ปรับตำแหน่งและแนวของ legend จากภายนอก
  final LegendPosition legendPosition;
  final LegendItemOrientation legendOrientation;

  const ComparisonGraph({
    Key? key,
    required this.forecastDataList,
    required this.startDate,
    required this.endDate,
    this.legendPosition = LegendPosition.right,
    this.legendOrientation = LegendItemOrientation.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ชุดสีสำหรับแต่ละ series
    final baseColors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
    ];

    final seriesList = <CartesianSeries<ChartData, DateTime>>[];

    for (var i = 0; i < forecastDataList.length; i++) {
      final f = forecastDataList[i];
      final vegName = f['name'] as String;
      final daily = (f['dailyPrices'] as List<dynamic>);
      final pred = (f['predictedPrices'] as List<dynamic>);

      // แปลง historical
      final histData = daily.map((e) {
        final dt = DateTime.parse(e['date'] as String);
        return ChartData(
          date: dt,
          minPrice: double.tryParse(e['min_price'].toString()) ?? 0.0,
          maxPrice: double.tryParse(e['max_price'].toString()) ?? 0.0,
          avgPrice: double.tryParse(e['average_price'].toString()) ?? 0.0,
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // แปลง predicted
      var predData = <ChartData>[];
      if (pred.isNotEmpty) {
        predData = pred.map((e) {
          final dt = DateTime.parse(e['date'] as String);
          return ChartData(
            date: dt,
            minPrice: 0,
            maxPrice: 0,
            predictedPrice:
                double.tryParse(e['predicted_price'].toString()) ?? 0.0,
          );
        }).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        // กรองเฉพาะหลังสุดของ historical
        if (histData.isNotEmpty) {
          final lastHist = histData.last.date;
          predData = predData.where((d) => d.date.isAfter(lastHist)).toList();
        }
      }

      // รวมข้อมูลและเรียงตามวัน
      final merged = <ChartData>[...histData, ...predData]
        ..sort((a, b) => a.date.compareTo(b.date));

      // เลือกสี
      final baseColor = baseColors[i % baseColors.length];
      final histColor = baseColor;
      final predColor = baseColor.withOpacity(0.5);

      // คำนวณตำแหน่ง transition ของ gradient
      final startMs = startDate.millisecondsSinceEpoch.toDouble();
      final endMs = endDate.millisecondsSinceEpoch.toDouble();
      final lastMs = histData.isNotEmpty
          ? histData.last.date.millisecondsSinceEpoch.toDouble()
          : startMs;
      final fraction = (endMs > startMs)
          ? ((lastMs - startMs) / (endMs - startMs)).clamp(0.0, 1.0)
          : 0.0;

      // สร้าง series เดียว พร้อม gradient ไล่สี
      seriesList.add(
        LineSeries<ChartData, DateTime>(
          name: vegName,
          dataSource: merged,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) {
            if (histData.isNotEmpty &&
                (d.date.isBefore(histData.last.date) ||
                    d.date.isAtSameMomentAs(histData.last.date))) {
              return d.avgPrice ?? 0.0;
            }
            return d.predictedPrice ?? d.avgPrice ?? 0.0;
          },
          color: baseColor, // fallback สำหรับ legend และ stroke
          onCreateShader: (ShaderDetails details) {
            // ใช้ details.rect ในการคำนวณ gradient
            final rect = details.rect;
            return ui.Gradient.linear(
              rect.topLeft,
              rect.topRight,
              [histColor, histColor, predColor, predColor],
              [0.0, fraction, fraction, 1.0],
            );
          },
          pointColorMapper: (d, _) {
            if (histData.isNotEmpty &&
                (d.date.isBefore(histData.last.date) ||
                    d.date.isAtSameMomentAs(histData.last.date))) {
              return histColor;
            }
            return predColor;
          },
          markerSettings:
              const MarkerSettings(isVisible: true, width: 8, height: 8),
          enableTooltip: true,
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
          position: legendPosition,
          orientation: legendOrientation,
        ),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('d MMM'),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        primaryYAxis: NumericAxis(labelFormat: '฿{value}'),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder:
              (dynamic data, dynamic point, dynamic series, int idx, int sidx) {
            final cd = data as ChartData;
            final isPred = cd.predictedPrice != null && cd.predictedPrice! > 0;
            final type = isPred ? "ราคาพยากรณ์" : "ราคาย้อนหลัง";
            final price = isPred
                ? cd.predictedPrice!.toStringAsFixed(0)
                : (cd.avgPrice?.toStringAsFixed(0) ?? '-');
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$type\n${series.name}\n"
                "${DateFormat('d MMM yyyy').format(cd.date)}\n฿$price",
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
