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

class YearlyComparisonGraph extends StatefulWidget {
  final String mainStartDate; // รูปแบบ 'yyyy-MM-dd'
  final String mainEndDate; // รูปแบบ 'yyyy-MM-dd'
  final List<Map<String, dynamic>> yearlyData;
  // yearlyData: List ของ Map แต่ละตัวมี key 'year' (int) และ 'dailyPrices' (List<dynamic>)

  const YearlyComparisonGraph({
    Key? key,
    required this.mainStartDate,
    required this.mainEndDate,
    required this.yearlyData,
  }) : super(key: key);

  @override
  _YearlyComparisonGraphState createState() => _YearlyComparisonGraphState();
}

class _YearlyComparisonGraphState extends State<YearlyComparisonGraph> {
  // Map สำหรับควบคุมการแสดงผลของแต่ละปี (true = visible)
  late Map<int, bool> _yearVisibility;

  // กำหนดสีสำหรับปีปัจจุบัน และลิสต์สีสำหรับปีอื่นๆ
  final Color currentYearColor = Colors.blue;
  final List<Color> otherYearColors = [
    Colors.green,
    Colors.purple.shade200,
    Colors.orange.shade300,
    Colors.pink.shade300
  ];

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นให้กับแต่ละปีจาก yearlyData (ทุกปีเปิดให้แสดง)
    _yearVisibility = {};
    for (var data in widget.yearlyData) {
      int year = data['year'] ?? 0;
      _yearVisibility[year] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง seriesList สำหรับปีที่ _yearVisibility[year] == true
    List<CartesianSeries<ChartData, DateTime>> seriesList = [];
    for (var dataPerYear in widget.yearlyData) {
      int year = dataPerYear['year'] ?? 0;
      // ถ้าปีนี้ถูก toggle off ใหข้าม series แต่ยังคงอยู่ใน legend
      if (!(_yearVisibility[year] ?? true)) continue;

      final String yearLabel = year.toString();
      final List<dynamic> dailyPrices = dataPerYear['dailyPrices'] ?? [];

      // Map dailyPrices เป็น List<ChartData> โดย normalize วันที่ให้มีปีคงที่ (2000)
      List<ChartData> chartDataList = dailyPrices.map<ChartData>((item) {
        DateTime originalDate = DateTime.parse(item['date']);
        // Normalize: ตั้งปีเป็น 2000 เพื่อให้แกน X แสดงเฉพาะวันและเดือน
        DateTime normalizedDate =
            DateTime(2000, originalDate.month, originalDate.day);
        return ChartData(
          date: normalizedDate,
          minPrice: double.tryParse(item['min_price'].toString()) ?? 0.0,
          maxPrice: double.tryParse(item['max_price'].toString()) ?? 0.0,
          avgPrice: double.tryParse(item['average_price'].toString()) ?? 0.0,
        );
      }).toList();

      if (chartDataList.isEmpty) continue;
      chartDataList.sort((a, b) => a.date.compareTo(b.date));

      // กำหนดสีสำหรับเส้นกราฟ: หากปีนี้เป็นปีปัจจุบัน (จากระบบ) ให้สีเขียว,
      // ถ้าไม่ใช่ ให้ใช้สีจาก otherYearColors โดยคำนวณจากค่า year
      Color seriesColor = (year == DateTime.now().year)
          ? currentYearColor
          : otherYearColors[year % otherYearColors.length];

      // สร้าง RangeAreaSeries สำหรับแสดงช่วงราคาต่ำสุด-สูงสุด
      seriesList.add(
        RangeAreaSeries<ChartData, DateTime>(
          dataSource: chartDataList,
          xValueMapper: (ChartData data, _) => data.date,
          lowValueMapper: (ChartData data, _) => data.minPrice,
          highValueMapper: (ChartData data, _) => data.maxPrice,
          // ไม่ต้องการให้แสดงใน legend
          isVisibleInLegend: false,
          color: seriesColor.withOpacity(0.2),
          enableTooltip: false,
        ),
      );

      // สร้าง LineSeries สำหรับแสดงราคาเฉลี่ย
      seriesList.add(
        LineSeries<ChartData, DateTime>(
          dataSource: chartDataList,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.avgPrice,
          name: yearLabel, // ชื่อใน legend
          color: seriesColor,
          markerSettings:
              const MarkerSettings(isVisible: true, width: 8, height: 8),
          enableTooltip: true,
        ),
      );
    }

    // สร้าง custom legend สำหรับทุกปีใน widget.yearlyData (ไม่คัดกรองด้วย _yearVisibility)
    List<_LegendItem> legendItems = [];
    for (var data in widget.yearlyData) {
      int year = data['year'] ?? 0;
      legendItems.add(_LegendItem(year: year));
    }

    Widget customLegend = Wrap(
      spacing: 16,
      children: legendItems.map((item) {
        bool isVisible = _yearVisibility[item.year] ?? true;
        Color legendColor = item.getColor(otherYearColors, currentYearColor);
        return GestureDetector(
          onTap: () {
            setState(() {
              _yearVisibility[item.year] = !isVisible;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVisible ? Icons.check_box : Icons.check_box_outline_blank,
                color: legendColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                item.year.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: legendColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    return Column(
      children: [
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SfCartesianChart(
            title: ChartTitle(
              text:
                  'เปรียบเทียบราคาพืชรายปี\n(${widget.mainStartDate} - ${widget.mainEndDate})',
              textStyle: const TextStyle(fontSize: 16),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                final ChartData chartData = data;
                final String yearLabel = series.name; // ใช้ series.name เป็นปี
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 140), // จำกัดความกว้างสูงสุด 220 พิกเซล
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // เนื้อหาชิดซ้าย
                      children: [
                        // หัวข้อแสดงปี
                        Text(
                          yearLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Divider(color: Colors.white54, thickness: 1),
                        const SizedBox(height: 1),
                        // เนื้อหารายละเอียด
                        Text(
                          "วันที่: ${DateFormat('d MMM').format(chartData.date)}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                          softWrap: true, // ให้ข้อความขึ้นบรรทัดใหม่ได้
                        ),
                        Text(
                          "ราคาเฉลี่ย: ฿${chartData.avgPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                          softWrap: true,
                        ),
                        Text(
                          "ช่วงราคา: ฿${chartData.minPrice.toStringAsFixed(0)} - ฿${chartData.maxPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('d MMM'),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '฿{value}',
            ),
            series: seriesList,
          ),
        ),
        const SizedBox(height: 8),
        customLegend,
      ],
    );
  }
}

class _LegendItem {
  final int year;
  _LegendItem({required this.year});

  Color getColor(List<Color> otherColors, Color currentYearColor) {
    return year == DateTime.now().year
        ? currentYearColor
        : otherColors[year % otherColors.length];
  }
}
