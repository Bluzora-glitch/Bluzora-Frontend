import 'package:flutter/material.dart';

class QuarterlyGraph extends StatelessWidget {
  final String startDate;
  final String endDate;
  final List<dynamic> dailyPrices;

  const QuarterlyGraph({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.dailyPrices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กรองข้อมูลกราฟตามช่วงวันที่ที่เลือก
    final filteredData = dailyPrices.where((price) {
      final date = DateTime.parse(price['date']);
      return date.isAfter(DateTime.parse(startDate)) &&
          date.isBefore(DateTime.parse(endDate));
    }).toList();

    return Container(
      height: 200, // กำหนดความสูงให้แน่นอน
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
            "ตรงคือกราฟ จะแสดงข้อมูลย้อนหลังตามเมื่อกดตามวันต่างๆ"), // หรือแสดงกราฟจริง
      ),
    );
  }
}
